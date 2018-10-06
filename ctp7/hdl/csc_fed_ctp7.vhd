------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company: TAMU
-- Engineer: Evaldas Juska (evaldas.juska@cern.ch, evka85@gmail.com)
-- 
-- Create Date:    21:00:00 2016-11-17
-- Module Name:    CSC_FED_CTP7 
-- Description:    This is the top module of CSC FED firmware for CTP7 Virtex7 FPGA (board designed by University of Wisconsin)
------------------------------------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

use work.gth_pkg.all;

use work.ctp7_utils_pkg.all;
use work.ttc_pkg.all;
use work.system_package.all;
use work.csc_pkg.all;
use work.ipbus.all;
use work.axi_pkg.all;
use work.ipb_addr_decode.all;
use work.csc_board_config_package.all;

--============================================================================
--                                                          Entity declaration
--============================================================================
entity csc_fed_ctp7 is
    generic(
        C_DATE_CODE      : std_logic_vector(31 downto 0) := x"00000000";
        C_GITHASH_CODE   : std_logic_vector(31 downto 0) := x"00000000";
        C_GIT_REPO_DIRTY : std_logic                     := '0'
    );
    port(
        clk_200_diff_in_clk_p          : in  std_logic;
        clk_200_diff_in_clk_n          : in  std_logic;

        clk_40_ttc_p_i                 : in  std_logic; -- TTC backplane clock signals
        clk_40_ttc_n_i                 : in  std_logic;
        ttc_data_p_i                   : in  std_logic;
        ttc_data_n_i                   : in  std_logic;

        LEDs                           : out std_logic_vector(1 downto 0);

        axi_c2c_v7_to_zynq_data        : out std_logic_vector(14 downto 0);
        axi_c2c_v7_to_zynq_clk         : out std_logic;
        axi_c2c_zynq_to_v7_clk         : in  std_logic;
        axi_c2c_zynq_to_v7_data        : in  std_logic_vector(14 downto 0);
        axi_c2c_v7_to_zynq_link_status : out std_logic;
        axi_c2c_zynq_to_v7_reset       : in  std_logic;

        refclk_F_0_p_i                 : in  std_logic_vector(3 downto 0);
        refclk_F_0_n_i                 : in  std_logic_vector(3 downto 0);
        refclk_F_1_p_i                 : in  std_logic_vector(3 downto 0);
        refclk_F_1_n_i                 : in  std_logic_vector(3 downto 0);

        refclk_B_0_p_i                 : in  std_logic_vector(3 downto 1);
        refclk_B_0_n_i                 : in  std_logic_vector(3 downto 1);
        refclk_B_1_p_i                 : in  std_logic_vector(3 downto 1);
        refclk_B_1_n_i                 : in  std_logic_vector(3 downto 1);
        
        -- AMC13 GTH
        amc13_gth_refclk_p             : in  std_logic;
        amc13_gth_refclk_n             : in  std_logic;
        amc_13_gth_rx_n                : in  std_logic;
        amc_13_gth_rx_p                : in  std_logic;
        amc13_gth_tx_n                 : out std_logic;
        amc13_gth_tx_p                 : out std_logic
        
    );
end csc_fed_ctp7;

--============================================================================
--                                                        Architecture section
--============================================================================
architecture csc_fed_ctp7_arch of csc_fed_ctp7 is

    --============================================================================
    --                                                         Signal declarations
    --============================================================================

    -------------------------- System clocks ---------------------------------
    signal clk_50       : std_logic;
    signal clk_200      : std_logic;

    -------------------------- AXI-IPbus bridge ---------------------------------
    --AXI
    signal axi_clk      : std_logic;
    signal axi_reset    : std_logic;
    signal ipb_axi_mosi : t_axi_lite_mosi;
    signal ipb_axi_miso : t_axi_lite_miso;
    --IPbus
    signal ipb_reset    : std_logic;
    signal ipb_clk      : std_logic;
    signal ipb_miso_arr : ipb_rbus_array(C_NUM_IPB_SLAVES - 1 downto 0) := (others => (ipb_rdata => (others => '0'), ipb_ack => '0', ipb_err => '0'));
    signal ipb_mosi_arr : ipb_wbus_array(C_NUM_IPB_SLAVES - 1 downto 0);

    -------------------------- TTC ---------------------------------
    signal ttc_clocks   : t_ttc_clks;
    signal ttc_status   : t_ttc_status;

    -------------------------- GTH ---------------------------------
    signal clk_gth_tx_arr       : std_logic_vector(g_NUM_OF_GTH_GTs - 1 downto 0);
    signal clk_gth_rx_arr       : std_logic_vector(g_NUM_OF_GTH_GTs - 1 downto 0);
    signal gth_tx_data_arr      : t_gt_8b10b_tx_data_arr(g_NUM_OF_GTH_GTs - 1 downto 0);
    signal gth_rx_data_arr      : t_gt_8b10b_rx_data_arr(g_NUM_OF_GTH_GTs - 1 downto 0);
    signal gth_rxreset_arr      : std_logic_vector(g_NUM_OF_GTH_GTs - 1 downto 0);
    signal gth_txreset_arr      : std_logic_vector(g_NUM_OF_GTH_GTs - 1 downto 0);
    signal gth_tx_status_arr    : t_gth_tx_status_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    signal gth_rx_status_arr    : t_gth_rx_status_arr(g_NUM_OF_GTH_GTs-1 downto 0);
    
    -------------------- GTHs mapped to CSC links ---------------------------------
    
    -- DMB links
    signal csc_dmb_rx_usrclk_arr        : std_logic_vector(CFG_NUM_DMBS - 1 downto 0);
    signal csc_dmb_rx_data_arr          : t_gt_8b10b_rx_data_arr(CFG_NUM_DMBS - 1 downto 0);
    signal csc_dmb_rx_status_arr        : t_gth_rx_status_arr(CFG_NUM_DMBS - 1 downto 0);
    
    -- Spy readout link
    signal csc_spy_usrclk               : std_logic;
    signal csc_spy_rx_data              : t_gt_8b10b_rx_data;
    signal csc_spy_tx_data              : t_gt_8b10b_tx_data;
    signal csc_spy_rx_status            : t_gth_rx_status;

    -------------------- AMC13 DAQLink ---------------------------------
    signal daq_to_daqlink       : t_daq_to_daqlink;
    signal daqlink_to_daq       : t_daqlink_to_daq;

--============================================================================
--                                                          Architecture begin
--============================================================================

begin

    -------------------------- SYSTEM ---------------------------------

    i_system : entity work.system
        --    generic map(
        --      C_DATE_CODE      => C_DATE_CODE,
        --      C_GITHASH_CODE   => C_GITHASH_CODE,
        --      C_GIT_REPO_DIRTY => C_GIT_REPO_DIRTY
        --    )
        port map(
            clk_200_diff_in_clk_p          => clk_200_diff_in_clk_p,
            clk_200_diff_in_clk_n          => clk_200_diff_in_clk_n,
            
            axi_c2c_v7_to_zynq_data        => axi_c2c_v7_to_zynq_data,
            axi_c2c_v7_to_zynq_clk         => axi_c2c_v7_to_zynq_clk,
            axi_c2c_zynq_to_v7_clk         => axi_c2c_zynq_to_v7_clk,
            axi_c2c_zynq_to_v7_data        => axi_c2c_zynq_to_v7_data,
            axi_c2c_v7_to_zynq_link_status => axi_c2c_v7_to_zynq_link_status,
            axi_c2c_zynq_to_v7_reset       => axi_c2c_zynq_to_v7_reset,
            
            refclk_F_0_p_i                 => refclk_F_0_p_i,
            refclk_F_0_n_i                 => refclk_F_0_n_i,
            refclk_F_1_p_i                 => refclk_F_1_p_i,
            refclk_F_1_n_i                 => refclk_F_1_n_i,
            refclk_B_0_p_i                 => refclk_B_0_p_i,
            refclk_B_0_n_i                 => refclk_B_0_n_i,
            refclk_B_1_p_i                 => refclk_B_1_p_i,
            refclk_B_1_n_i                 => refclk_B_1_n_i,

            clk_50_o                       => clk_50,
            clk_200_o                      => clk_200,
            
            axi_clk_o                      => axi_clk,
            axi_reset_o                    => axi_reset,
            ipb_axi_mosi_o                 => ipb_axi_mosi,
            ipb_axi_miso_i                 => ipb_axi_miso,
            
            ttc_clks_i                     => ttc_clocks,
            ttc_status_i                   => ttc_status,
            
            clk_gth_tx_arr_o               => clk_gth_tx_arr,
            clk_gth_rx_arr_o               => clk_gth_rx_arr,
            
            gth_tx_data_arr_i              => gth_tx_data_arr,
            gth_rx_data_arr_o              => gth_rx_data_arr,
            
            gth_rxreset_arr_o              => gth_rxreset_arr,
            gth_txreset_arr_o              => gth_txreset_arr,

            gth_rx_status_arr_o            => gth_rx_status_arr,
            gth_tx_status_arr_o            => gth_tx_status_arr,

            amc13_gth_refclk_p             => amc13_gth_refclk_p,
            amc13_gth_refclk_n             => amc13_gth_refclk_n,
            amc_13_gth_rx_n                => amc_13_gth_rx_n,
            amc_13_gth_rx_p                => amc_13_gth_rx_p,
            amc13_gth_tx_n                 => amc13_gth_tx_n,
            amc13_gth_tx_p                 => amc13_gth_tx_p,
            
            daq_to_daqlink_i               => daq_to_daqlink,
            daqlink_to_daq_o               => daqlink_to_daq
        );

    -------------------------- IPBus ---------------------------------

    i_axi_ipbus_bridge : entity work.axi_ipbus_bridge
        generic map(
            C_NUM_IPB_SLAVES   => C_NUM_IPB_SLAVES,
            C_S_AXI_DATA_WIDTH => 32,
            C_S_AXI_ADDR_WIDTH => C_IPB_AXI_ADDR_WIDTH
        )
        port map(
            ipb_reset_o   => ipb_reset,
            ipb_clk_o     => ipb_clk,
            ipb_miso_i    => ipb_miso_arr,
            ipb_mosi_o    => ipb_mosi_arr,
            S_AXI_ACLK    => axi_clk,
            S_AXI_ARESETN => axi_reset,
            S_AXI_AWADDR  => ipb_axi_mosi.awaddr(C_IPB_AXI_ADDR_WIDTH - 1 downto 0),
            S_AXI_AWPROT  => ipb_axi_mosi.awprot,
            S_AXI_AWVALID => ipb_axi_mosi.awvalid,
            S_AXI_AWREADY => ipb_axi_miso.awready,
            S_AXI_WDATA   => ipb_axi_mosi.wdata,
            S_AXI_WSTRB   => ipb_axi_mosi.wstrb,
            S_AXI_WVALID  => ipb_axi_mosi.wvalid,
            S_AXI_WREADY  => ipb_axi_miso.wready,
            S_AXI_BRESP   => ipb_axi_miso.bresp,
            S_AXI_BVALID  => ipb_axi_miso.bvalid,
            S_AXI_BREADY  => ipb_axi_mosi.bready,
            S_AXI_ARADDR  => ipb_axi_mosi.araddr(C_IPB_AXI_ADDR_WIDTH - 1 downto 0),
            S_AXI_ARPROT  => ipb_axi_mosi.arprot,
            S_AXI_ARVALID => ipb_axi_mosi.arvalid,
            S_AXI_ARREADY => ipb_axi_miso.arready,
            S_AXI_RDATA   => ipb_axi_miso.rdata,
            S_AXI_RRESP   => ipb_axi_miso.rresp,
            S_AXI_RVALID  => ipb_axi_miso.rvalid,
            S_AXI_RREADY  => ipb_axi_mosi.rready
        );

    -------------------------- CSC logic ---------------------------------
    
    i_csc_fed : entity work.csc_fed
        generic map(
            g_BOARD_TYPE         => CFG_BOARD_TYPE,
            g_NUM_OF_DMBs        => CFG_NUM_DMBS,
            g_NUM_IPB_SLAVES     => C_NUM_IPB_SLAVES,
            g_DAQLINK_CLK_FREQ   => 50_000_000
        )
        port map(
        	-- Resets
            reset_i                 => or_reduce(gth_rxreset_arr) or or_reduce(gth_txreset_arr),
            reset_pwrup_o           => open,
            
            -- TTC
            clk_40_ttc_p_i          => clk_40_ttc_p_i,
            clk_40_ttc_n_i          => clk_40_ttc_n_i,
            ttc_data_p_i            => ttc_data_p_i,
            ttc_data_n_i            => ttc_data_n_i,
            ttc_clocks_o            => ttc_clocks,
            ttc_status_o            => ttc_status,
            
            -- DMB links
            csc_dmb_rx_usrclk_arr_i => csc_dmb_rx_usrclk_arr,
            csc_dmb_rx_data_arr_i   => csc_dmb_rx_data_arr,
            csc_dmb_rx_status_arr_i => csc_dmb_rx_status_arr,

            -- Spy link
            csc_spy_usrclk_i        => csc_spy_usrclk,
            csc_spy_rx_data_i       => csc_spy_rx_data,
            csc_spy_tx_data_o       => csc_spy_tx_data,
            csc_spy_rx_status_i     => csc_spy_rx_status,
            
            -- IPbus
            ipb_reset_i             => ipb_reset,
            ipb_clk_i               => ipb_clk,
            ipb_miso_arr_o          => ipb_miso_arr,
            ipb_mosi_arr_i          => ipb_mosi_arr,

            -- LEDs
            led_l1a_o               => LEDs(0),
            led_tts_ready_o         => LEDs(1),
            
            -- DAQLink
            daqlink_clk_i           => clk_50,
            daqlink_clk_locked_i    => '1',
            daq_to_daqlink_o        => daq_to_daqlink,
            daqlink_to_daq_i        => daqlink_to_daq
        );

    -- GTH mapping to CSC links (for now only single link DMBs are supported)
    g_csc_dmb_links : for i in 0 to CFG_NUM_DMBS - 1 generate

        csc_dmb_rx_usrclk_arr(i)    <= clk_gth_rx_arr(CFG_RX_FIBER_TO_GTH_MAP(CFG_DMB_CONFIG_ARR(i).rx_fibers(0)));
        csc_dmb_rx_data_arr(i)      <= gth_rx_data_arr(CFG_RX_FIBER_TO_GTH_MAP(CFG_DMB_CONFIG_ARR(i).rx_fibers(0)));
        csc_dmb_rx_status_arr(i)    <= gth_rx_status_arr(CFG_RX_FIBER_TO_GTH_MAP(CFG_DMB_CONFIG_ARR(i).rx_fibers(0)));
        
        -- send some dummy data on the TX of the same fiber -- that's only for test now, should be removed later (especially after starting to use MiniPODs) 
        gth_tx_data_arr(CFG_RX_FIBER_TO_GTH_MAP(CFG_DMB_CONFIG_ARR(i).rx_fibers(0))) <= (txdata => x"000050bc", txcharisk => x"1", txchardispmode => x"0", txchardispval => x"0");
        
    end generate; 

    -- spy link mapping
    g_csc_spy_link : if CFG_USE_SPY_LINK generate
        csc_spy_usrclk      <= clk_gth_tx_arr(CFG_TX_FIBER_TO_GTH_MAP(CFG_SPY_LINK));
        csc_spy_rx_data     <= gth_rx_data_arr(CFG_RX_FIBER_TO_GTH_MAP(CFG_SPY_LINK));
        csc_spy_rx_status   <= gth_rx_status_arr(CFG_RX_FIBER_TO_GTH_MAP(CFG_SPY_LINK));
        gth_tx_data_arr(CFG_TX_FIBER_TO_GTH_MAP(CFG_SPY_LINK)) <= csc_spy_tx_data;
    end generate;

    -- spy link mapping
    g_csc_fake_spy_link : if not CFG_USE_SPY_LINK generate
        csc_spy_usrclk      <= '0';
        csc_spy_rx_data     <= (rxdata => (others => '0'), rxbyteisaligned => '0', rxbyterealign => '0', rxcommadet => '0', rxdisperr => (others => '0'), rxnotintable => (others => '0'), rxchariscomma => (others => '0'), rxcharisk => (others => '0'));
        csc_spy_rx_status   <= (rxprbserr => '0', rxbufstatus => (others => '0'), rxclkcorcnt => (others => '0'), rxresetdone => '0', RXPMARESETDONE => '0', RXDLYSRESETDONE => '0', RXPHALIGNDONE => '0', RXSYNCDONE => '0', RXSYNCOUT => '0', rxdisperr => (others => '0'), rxnotintable => (others => '0'));
    end generate;

    -------------------------- DEBUG ---------------------------------

    i_dmb1_rx_ila_inst : entity work.gt_rx_link_ila_wrapper
        generic map (
            g_CNT_START_DELAY => 80_000_000
        )
        port map(
            clk_i           => csc_dmb_rx_usrclk_arr(1),
            kchar_i         => csc_dmb_rx_data_arr(1).rxcharisk(1 downto 0),
            comma_i         => csc_dmb_rx_data_arr(1).rxchariscomma(1 downto 0),
            not_in_table_i  => csc_dmb_rx_data_arr(1).rxnotintable(1 downto 0),
            disperr_i       => csc_dmb_rx_data_arr(1).rxdisperr(1 downto 0),
            data_i          => csc_dmb_rx_data_arr(1).rxdata(15 downto 0),
            bufstatus_i     => csc_dmb_rx_status_arr(1).rxbufstatus,
            clkcorrcnt_i    => csc_dmb_rx_status_arr(1).rxclkcorcnt
        );

    i_spy_rx_ila_inst : entity work.gt_rx_link_ila_wrapper
        generic map (
            g_CNT_START_DELAY => 80_000_000
        )
        port map(
            clk_i           => csc_spy_usrclk,
            kchar_i         => csc_spy_rx_data.rxcharisk(1 downto 0),
            comma_i         => csc_spy_rx_data.rxchariscomma(1 downto 0),
            not_in_table_i  => csc_spy_rx_data.rxnotintable(1 downto 0),
            disperr_i       => csc_spy_rx_data.rxdisperr(1 downto 0),
            data_i          => csc_spy_rx_data.rxdata(15 downto 0),
            bufstatus_i     => csc_spy_rx_status.rxbufstatus,
            clkcorrcnt_i    => csc_spy_rx_status.rxclkcorcnt
        );

    i_spy_tx_ila_inst : entity work.gt_tx_link_ila_wrapper
        port map(
            clk_i   => csc_spy_usrclk,
            kchar_i => csc_spy_tx_data.txcharisk(1 downto 0),
            data_i  => csc_spy_tx_data.txdata(15 downto 0)
        );

end csc_fed_ctp7_arch;

--============================================================================
--                                                            Architecture end
--============================================================================

