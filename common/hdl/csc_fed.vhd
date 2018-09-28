------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company: TAMU
-- Engineer: Evaldas Juska (evaldas.juska@cern.ch, evka85@gmail.com)
-- 
-- Create Date:    23:45:21 2016-11-23
-- Module Name:    CSC_FED 
-- Description:    This is the top module of all the common CSC FED logic. It is board-agnostic and can be used in different FPGA / board designs 
------------------------------------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;

use work.gth_pkg.all;
use work.csc_pkg.all;
use work.ipb_addr_decode.all;
use work.ipbus.all;
use work.ttc_pkg.all;

entity csc_fed is
    generic(
        g_BOARD_TYPE         : std_logic_vector(3 downto 0) := x"1"; -- this is not used except for putting it in a register for the user to see
        g_NUM_OF_DMBs        : integer;
        g_NUM_IPB_SLAVES     : integer;
        g_DAQLINK_CLK_FREQ   : integer
    );
    port(
        -- Resets
        reset_i                 : in   std_logic;
        reset_pwrup_o           : out  std_logic;

        -- TTC
        clk_40_ttc_p_i          : in  std_logic;      -- TTC backplane clock signals
        clk_40_ttc_n_i          : in  std_logic;
        ttc_data_p_i            : in  std_logic;      -- TTC data backplane signals
        ttc_data_n_i            : in  std_logic;
        ttc_clocks_o            : out t_ttc_clks;
        ttc_status_o            : out t_ttc_status;
        
        -- DMB links
        csc_dmb_rx_usrclk_arr_i : in  std_logic_vector(g_NUM_OF_DMBs - 1 downto 0);
        csc_dmb_rx_data_arr_i   : in  t_gt_8b10b_rx_data_arr(g_NUM_OF_DMBs - 1 downto 0);
        csc_dmb_rx_status_arr_i : in  t_gth_rx_status_arr(g_NUM_OF_DMBs - 1 downto 0);

        -- Spy link
        csc_spy_usrclk_i        : in  std_logic;
        csc_spy_rx_data_i       : in  t_gt_8b10b_rx_data;
        csc_spy_tx_data_o       : out t_gt_8b10b_tx_data;                
        csc_spy_rx_status_i     : in  t_gth_rx_status;

        -- IPbus
        ipb_reset_i             : in  std_logic;
        ipb_clk_i               : in  std_logic;
        ipb_miso_arr_o          : out ipb_rbus_array(g_NUM_IPB_SLAVES - 1 downto 0);
        ipb_mosi_arr_i          : in  ipb_wbus_array(g_NUM_IPB_SLAVES - 1 downto 0);
        
        -- LEDs
        led_l1a_o               : out std_logic;
        led_tts_ready_o         : out std_logic;
        
        -- DAQLink
        daqlink_clk_i           : in  std_logic;
        daqlink_clk_locked_i    : in  std_logic;
        daq_to_daqlink_o        : out t_daq_to_daqlink;
        daqlink_to_daq_i        : in  t_daqlink_to_daq;
        
        -- Board serial number
        board_id_i              : in std_logic_vector(15 downto 0) -- this gets embedded in the daqlink header, though probably not used anywhere :)
        
    );
end csc_fed;

architecture csc_fed_arch of csc_fed is

    constant POWER_UP_RESET_TIME : std_logic_vector(31 downto 0) := x"02625a00"; -- 40_000_000 clock cycles (1s) - way too long of course, but fine -- this is only used at powerup (FED doesn't care about hard resets), it's not like someone will want to start taking data sooner than that :) 

    --================================--
    -- Signals
    --================================--

    --== General ==--
    signal reset            : std_logic;
    signal reset_pwrup      : std_logic;
    signal ipb_reset        : std_logic;
    signal pwrup_countdown  : std_logic_vector(31 downto 0) := POWER_UP_RESET_TIME;

    --== TTC signals ==--
    signal ttc_clocks       : t_ttc_clks;
    signal ttc_cmd          : t_ttc_cmds;
    signal ttc_counters     : t_ttc_daq_cntrs;
    signal ttc_status       : t_ttc_status;

    --== IPbus ==--
    signal ipb_miso_arr     : ipb_rbus_array(g_NUM_IPB_SLAVES - 1 downto 0) := (others => (ipb_rdata => (others => '0'), ipb_ack => '0', ipb_err => '0'));

begin

    --================================--
    -- I/O wiring  
    --================================--
    
    reset_pwrup_o <= reset_pwrup;
    reset <= reset_i or reset_pwrup; -- TODO: Add a global reset from IPbus
    ipb_reset <= ipb_reset_i or reset_pwrup;
    ttc_clocks_o <= ttc_clocks; 
    ipb_miso_arr_o <= ipb_miso_arr;
    led_tts_ready_o <= '1';

    --================================--
    -- Power-on reset  
    --================================--
    
    process(ttc_clocks.clk_40) -- NOTE: using TTC clock, nothing will work if there's no TTC clock
    begin
        if (rising_edge(ttc_clocks.clk_40)) then
            if (reset_i = '1') then
                pwrup_countdown <= POWER_UP_RESET_TIME;
            else
                if (unsigned(pwrup_countdown) /= x"00000000") then
                  reset_pwrup <= '1';
                  pwrup_countdown <= std_logic_vector(unsigned(pwrup_countdown) - 1);
                else
                  reset_pwrup <= '0';
                end if;
            end if;
        end if;
    end process;    
    
    --================================--
    -- TTC  
    --================================--

    i_ttc : entity work.ttc
        port map(
            reset_i         => reset,
            clk_40_ttc_p_i  => clk_40_ttc_p_i,
            clk_40_ttc_n_i  => clk_40_ttc_n_i,
            ttc_data_p_i    => ttc_data_p_i,
            ttc_data_n_i    => ttc_data_n_i,
            ttc_clks_o      => ttc_clocks,
            ttc_cmds_o      => ttc_cmd,
            ttc_daq_cntrs_o => ttc_counters,
            ttc_status_o    => ttc_status,
            l1a_led_o       => led_l1a_o,
            ipb_reset_i     => ipb_reset,
            ipb_clk_i       => ipb_clk_i,
            ipb_mosi_i      => ipb_mosi_arr_i(C_IPB_SLV.ttc),
            ipb_miso_o      => ipb_miso_arr(C_IPB_SLV.ttc)
        );

    ttc_status_o <= ttc_status;
    
    --================================--
    -- DAQ  
    --================================--

    i_daq : entity work.daq
        generic map(
            g_NUM_OF_DMBs => g_NUM_OF_DMBs,
            g_DAQ_CLK_FREQ => g_DAQLINK_CLK_FREQ
        )
        port map(
            reset_i          => reset,
            daq_clk_i        => daqlink_clk_i,
            daq_clk_locked_i => daqlink_clk_locked_i,
            daq_to_daqlink_o => daq_to_daqlink_o,
            daqlink_to_daq_i => daqlink_to_daq_i,
            ttc_clks_i       => ttc_clocks,
            ttc_cmds_i       => ttc_cmd,
            ttc_daq_cntrs_i  => ttc_counters,
            ttc_status_i     => ttc_status,
            input_clk_arr_i  => csc_dmb_rx_usrclk_arr_i,
            input_link_arr_i => csc_dmb_rx_data_arr_i,
            ipb_reset_i      => ipb_reset_i,
            ipb_clk_i        => ipb_clk_i,
            ipb_mosi_i       => ipb_mosi_arr_i(C_IPB_SLV.daq),
            ipb_miso_o       => ipb_miso_arr(C_IPB_SLV.daq),
            board_sn_i       => board_id_i,
            tts_ready_o      => led_tts_ready_o
        );    

    --================================--
    -- System registers
    --================================--

    i_system : entity work.system_regs
        generic map(
            g_NUM_OF_DMBs => g_NUM_OF_DMBs,
            g_BOARD_TYPE  => g_BOARD_TYPE
        )
        port map(
            reset_i     => reset,
            ttc_clks_i  => ttc_clocks,
            
            board_id_o  => open,
            
            -- IPbus
            ipb_reset_i => ipb_reset_i,
            ipb_clk_i   => ipb_clk_i,
            ipb_mosi_i  => ipb_mosi_arr_i(C_IPB_SLV.system),
            ipb_miso_o  => ipb_miso_arr(C_IPB_SLV.system)
        );

    --================================--
    -- Link status monitor
    --================================--

    i_link_monitor : entity work.link_monitor
        generic map(
            g_NUM_OF_DMBs => g_NUM_OF_DMBs
        )
        port map(
            reset_i                 => reset,
            clk_i                   => csc_dmb_rx_usrclk_arr_i(0),

            -- DMB links
            csc_dmb_rx_usrclk_arr_i => csc_dmb_rx_usrclk_arr_i,
            csc_dmb_rx_data_arr_i   => csc_dmb_rx_data_arr_i,
            csc_dmb_rx_status_arr_i => csc_dmb_rx_status_arr_i,
    
            -- Spy link
            csc_spy_usrclk_i        => csc_spy_usrclk_i,
            csc_spy_rx_data_i       => csc_spy_rx_data_i,
            csc_spy_rx_status_i     => csc_spy_rx_status_i,
                
            -- IPbus
            ipb_reset_i            => ipb_reset_i,
            ipb_clk_i              => ipb_clk_i,
            ipb_miso_o             => ipb_miso_arr(C_IPB_SLV.links),
            ipb_mosi_i             => ipb_mosi_arr_i(C_IPB_SLV.links)
        );

    --================================--
    -- Tests
    --================================--

    i_csc_tests : entity work.csc_tests
        port map(
            reset_i           => reset,
            ttc_clk_i         => ttc_clocks,
            ttc_cmds_i        => ttc_cmd,
            gbe_clk_i         => csc_spy_usrclk_i,
            gbe_tx_data_o     => csc_spy_tx_data_o,
            gbe_test_enable_o => open,
            ipb_reset_i       => ipb_reset_i,
            ipb_clk_i         => ipb_clk_i,
            ipb_miso_o        => ipb_miso_arr(C_IPB_SLV.tests),
            ipb_mosi_i        => ipb_mosi_arr_i(C_IPB_SLV.tests)
        );

end csc_fed_arch;
