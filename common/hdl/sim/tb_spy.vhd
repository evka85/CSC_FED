------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company: TAMU
-- Engineer: Evaldas Juska (evaldas.juska@cern.ch, evka85@gmail.com)
-- 
-- Create Date:    02:17:00 2018-10-05
-- Module Name:    TB_SPY
-- Description:    This is a test bench for gbe_tx_driver module 
------------------------------------------------------------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.gth_pkg.all;
use work.csc_pkg.all;

entity tb_spy is
end tb_spy;

architecture Behavioral of tb_spy is

    constant CLK_PERIOD : time := 10 ns;
    
    -- sample data

    constant PREAMBLE_SOF : t_std16_array(0 to 3)  := (x"55FB", x"5555", x"5555", x"D555");
    constant PAYLOAD      : t_std16_array(0 to 23) := (x"4770", x"7313", x"04ce", x"5000",
                                                       x"0000", x"8000", x"0001", x"8000",
                                                       x"0080", x"0000", x"3031", x"7fff",
                                                       x"8000", x"8000", x"ffff", x"8000",
                                                       x"0000", x"0000", x"0000", x"2010",
                                                       x"0080", x"3a6d", x"0006", x"a000");
    constant PADDING      : t_std16_array(0 to 7)  := (x"ff30", x"ffff", x"ffff", x"ffff",
                                                       x"ffff", x"ffff", x"ffff", x"ffff");
    constant PACKET_CNT   : std_logic_vector(15 downto 0) := x"04cf";
    constant CRC          : t_std16_array(0 to 1)  := (x"30ba", x"e514");
    constant EOF          : t_std16_array(0 to 1)  := (x"3f7fd", x"1c5bc");
    
    -- signals
    signal reset        : std_logic;
    signal clk          : std_logic;
    
    signal spy_data     : t_gt_8b10b_tx_data;
    signal fifo_empty   : std_logic := '1'; 
    signal fifo_aempty  : std_logic := '0'; 
    signal fifo_dout    : std_logic_vector(15 downto 0) := PAYLOAD(0); 
    signal fifo_rd_en   : std_logic; 
    signal payload_idx  : integer range 0 to PAYLOAD'length := 0;

begin

    i_spy_ethernet_driver : entity work.gbe_tx_driver
        generic map(
            g_MAX_PAYLOAD_WORDS   => 3976,
            g_MIN_PAYLOAD_WORDS   => 32,
            g_MAX_EVT_WORDS       => 50000,
            g_NUM_IDLES_SMALL_EVT => 2,
            g_NUM_IDLES_BIG_EVT   => 7,
            g_SMALL_EVT_MAX_WORDS => 24
        )
        port map(
            reset_i             => reset,
            gbe_clk_i           => clk,
            gbe_tx_data_o       => spy_data,
            skip_eth_header_i   => '1',
            data_empty_i        => fifo_empty,
            data_i              => fifo_dout,
            data_rd_en          => fifo_rd_en,
            last_valid_word_i   => fifo_aempty,
            err_event_too_big_o => open,
            err_eoe_not_found_o => open,
            word_rate_o         => open
        );

    -- Clock process
    CLK_process : process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process;

    fifo_dout <= PAYLOAD(payload_idx);

    process(clk)
    begin
        if (rising_edge(clk)) then
            if fifo_rd_en = '1' and payload_idx < PAYLOAD'length then
                payload_idx <= payload_idx + 1; 
            end if;
            if payload_idx = PAYLOAD'length - 2 then
                fifo_aempty <= '1';
            else
                fifo_aempty <= '0';
            end if;
        end if;
    end process;

    -- Stimulus process
    stim_proc : process
    begin
        -- hold reset state for 100 ns.
        reset <= '1';
        fifo_empty <= '1';
        wait for 100 ns;
        reset <= '0';
        wait for CLK_period * 10;
        fifo_empty <= '0';
        wait for CLK_period * 100;
        wait;
    end process;
  
end Behavioral;
