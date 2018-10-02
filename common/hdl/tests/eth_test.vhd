------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company: TAMU
-- Engineer: Evaldas Juska (evaldas.juska@cern.ch, evka85@gmail.com)
-- 
-- Create Date:    01:33:00 2018-09-28
-- Module Name:    ETH_TEST
-- Description:    This module is used to send user generated data out of the 1.25Gb/s GbE port 
------------------------------------------------------------------------------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.csc_pkg.all;
use work.gth_pkg.all;

entity eth_test is
    port(
        -- reset
        reset_i                 : in  std_logic;
        
        -- GbE link
        gbe_clk_i               : in  std_logic;
        gbe_tx_data_o           : out t_gt_8b10b_tx_data;
        
        -- control
        user_data_clk_i         : in  std_logic;
        user_data_i             : in  std_logic_vector(15 downto 0);
        user_data_charisk_i     : in  std_logic_vector(1 downto 0);
        user_data_en_i          : in  std_logic;
        send_en_i               : in  std_logic;
        
        -- status
        busy_o                  : out std_logic;
        empty_o                 : out std_logic;
        
        -- manual readback of the fifo
        manual_reading_enabled_i: in  std_logic;
        manual_read_en_i        : in  std_logic;
        manual_read_data_o      : out std_logic_vector(17 downto 0);
        manual_read_valid_o     : out std_logic

    );
end eth_test;

architecture eth_test_arch of eth_test is

    component eth_test_fifo
        port(
            rst    : in  std_logic;
            wr_clk : in  std_logic;
            rd_clk : in  std_logic;
            din    : in  std_logic_vector(17 downto 0);
            wr_en  : in  std_logic;
            rd_en  : in  std_logic;
            dout   : out std_logic_vector(17 DOWNTO 0);
            full   : out std_logic;
            empty  : out std_logic;
            valid  : out std_logic
        );
    end component;

    constant ETH_IDLE           : std_logic_vector(15 downto 0) := x"50BC";

    signal fifo_dout            : std_logic_vector(17 downto 0);
    signal fifo_valid           : std_logic;
    signal fifo_rd_en           : std_logic;
    signal fifo_empty           : std_logic;

    signal start_ext            : std_logic;
    signal start_sync           : std_logic;
    
    signal manual_rd_en         : std_logic := '0';

begin

    gbe_tx_data_o.txchardispmode <= (others => '0');
    gbe_tx_data_o.txchardispval <= (others => '0');
    busy_o <= fifo_rd_en;
    empty_o <= fifo_empty;
    manual_read_data_o <= fifo_dout;    

    process (gbe_clk_i)
    begin
        if (rising_edge(gbe_clk_i)) then
            if (fifo_valid = '1') then
                gbe_tx_data_o.txdata <= fifo_dout(15 downto 0);
                gbe_tx_data_o.txcharisk <= fifo_dout(17 downto 16);
            else
                gbe_tx_data_o.txdata <= ETH_IDLE;
                gbe_tx_data_o.txcharisk <= "01";
            end if;
        end if;
    end process;

    i_start_ext : entity work.pulse_extend
        generic map(
            DELAY_CNT_LENGTH => 2
        )
        port map(
            clk_i          => user_data_clk_i,
            rst_i          => reset_i,
            pulse_length_i => "11",
            pulse_i        => send_en_i,
            pulse_o        => start_ext
        );

    i_start_sync : entity work.synchronizer
        generic map(
            N_STAGES => 3
        )
        port map(
            async_i => start_ext,
            clk_i   => gbe_clk_i,
            sync_o  => start_sync
        );

    process (gbe_clk_i)
    begin
        if (rising_edge(gbe_clk_i)) then
            if (reset_i = '1') then
                fifo_rd_en <= '0';
            else
                if (start_sync = '1') then
                    fifo_rd_en <= '1';
                elsif (fifo_empty = '1') then
                    fifo_rd_en <= '0';
                else
                    fifo_rd_en <= fifo_rd_en;
                end if;
            end if;
        end if;
    end process;

    -- transfer between the ipbus clock and the gbe clock for the manual read signals

    i_manual_read_en_cross : entity work.cross_domain_pulse
        port map(
            reset_i   => reset_i,
            in_clk_i  => user_data_clk_i,
            pulse_i   => manual_read_en_i,
            out_clk_i => gbe_clk_i,
            pulse_o   => manual_rd_en,
            busy_o    => open
        );

    i_manual_read_valid_cross : entity work.cross_domain_pulse
        port map(
            reset_i   => reset_i,
            in_clk_i  => gbe_clk_i,
            pulse_i   => fifo_valid,
            out_clk_i => user_data_clk_i,
            pulse_o   => manual_read_valid_o,
            busy_o    => open
        );

    -- fifo

    i_eth_fifo : component eth_test_fifo
        port map(
            rst    => reset_i,
            wr_clk => user_data_clk_i,
            rd_clk => gbe_clk_i,
            din    => user_data_charisk_i & user_data_i,
            wr_en  => user_data_en_i,
            rd_en  => fifo_rd_en or (manual_reading_enabled_i and manual_rd_en),
            dout   => fifo_dout,
            full   => open,
            empty  => fifo_empty,
            valid  => fifo_valid
        );

end eth_test_arch;
