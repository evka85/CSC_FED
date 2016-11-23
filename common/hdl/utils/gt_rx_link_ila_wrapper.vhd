------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company: TAMU
-- Engineer: Evaldas Juska (evaldas.juska@cern.ch, evka85@gmail.com)
-- 
-- Create Date:    20:10:11 2016-05-02
-- Module Name:    A simple ILA wrapper for a GTH or GTX RX link 
-- Description:     
------------------------------------------------------------------------------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use work.csc_pkg.all;

entity gt_rx_link_ila_wrapper is
  generic (
      g_CNT_START_DELAY : integer  := 80_000_000 -- number of clk_i periods to wait before starting the counters
  );    
  port (      
      clk_i             : in std_logic;
      kchar_i           : in std_logic_vector(1 downto 0);
      comma_i           : in std_logic_vector(1 downto 0);
      not_in_table_i    : in std_logic_vector(1 downto 0);
      disperr_i         : in std_logic_vector(1 downto 0);
      data_i            : in std_logic_vector(15 downto 0);
      bufstatus_i       : in std_logic_vector(2 downto 0);
      clkcorrcnt_i      : in std_logic_vector(1 downto 0)
  );
end gt_rx_link_ila_wrapper;

architecture Behavioral of gt_rx_link_ila_wrapper is
    
    component gt_rx_link_ila is
        PORT(
            clk    : IN STD_LOGIC;
            probe0 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            probe1 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            probe2 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            probe3 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            probe4 : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
            probe5 : IN STD_LOGIC_VECTOR(2 DOWNTO 0); 
            probe6 : IN STD_LOGIC_VECTOR(1 DOWNTO 0); 
            probe7 : IN STD_LOGIC_VECTOR(15 DOWNTO 0); 
            probe8 : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            probe9 : IN STD_LOGIC_VECTOR(15 DOWNTO 0)            
        );
    end component gt_rx_link_ila;
    
    signal not_in_table_cnt     : std_logic_vector(15 downto 0);
    signal clk_corr_add_cnt     : std_logic_vector(15 downto 0);
    signal clk_corr_drop_cnt    : std_logic_vector(15 downto 0);
    
    signal cnt_reset            : std_logic := '1';
    signal cnt_reset_countdown  : integer range 0 to g_CNT_START_DELAY := g_CNT_START_DELAY;
    
begin

    cnt_reset <= '0' when cnt_reset_countdown = 0 else '1'; 

    process(clk_i)
    begin
        if (rising_edge(clk_i)) then
            if (cnt_reset_countdown /= 0) then
                cnt_reset_countdown <= cnt_reset_countdown - 1;
            end if;
        end if;
    end process;

    i_notintable_cnt : entity work.counter
        generic map(
            g_COUNTER_WIDTH  => 16,
            g_ALLOW_ROLLOVER => true
        )
        port map(
            ref_clk_i => clk_i,
            reset_i   => cnt_reset,
            en_i      => not_in_table_i(0) or not_in_table_i(1),
            count_o   => not_in_table_cnt
        );

    i_clk_corr_add_cnt : entity work.counter
        generic map(
            g_COUNTER_WIDTH  => 16,
            g_ALLOW_ROLLOVER => true
        )
        port map(
            ref_clk_i => clk_i,
            reset_i   => cnt_reset,
            en_i      => clkcorrcnt_i(0) and clkcorrcnt_i(1),
            count_o   => clk_corr_add_cnt
        );

    i_clk_corr_drop_cnt : entity work.counter
        generic map(
            g_COUNTER_WIDTH  => 16,
            g_ALLOW_ROLLOVER => true
        )
        port map(
            ref_clk_i => clk_i,
            reset_i   => cnt_reset,
            en_i      => clkcorrcnt_i(0) xor clkcorrcnt_i(1),
            count_o   => clk_corr_drop_cnt
        );

    i_gt_rx_link_ila : component gt_rx_link_ila
        port map(
            clk         => clk_i,
            probe0      => data_i,
            probe1      => kchar_i,
            probe2      => comma_i,
            probe3      => not_in_table_i,
            probe4      => disperr_i,
            probe5      => bufstatus_i,
            probe6      => clkcorrcnt_i,
            probe7      => not_in_table_cnt,
            probe8      => clk_corr_add_cnt,
            probe9      => clk_corr_drop_cnt
        );
        
end Behavioral;
