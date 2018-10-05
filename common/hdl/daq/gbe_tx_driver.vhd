------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company: TAMU
-- Engineer: Evaldas Juska (evaldas.juska@cern.ch, evka85@gmail.com)
-- 
-- Create Date:    01:33:00 2018-10-04
-- Module Name:    GBE_TX_DRIVER
-- Description:    This module is reading event data from an external FWFT FIFO and constructs ethernet packets to be sent out of the 1.25Gb/s GbE port 
------------------------------------------------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.csc_pkg.all;
use work.gth_pkg.all;

entity gbe_tx_driver is
    generic (
        g_MAX_PAYLOAD_WORDS     : integer := 3976; -- max payload size in 16bit words, excluding the packet counter
        g_MIN_PAYLOAD_WORDS     : integer := 32;   -- minimum payload size in 16bit words
        g_MAX_EVT_WORDS         : integer := 50000;-- maximum event size (nothing really gets done when this size is reached, but an error is asserted on the output port)
        g_NUM_IDLES_SMALL_EVT   : integer := 2;    -- minimum number of idle words after a "small" event
        g_NUM_IDLES_BIG_EVT     : integer := 7;    -- minimum number of idle words after a "big" event
        g_SMALL_EVT_MAX_WORDS   : integer := 24    -- above this number of words, the event is considered "big", thus requiring g_NUM_IDLES_BIG_EVT of idles after the packet
    );
    port (
        -- reset
        reset_i                 : in  std_logic;
        
        -- GbE link
        gbe_clk_i               : in  std_logic;
        gbe_tx_data_o           : out t_gt_8b10b_tx_data;
        
        -- config
        skip_eth_header_i       : in  std_logic; -- if this is set high, the eth header will be skipped, just like in DDU, otherwise this will produce normal ETH frames of eth type 0x8870
        
        -- control
        data_empty_i            : in  std_logic;
        data_i                  : in  std_logic_vector(15 downto 0);
        data_rd_en              : out std_logic;
        last_valid_word_i       : in  std_logic; -- this indicates that this is the last valid word (almost_empty flag of the external FWFT FIFO)
        
        -- status
        err_event_too_big_o     : out std_logic; -- this is asserted if an event exceeding g_MAX_EVT_WORDS was seen since last reset
        err_eoe_not_found_o     : out std_logic; -- this is asserted if the fifo became empty before an end of event was found (latched till reset)
        word_rate_o             : out std_logic_vector(31 downto 0) -- word rate in Hz (including the ethernet frame words)

    );
end gbe_tx_driver;

architecture gbe_tx_driver_arch of gbe_tx_driver is

    constant ETH_IDLE           : std_logic_vector(15 downto 0) := x"50BC";
    constant ETH_PREAMBLE_SOF   : t_std16_array(0 to 3) := (x"55FB", x"5555", x"5555", x"D555");
    constant ETH_HEADER         : t_std16_array(0 to 7) := (x"CFED", x"CFED", x"CFED", x"9E80", x"1417", x"1500", x"7088");
    constant ETH_EOF            : t_std16_array(0 to 3) := (x"F7FD", x"C5BC");
    constant DDU_EOE_WORD64     : std_logic_vector(63 downto 0) := x"8000ffff80008000";

    type t_eth_state is (IDLE, PREAMBLE_SOF, HEADER, PAYLOAD, FILLER, PACKET_CNT, CRC, EOF);
    
    signal state                : t_eth_state;
    signal word_idx             : integer range 0 to 16383 := 0;
    signal packet_idx           : unsigned(15 downto 0) := (others => '0');
    signal min_idle_cnt         : integer range 0 to g_NUM_IDLES_BIG_EVT := 0;
    signal first_filler_word    : std_logic := '0';
    signal not_idle             : std_logic;
    
    signal evt_word_cnt         : unsigned(15 downto 0) := (others => '0');
    signal word64               : std_logic_vector(63 downto 0) := (others => '0');
    signal eoe_detected         : std_logic := '0';
    signal eoe_countdown        : unsigned(2 downto 0) := (others => '0'); 
    signal eoe                  : std_logic := '0';
    
    signal crc_reset            : std_logic := '0';
    signal crc_en               : std_logic := '0';
    signal crc_reg              : std_logic_vector(31 downto 0);
    signal crc_current          : std_logic_vector(31 downto 0);
    
    signal err_evt_too_big      : std_logic := '0';
    signal err_eoe_not_found    : std_logic := '0';
    
    signal data                 : std_logic_vector(15 downto 0) := ETH_IDLE;
    signal charisk              : std_logic_vector(1 downto 0) := "01";

begin

    gbe_tx_data_o.txchardispmode <= (others => '0');
    gbe_tx_data_o.txchardispval <= (others => '0');
    gbe_tx_data_o.txcharisk <= "00" & charisk;
    gbe_tx_data_o.txdata <= x"0000" & data;
    
    err_event_too_big_o <= err_evt_too_big;
    err_eoe_not_found_o <= err_eoe_not_found;

    process(gbe_clk_i)
    begin
        if (rising_edge(gbe_clk_i)) then
            if (reset_i = '1') then
                state <= IDLE;
                word_idx <= 0;
                min_idle_cnt <= 0;
                data <= ETH_IDLE;
                charisk <= "01";
                data_rd_en <= '0';
                first_filler_word <= '0';
                crc_reset <= '1';
                crc_en <= '0';
            else
                case state is
                    
                    --=== Send IDLEs and check for available data ===--evt_word_cnt
                    when IDLE =>
                
                        first_filler_word <= '0';
                        word_idx <= 0;
                        crc_reset <= '1';
                        crc_en <= '0';
                        data <= ETH_IDLE;
                        charisk <= "01";
                        data_rd_en <= '0';
                        
                        if (data_empty_i = '0' and min_idle_cnt = 0) then
                            state <= PREAMBLE_SOF;
                        else
                            state <= IDLE;
                        end if;
                        
                        if (min_idle_cnt /= 0) then
                            min_idle_cnt <= min_idle_cnt - 1;
                        else
                            min_idle_cnt <= 0;
                        end if;
                        
                    --=== Send the preamble and start of frame sequence ===--        
                    when PREAMBLE_SOF =>
                        
                        first_filler_word <= '0';
                        min_idle_cnt <= 0;
                        crc_reset <= '0';
                        crc_en <= '0';
                        data <= ETH_PREAMBLE_SOF(word_idx);
                        
                        if (word_idx = 0) then
                            charisk <= "01";
                        else
                            charisk <= "00";
                        end if;
                        
                        if (word_idx = ETH_PREAMBLE_SOF'length - 1) then
                            word_idx <= 0;
                            if (skip_eth_header_i = '0') then
                                data_rd_en <= '0';
                                state <= HEADER;
                            else
                                data_rd_en <= '1';
                                state <= PAYLOAD;
                            end if;
                        else
                            word_idx <= word_idx + 1;
                            data_rd_en <= '0';
                            state <= PREAMBLE_SOF;
                        end if;

                    --=== Send the ethernet header (source MAC, destination MAC, and ethernet type) ===--        
                    when HEADER =>

                        first_filler_word <= '0';
                        min_idle_cnt <= 0;
                        crc_reset <= '0';
                        crc_en <= '1';
                        data <= ETH_HEADER(word_idx);
                        charisk <= "00";
                        
                        if (word_idx = ETH_HEADER'length - 1) then
                            word_idx <= 0;
                            data_rd_en <= '1';
                            state <= PAYLOAD;
                        else
                            word_idx <= word_idx + 1;
                            data_rd_en <= '0';
                            state <= HEADER;
                        end if;                        
                    
                    --=== Send the ethernet header (source MAC, destination MAC, and ethernet type) ===--        
                    when PAYLOAD =>

                        data <= data_i;
                        charisk <= "00";
                        word_idx <= word_idx + 1;
                        first_filler_word <= '1';
                        crc_reset <= '0';
                        crc_en <= '1';

                        -- end of packet (either due to end of event detection, empty fifo, or packet size limit)
                        if (eoe = '1') or (last_valid_word_i = '1') or (word_idx = g_MAX_PAYLOAD_WORDS - 1) then
                            data_rd_en <= '0';
                            if (word_idx < g_MIN_PAYLOAD_WORDS - 1) then
                                state <= FILLER;
                            else
                                state <= PACKET_CNT;
                            end if;
                            
                        else
                            data_rd_en <= '1';
                            state <= PAYLOAD;
                        end if;

                        if (word_idx < g_SMALL_EVT_MAX_WORDS) then
                            min_idle_cnt <= g_NUM_IDLES_SMALL_EVT;
                        else
                            min_idle_cnt <= g_NUM_IDLES_BIG_EVT;
                        end if;

                    --=== Send the filler words to satisfy the minimum packet length requirement (first word contains an 8bit valid word counter) ===--        
                    when FILLER =>
                        
                        charisk <= "00";
                        word_idx <= word_idx + 1;
                        first_filler_word <= '0';
                        min_idle_cnt <= min_idle_cnt;
                        data_rd_en <= '0';
                        crc_reset <= '0';
                        crc_en <= '1';
                                               
                        if (first_filler_word = '1') then
                            data <= x"ff" & std_logic_vector(to_unsigned(word_idx, 8));
                        else
                            data <= x"ffff";
                        end if;
                                   
                        if (word_idx < g_MIN_PAYLOAD_WORDS - 1) then
                            state <= FILLER;
                        else
                            state <= PACKET_CNT;
                        end if;

                    --=== Send the packet counter ===--        
                    when PACKET_CNT =>
                        
                        data <= std_logic_vector(packet_idx);
                        charisk <= "00";
                        word_idx <= 0;
                        first_filler_word <= '0';
                        min_idle_cnt <= min_idle_cnt;
                        crc_reset <= '0';
                        crc_en <= '1';
                        data_rd_en <= '0';
                        state <= CRC;

                    --=== Send the CRC ===--        
                    when CRC =>

                        charisk <= "00";
                        first_filler_word <= '0';
                        min_idle_cnt <= min_idle_cnt;
                        crc_reset <= '0';
                        crc_en <= '0';
                        data_rd_en <= '0';

                        if (word_idx = 0) then
                            data <= crc_current(15 downto 0);
                            word_idx <= 1;
                            state <= CRC;
                        else
                            data <= crc_reg(31 downto 16);
                            word_idx <= 0;
                            state <= EOF;
                        end if;

                    --=== Send the EOF ===--        
                    when EOF =>

                        first_filler_word <= '0';
                        min_idle_cnt <= min_idle_cnt;
                        crc_reset <= '0';
                        crc_en <= '0';
                        data_rd_en <= '0';

                        if (word_idx = 0) then
                            charisk <= "11";
                            data <= ETH_EOF(0);
                            word_idx <= 1;
                            state <= EOF;
                        else
                            charisk <= "01";
                            data <= ETH_EOF(1);
                            word_idx <= 0;
                            state <= IDLE;
                        end if;
                                            
                    --=== For completeness ===--        
                    when others =>
                        state <= IDLE;
                        word_idx <= 0;
                        min_idle_cnt <= 0;
                        data <= ETH_IDLE;
                        charisk <= "01";
                        data_rd_en <= '0';
                        first_filler_word <= '0';
                        crc_reset <= '1';
                        crc_en <= '0';

                end case;
            end if;
        end if;
    end process;

    -- packet counter
    process(gbe_clk_i)
    begin
        if (rising_edge(gbe_clk_i)) then
            if (reset_i = '1') then
                packet_idx <= (others => '0');
            else
                if state = EOF then
                    packet_idx <= packet_idx + 1;
                else
                    packet_idx <= packet_idx;
                end if;
            end if;
        end if;
    end process;

    -- end of event detection and word count
    
    eoe <= '1' when (eoe_detected = '1') and (eoe_countdown = "000") else '0';
    
    process(gbe_clk_i)
    begin
        if (rising_edge(gbe_clk_i)) then
            if (reset_i = '1') then
                word64 <= (others => '0');
                evt_word_cnt <= (others => '0');
                eoe_detected <= '0';
                eoe_countdown <= (others => '0');     
                err_evt_too_big <= '0';  
                err_eoe_not_found <= '0';                          
            else

                if (state = PAYLOAD) then
                    word64 <= data_i & word64(63 downto 16);
                    
                    if (word64 = DDU_EOE_WORD64) then
                        eoe_countdown <= "111";
                        eoe_detected <= '1';
                    elsif (eoe_countdown = "000") then
                        eoe_detected <= '0';
                        eoe_countdown <= (others => '0');
                    else
                        eoe_detected <= '1';
                        eoe_countdown <= eoe_countdown - 1;
                    end if;
                    
                    if (eoe = '1') then
                        evt_word_cnt <= (others => '0');
                    else
                        evt_word_cnt <= evt_word_cnt + 1;
                    end if;
                    
                    if (evt_word_cnt > to_unsigned(g_MAX_EVT_WORDS, 16)) then
                        err_evt_too_big <= '1';
                    else
                        err_evt_too_big <= err_evt_too_big;
                    end if;
                    
                    if (eoe = '0') and (last_valid_word_i = '1') then
                        err_eoe_not_found <= '1';
                    else
                        err_eoe_not_found <= err_eoe_not_found;
                    end if;
                    
                end if;

            end if;
        end if;
    end process;    
    
    -- word rate
    
    not_idle <= '0' when state = IDLE else '1';
    
    i_word_rate : entity work.rate_counter
        generic map(
            g_CLK_FREQUENCY => x"03b9aca0", -- 62.5MHz
            g_COUNTER_WIDTH => 32
        )
        port map(
            clk_i   => gbe_clk_i,
            reset_i => reset_i,
            en_i    => not_idle,
            rate_o  => word_rate_o
        );
    
    -- crc
    
    i_crc : entity work.crc32_gbe
        port map(
            data_in     => data,
            crc_en      => crc_en,
            rst         => crc_reset,
            clk         => gbe_clk_i,
            crc_reg     => crc_reg,
            crc_current => crc_current
        );
    
end gbe_tx_driver_arch;
