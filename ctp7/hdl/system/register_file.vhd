-------------------------------------------------------------------------------
--                                                                            
--       Unit Name: register_file                                            
--                                                                            
--     Description: 
--
--                                                                            
-------------------------------------------------------------------------------
--                                                                            
--           Notes:                                                           
--                                                                            
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library UNISIM;
use UNISIM.vcomponents.all;

library work;
use work.system_package.all;

use work.ctp7_utils_pkg.all;
use work.capture_playback_pkg.all;
use work.ttc_pkg.all;

--============================================================================
--                                                          Entity declaration
--============================================================================
entity register_file is
  generic (
    C_DATE_CODE      : std_logic_vector (31 downto 0) := x"00000000";
    C_GITHASH_CODE   : std_logic_vector (31 downto 0) := x"00000000";
    C_GIT_REPO_DIRTY : std_logic                      := '0'
    );
  port (

    clk240_i : in std_logic;
    clk40_i  : in std_logic;

    ttc_mmcm_ctrl_o  : out t_ttc_mmcm_ctrl;
    ttc_mmcm_stat_i  : in  t_ttc_mmcm_stat;
    ttc_ctrl_o       : out t_ttc_ctrl;
    ttc_stat_i       : in  t_ttc_stat;
    ttc_diag_cntrs_i : in  t_ttc_diag_cntrs;
    ttc_daq_cntrs_i  : in  t_ttc_daq_cntrs;

    rx_capture_ctrl_o   : out t_capture_ctrl_arr(11 downto 0);
    rx_capture_status_i : in  t_capture_status_arr(11 downto 0);

    BRAM_CTRL_REG_FILE_en   : in  std_logic;
    BRAM_CTRL_REG_FILE_dout : out std_logic_vector (31 downto 0);
    BRAM_CTRL_REG_FILE_din  : in  std_logic_vector (31 downto 0);
    BRAM_CTRL_REG_FILE_we   : in  std_logic_vector (3 downto 0);
    BRAM_CTRL_REG_FILE_addr : in  std_logic_vector (16 downto 0);
    BRAM_CTRL_REG_FILE_clk  : in  std_logic;
    BRAM_CTRL_REG_FILE_rst  : in  std_logic
    );
end register_file;

--============================================================================
--                                                        Architecture section
--============================================================================
architecture register_file_arch of register_file is

--============================================================================
--                                                       Constant declarations
--============================================================================

  constant C_BASE_ADDR            : integer := 16#0000#;
  constant C_CH_to_CH_ADDR_OFFSET : integer := 4 * 64;

  constant C_RX_CAPTURE_STATUS_CH0_ADDR : integer := C_BASE_ADDR + 4 * 0;  -- 0x00
  constant C_RX_CAPTURE_CTRL_CH0_ADDR   : integer := C_BASE_ADDR + 4 * 1;  -- 0x04

--============================================================================
--                                                                Common Logic
--============================================================================

  constant C_TTC_MMCM_RST           : integer := 16#1_0000#;
  constant C_TTC_MMCM_LOCKED        : integer := 16#1_0004#;
  constant C_TTC_MMCM_PHASE_SHIFT   : integer := 16#1_0008#;
  constant C_TTC_STAT_RST           : integer := 16#1_000C#;
  constant C_TTC_BX0_LOCKED         : integer := 16#1_0010#;
  constant C_TTC_BX0_ERR            : integer := 16#1_0014#;
  constant C_TTC_BX0_UNLOCKED_CNT   : integer := 16#1_0018#;
  constant C_TTC_BX0_UDF_CNT        : integer := 16#1_001C#;
  constant C_TTC_BX0_OVF_CNT        : integer := 16#1_0020#;
  constant C_TTC_DEC_SINGLE_ERR_CNT : integer := 16#1_0024#;
  constant C_TTC_DEC_DOUBLE_ERR_CNT : integer := 16#1_0028#;
  constant C_TTC_BX0_CMD            : integer := 16#1_002C#;
  constant C_TTC_EC0_CMD            : integer := 16#1_0030#;
  constant C_TTC_RESYNC_CMD         : integer := 16#1_0034#;
  constant C_TTC_OC0_CMD            : integer := 16#1_0038#;
  constant C_TTC_TEST_SYNC_CMD      : integer := 16#1_003C#;
  constant C_TTC_START_CMD          : integer := 16#1_0040#;
  constant C_TTC_STOP_CMD           : integer := 16#1_0044#;

  constant C_TTC_L1A_ENABLE    : integer := 16#1_004C#;
  constant C_TTC_L1A_CNT       : integer := 16#1_0050#;
  constant C_TTC_BX0_CNT       : integer := 16#1_0054#;
  constant C_TTC_EC0_CNT       : integer := 16#1_0058#;
  constant C_TTC_RESYNC_CNT    : integer := 16#1_005C#;
  constant C_TTC_OC0_CNT       : integer := 16#1_0060#;
  constant C_TTC_TEST_SYNC_CNT : integer := 16#1_0064#;
  constant C_TTC_START_CNT     : integer := 16#1_0068#;
  constant C_TTC_STOP_CNT      : integer := 16#1_006C#;
  constant C_TTC_L1ID_CNT      : integer := 16#1_0070#;
  constant C_TTC_ORBIT_CNT     : integer := 16#1_0074#;

  signal s_ttc_mmcm_ctrl : t_ttc_mmcm_ctrl;

  signal s_ttc_mmcm_stat : t_ttc_mmcm_stat;

  signal s_ttc_ctrl : t_ttc_ctrl := (
    bc0_cmd       => C_TTC_BGO_BC0,
    ec0_cmd       => C_TTC_BGO_EC0,
    resync_cmd    => C_TTC_BGO_RESYNC,
    oc0_cmd       => C_TTC_BGO_OC0,
    test_sync_cmd => C_TTC_BGO_TEST_SYNC,
    start_cmd     => C_TTC_BGO_START,
    stop_cmd      => C_TTC_BGO_STOP,
    l1a_enable    => '0',
    stat_reset    => '0'
    );

  signal s_ttc_stat       : t_ttc_stat;
  signal s_ttc_diag_cntrs : t_ttc_diag_cntrs;
  signal s_ttc_daq_cntrs  : t_ttc_daq_cntrs;

--============================================================================
--                                                         Signal declarations
--============================================================================

  constant C_REG_FILE_CLK_FREQ : integer := 50_000_000;

  signal s_uptime_second_cnt : unsigned(31 downto 0);
  signal s_free_running_cnt  : integer range 0 to C_REG_FILE_CLK_FREQ - 1;


  signal s_mmcm_rst     : std_logic;
  signal s_ttc_stat_rst : std_logic;


  signal s_wr_cmd_cnt : std_logic_vector(31 downto 0);

  signal s_rx_capture_status_reg : t_slv_arr_32(11 downto 0);
  signal s_rx_capture_ctrl_reg   : t_slv_arr_32(11 downto 0);

--============================================================================
--                                                          Architecture begin
--============================================================================

begin

  ttc_mmcm_ctrl_o  <= s_ttc_mmcm_ctrl;
  s_ttc_mmcm_stat  <= ttc_mmcm_stat_i;
  ttc_ctrl_o       <= s_ttc_ctrl;
  s_ttc_stat       <= ttc_stat_i;
  s_ttc_diag_cntrs <= ttc_diag_cntrs_i;
  s_ttc_daq_cntrs  <= ttc_daq_cntrs_i;

  process (BRAM_CTRL_REG_FILE_clk)
  begin
    if(rising_edge(BRAM_CTRL_REG_FILE_clk)) then
      s_free_running_cnt <= s_free_running_cnt + 1;

      if (s_free_running_cnt = C_REG_FILE_CLK_FREQ - 1) then
        s_free_running_cnt  <= 0;
        s_uptime_second_cnt <= s_uptime_second_cnt + 1;
      end if;
    end if;
  end process;

  i_pulse_extend_1 : pulse_extend
    generic map (
      DELAY_CNT_LENGTH => 2
      )
    port map (
      clk_i          => BRAM_CTRL_REG_FILE_clk,
      rst_i          => '0',
      pulse_length_i => "11",
      pulse_i        => s_mmcm_rst,
      pulse_o        => s_ttc_mmcm_ctrl.reset
      );

  i_pulse_extend_2 : pulse_extend
    generic map (
      DELAY_CNT_LENGTH => 2
      )
    port map(
      clk_i          => BRAM_CTRL_REG_FILE_clk,
      rst_i          => '0',
      pulse_length_i => "11",
      pulse_i        => s_ttc_stat_rst,
      pulse_o        => s_ttc_ctrl.stat_reset
      );

  process (BRAM_CTRL_REG_FILE_clk)
  begin
    if(rising_edge(BRAM_CTRL_REG_FILE_clk)) then

      s_mmcm_rst     <= '0';
      s_ttc_stat_rst <= '0';

      s_ttc_mmcm_ctrl.phase_shift <= '0';

      if(BRAM_CTRL_REG_FILE_en = '1' and BRAM_CTRL_REG_FILE_we = "1111") then

        s_wr_cmd_cnt <= std_logic_vector(unsigned(s_wr_cmd_cnt) + 1);

        case (BRAM_CTRL_REG_FILE_addr) is

          when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH0, 17)  => s_rx_capture_ctrl_reg(C_CH0)  <= BRAM_CTRL_REG_FILE_din;
          when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH1, 17)  => s_rx_capture_ctrl_reg(C_CH1)  <= BRAM_CTRL_REG_FILE_din;
          when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH2, 17)  => s_rx_capture_ctrl_reg(C_CH2)  <= BRAM_CTRL_REG_FILE_din;
          when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH3, 17)  => s_rx_capture_ctrl_reg(C_CH3)  <= BRAM_CTRL_REG_FILE_din;
          when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH4, 17)  => s_rx_capture_ctrl_reg(C_CH4)  <= BRAM_CTRL_REG_FILE_din;
          when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH5, 17)  => s_rx_capture_ctrl_reg(C_CH5)  <= BRAM_CTRL_REG_FILE_din;
          when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH6, 17)  => s_rx_capture_ctrl_reg(C_CH6)  <= BRAM_CTRL_REG_FILE_din;
          when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH7, 17)  => s_rx_capture_ctrl_reg(C_CH7)  <= BRAM_CTRL_REG_FILE_din;
          when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH8, 17)  => s_rx_capture_ctrl_reg(C_CH8)  <= BRAM_CTRL_REG_FILE_din;
          when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH9, 17)  => s_rx_capture_ctrl_reg(C_CH9)  <= BRAM_CTRL_REG_FILE_din;
          when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH10, 17) => s_rx_capture_ctrl_reg(C_CH10) <= BRAM_CTRL_REG_FILE_din;
          when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH11, 17) => s_rx_capture_ctrl_reg(C_CH11) <= BRAM_CTRL_REG_FILE_din;

          when addr_encode(C_TTC_MMCM_RST, 0, 0, 17)         => s_mmcm_rst                  <= BRAM_CTRL_REG_FILE_din(0);
          when addr_encode(C_TTC_MMCM_PHASE_SHIFT, 0, 0, 17) => s_ttc_mmcm_ctrl.phase_shift <= BRAM_CTRL_REG_FILE_din(0);
          when addr_encode(C_TTC_STAT_RST, 0, 0, 17)         => s_ttc_stat_rst              <= BRAM_CTRL_REG_FILE_din(0);

          when addr_encode(C_TTC_BX0_CMD, 0, 0, 17)       => s_ttc_ctrl.bc0_cmd       <= BRAM_CTRL_REG_FILE_din(7 downto 0);
          when addr_encode(C_TTC_EC0_CMD, 0, 0, 17)       => s_ttc_ctrl.ec0_cmd       <= BRAM_CTRL_REG_FILE_din(7 downto 0);
          when addr_encode(C_TTC_RESYNC_CMD, 0, 0, 17)    => s_ttc_ctrl.resync_cmd    <= BRAM_CTRL_REG_FILE_din(7 downto 0);
          when addr_encode(C_TTC_OC0_CMD, 0, 0, 17)       => s_ttc_ctrl.oc0_cmd       <= BRAM_CTRL_REG_FILE_din(7 downto 0);
          when addr_encode(C_TTC_TEST_SYNC_CMD, 0, 0, 17) => s_ttc_ctrl.test_sync_cmd <= BRAM_CTRL_REG_FILE_din(7 downto 0);
          when addr_encode(C_TTC_START_CMD, 0, 0, 17)     => s_ttc_ctrl.start_cmd     <= BRAM_CTRL_REG_FILE_din(7 downto 0);
          when addr_encode(C_TTC_STOP_CMD, 0, 0, 17)      => s_ttc_ctrl.stop_cmd      <= BRAM_CTRL_REG_FILE_din(7 downto 0);
          when addr_encode(C_TTC_L1A_ENABLE, 0, 0, 17)    => s_ttc_ctrl.l1a_enable    <= BRAM_CTRL_REG_FILE_din(0);

          when others => null;
        end case;
      end if;

      --default BRAM dout assignment
      BRAM_CTRL_REG_FILE_dout <= (others => '0');

      case (BRAM_CTRL_REG_FILE_addr) is

        when addr_encode(C_RX_CAPTURE_STATUS_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH0, 17)  => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_status_reg(C_CH0);
        when addr_encode(C_RX_CAPTURE_STATUS_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH1, 17)  => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_status_reg(C_CH1);
        when addr_encode(C_RX_CAPTURE_STATUS_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH2, 17)  => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_status_reg(C_CH2);
        when addr_encode(C_RX_CAPTURE_STATUS_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH3, 17)  => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_status_reg(C_CH3);
        when addr_encode(C_RX_CAPTURE_STATUS_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH4, 17)  => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_status_reg(C_CH4);
        when addr_encode(C_RX_CAPTURE_STATUS_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH5, 17)  => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_status_reg(C_CH5);
        when addr_encode(C_RX_CAPTURE_STATUS_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH6, 17)  => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_status_reg(C_CH6);
        when addr_encode(C_RX_CAPTURE_STATUS_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH7, 17)  => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_status_reg(C_CH7);
        when addr_encode(C_RX_CAPTURE_STATUS_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH8, 17)  => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_status_reg(C_CH8);
        when addr_encode(C_RX_CAPTURE_STATUS_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH9, 17)  => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_status_reg(C_CH9);
        when addr_encode(C_RX_CAPTURE_STATUS_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH10, 17) => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_status_reg(C_CH10);
        when addr_encode(C_RX_CAPTURE_STATUS_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH11, 17) => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_status_reg(C_CH11);

        when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH0, 17)  => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_ctrl_reg(C_CH0);
        when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH1, 17)  => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_ctrl_reg(C_CH1);
        when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH2, 17)  => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_ctrl_reg(C_CH2);
        when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH3, 17)  => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_ctrl_reg(C_CH3);
        when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH4, 17)  => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_ctrl_reg(C_CH4);
        when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH5, 17)  => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_ctrl_reg(C_CH5);
        when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH6, 17)  => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_ctrl_reg(C_CH6);
        when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH7, 17)  => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_ctrl_reg(C_CH7);
        when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH8, 17)  => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_ctrl_reg(C_CH8);
        when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH9, 17)  => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_ctrl_reg(C_CH9);
        when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH10, 17) => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_ctrl_reg(C_CH10);
        when addr_encode(C_RX_CAPTURE_CTRL_CH0_ADDR, C_CH_to_CH_ADDR_OFFSET, C_CH11, 17) => BRAM_CTRL_REG_FILE_dout <= s_rx_capture_ctrl_reg(C_CH11);

        when addr_encode(C_TTC_MMCM_LOCKED, 0, 0, 17) => BRAM_CTRL_REG_FILE_dout(0) <= s_ttc_mmcm_stat.locked;

        when addr_encode(C_TTC_BX0_LOCKED, 0, 0, 17)         => BRAM_CTRL_REG_FILE_dout(0)           <= s_ttc_stat.bc0_stat.locked;
        when addr_encode(C_TTC_BX0_ERR, 0, 0, 17)            => BRAM_CTRL_REG_FILE_dout(0)           <= s_ttc_stat.bc0_stat.err;
        when addr_encode(C_TTC_BX0_UNLOCKED_CNT, 0, 0, 17)   => BRAM_CTRL_REG_FILE_dout(15 downto 0) <= s_ttc_stat.bc0_stat.unlocked_cnt;
        when addr_encode(C_TTC_BX0_UDF_CNT, 0, 0, 17)        => BRAM_CTRL_REG_FILE_dout(15 downto 0) <= s_ttc_stat.bc0_stat.udf_cnt;
        when addr_encode(C_TTC_BX0_OVF_CNT, 0, 0, 17)        => BRAM_CTRL_REG_FILE_dout(15 downto 0) <= s_ttc_stat.bc0_stat.ovf_cnt;
        when addr_encode(C_TTC_DEC_SINGLE_ERR_CNT, 0, 0, 17) => BRAM_CTRL_REG_FILE_dout(15 downto 0) <= s_ttc_stat.single_err;
        when addr_encode(C_TTC_DEC_DOUBLE_ERR_CNT, 0, 0, 17) => BRAM_CTRL_REG_FILE_dout(15 downto 0) <= s_ttc_stat.double_err;
        when addr_encode(C_TTC_BX0_CMD, 0, 0, 17)            => BRAM_CTRL_REG_FILE_dout(7 downto 0)  <= s_ttc_ctrl.bc0_cmd;
        when addr_encode(C_TTC_EC0_CMD, 0, 0, 17)            => BRAM_CTRL_REG_FILE_dout(7 downto 0)  <= s_ttc_ctrl.ec0_cmd;
        when addr_encode(C_TTC_RESYNC_CMD, 0, 0, 17)         => BRAM_CTRL_REG_FILE_dout(7 downto 0)  <= s_ttc_ctrl.resync_cmd;
        when addr_encode(C_TTC_OC0_CMD, 0, 0, 17)            => BRAM_CTRL_REG_FILE_dout(7 downto 0)  <= s_ttc_ctrl.oc0_cmd;
        when addr_encode(C_TTC_TEST_SYNC_CMD, 0, 0, 17)      => BRAM_CTRL_REG_FILE_dout(7 downto 0)  <= s_ttc_ctrl.test_sync_cmd;
        when addr_encode(C_TTC_START_CMD, 0, 0, 17)          => BRAM_CTRL_REG_FILE_dout(7 downto 0)  <= s_ttc_ctrl.start_cmd;
        when addr_encode(C_TTC_STOP_CMD, 0, 0, 17)           => BRAM_CTRL_REG_FILE_dout(7 downto 0)  <= s_ttc_ctrl.stop_cmd;
        when addr_encode(C_TTC_L1A_ENABLE, 0, 0, 17)         => BRAM_CTRL_REG_FILE_dout(0)           <= s_ttc_ctrl.l1a_enable;
        when addr_encode(C_TTC_L1A_CNT, 0, 0, 17)            => BRAM_CTRL_REG_FILE_dout(31 downto 0) <= s_ttc_diag_cntrs.l1a;
        when addr_encode(C_TTC_BX0_CNT, 0, 0, 17)            => BRAM_CTRL_REG_FILE_dout(31 downto 0) <= s_ttc_diag_cntrs.bc0;
        when addr_encode(C_TTC_EC0_CNT, 0, 0, 17)            => BRAM_CTRL_REG_FILE_dout(31 downto 0) <= s_ttc_diag_cntrs.ec0;
        when addr_encode(C_TTC_RESYNC_CNT, 0, 0, 17)         => BRAM_CTRL_REG_FILE_dout(31 downto 0) <= s_ttc_diag_cntrs.resync;
        when addr_encode(C_TTC_OC0_CNT, 0, 0, 17)            => BRAM_CTRL_REG_FILE_dout(31 downto 0) <= s_ttc_diag_cntrs.oc0;
        when addr_encode(C_TTC_TEST_SYNC_CNT, 0, 0, 17)      => BRAM_CTRL_REG_FILE_dout(31 downto 0) <= s_ttc_diag_cntrs.test_sync;
        when addr_encode(C_TTC_START_CNT, 0, 0, 17)          => BRAM_CTRL_REG_FILE_dout(31 downto 0) <= s_ttc_diag_cntrs.start;
        when addr_encode(C_TTC_STOP_CNT, 0, 0, 17)           => BRAM_CTRL_REG_FILE_dout(31 downto 0) <= s_ttc_diag_cntrs.stop;
        when addr_encode(C_TTC_L1ID_CNT, 0, 0, 17)           => BRAM_CTRL_REG_FILE_dout(31 downto 0) <= s_ttc_daq_cntrs.L1ID;

        when '1' & X"FF04" => BRAM_CTRL_REG_FILE_dout(31 downto 0) <= s_wr_cmd_cnt;

        when '1' & X"FFE0" => BRAM_CTRL_REG_FILE_dout(31 downto 0) <= C_DATE_CODE;
        when '1' & X"FFE4" => BRAM_CTRL_REG_FILE_dout(31 downto 0) <= C_GITHASH_CODE;
        when '1' & X"FFE8" => BRAM_CTRL_REG_FILE_dout(0)           <= C_GIT_REPO_DIRTY;
        when '1' & X"FFEC" => BRAM_CTRL_REG_FILE_dout(31 downto 0) <= BCFG_FW_VERSION_MAJOR &
                                                                      BCFG_FW_VERSION_MINOR &
                                                                      BCFG_FW_VERSION_PATCH &
                                                                      x"00";

        when '1' & X"FFF8" => BRAM_CTRL_REG_FILE_dout(31 downto 0) <= std_logic_vector(s_uptime_second_cnt);
        when '1' & X"FFFC" => BRAM_CTRL_REG_FILE_dout(31 downto 0) <= BCFG_FW_PROJECT_CODE;

        when others => BRAM_CTRL_REG_FILE_dout <= x"00000000";
      end case;

    end if;
  end process;


  gen_capture_regs : for i in 0 to 11 generate
    s_rx_capture_status_reg(i)(3 downto 0) <= rx_capture_status_i(i).fsm_state;
    s_rx_capture_status_reg(i)(4)          <= rx_capture_status_i(i).done;

    rx_capture_ctrl_o(i).rst <= s_rx_capture_ctrl_reg(i)(0);
    rx_capture_ctrl_o(i).arm <= s_rx_capture_ctrl_reg(i)(1);

  end generate;

end register_file_arch;
--============================================================================
--                                                            Architecture end
--============================================================================
