library IEEE;
use IEEE.STD_LOGIC_1164.all;

-----> !! This package is auto-generated from an address table file using <repo_root>/scripts/generate_registers.py !! <-----
package registers is

    --============================================================================
    --       >>> TTC Module <<<    base address: 0x00300000
    --
    -- TTC control and monitoring. It takes care of locking to the TTC clock
    -- coming from the backplane as well as decoding TTC commands and forwarding
    -- that to all other modules in the design. It also provides several control
    -- and monitoring registers (resets, command decoding configuration, clock and
    -- data status, bc0 status, command counters and a small spy buffer)
    --============================================================================

    constant REG_TTC_NUM_REGS : integer := 26;
    constant REG_TTC_ADDRESS_MSB : integer := 5;
    constant REG_TTC_ADDRESS_LSB : integer := 0;
    constant REG_TTC_CTRL_MODULE_RESET_ADDR    : std_logic_vector(5 downto 0) := "00" & x"0";
    constant REG_TTC_CTRL_MODULE_RESET_BIT    : integer := 31;

    constant REG_TTC_CTRL_MMCM_RESET_ADDR    : std_logic_vector(5 downto 0) := "00" & x"1";
    constant REG_TTC_CTRL_MMCM_RESET_BIT    : integer := 30;

    constant REG_TTC_CTRL_CNT_RESET_ADDR    : std_logic_vector(5 downto 0) := "00" & x"2";
    constant REG_TTC_CTRL_CNT_RESET_BIT    : integer := 29;

    constant REG_TTC_CTRL_MMCM_PHASE_SHIFT_ADDR    : std_logic_vector(5 downto 0) := "00" & x"3";
    constant REG_TTC_CTRL_MMCM_PHASE_SHIFT_BIT    : integer := 28;

    constant REG_TTC_CTRL_L1A_ENABLE_ADDR    : std_logic_vector(5 downto 0) := "00" & x"4";
    constant REG_TTC_CTRL_L1A_ENABLE_BIT    : integer := 0;
    constant REG_TTC_CTRL_L1A_ENABLE_DEFAULT : std_logic := '1';

    constant REG_TTC_CONFIG_CMD_BC0_ADDR    : std_logic_vector(5 downto 0) := "00" & x"5";
    constant REG_TTC_CONFIG_CMD_BC0_MSB    : integer := 7;
    constant REG_TTC_CONFIG_CMD_BC0_LSB     : integer := 0;
    constant REG_TTC_CONFIG_CMD_BC0_DEFAULT : std_logic_vector(7 downto 0) := x"01";

    constant REG_TTC_CONFIG_CMD_EC0_ADDR    : std_logic_vector(5 downto 0) := "00" & x"5";
    constant REG_TTC_CONFIG_CMD_EC0_MSB    : integer := 15;
    constant REG_TTC_CONFIG_CMD_EC0_LSB     : integer := 8;
    constant REG_TTC_CONFIG_CMD_EC0_DEFAULT : std_logic_vector(15 downto 8) := x"02";

    constant REG_TTC_CONFIG_CMD_RESYNC_ADDR    : std_logic_vector(5 downto 0) := "00" & x"5";
    constant REG_TTC_CONFIG_CMD_RESYNC_MSB    : integer := 23;
    constant REG_TTC_CONFIG_CMD_RESYNC_LSB     : integer := 16;
    constant REG_TTC_CONFIG_CMD_RESYNC_DEFAULT : std_logic_vector(23 downto 16) := x"04";

    constant REG_TTC_CONFIG_CMD_OC0_ADDR    : std_logic_vector(5 downto 0) := "00" & x"5";
    constant REG_TTC_CONFIG_CMD_OC0_MSB    : integer := 31;
    constant REG_TTC_CONFIG_CMD_OC0_LSB     : integer := 24;
    constant REG_TTC_CONFIG_CMD_OC0_DEFAULT : std_logic_vector(31 downto 24) := x"08";

    constant REG_TTC_CONFIG_CMD_HARD_RESET_ADDR    : std_logic_vector(5 downto 0) := "00" & x"6";
    constant REG_TTC_CONFIG_CMD_HARD_RESET_MSB    : integer := 7;
    constant REG_TTC_CONFIG_CMD_HARD_RESET_LSB     : integer := 0;
    constant REG_TTC_CONFIG_CMD_HARD_RESET_DEFAULT : std_logic_vector(7 downto 0) := x"10";

    constant REG_TTC_CONFIG_CMD_CALPULSE_ADDR    : std_logic_vector(5 downto 0) := "00" & x"6";
    constant REG_TTC_CONFIG_CMD_CALPULSE_MSB    : integer := 15;
    constant REG_TTC_CONFIG_CMD_CALPULSE_LSB     : integer := 8;
    constant REG_TTC_CONFIG_CMD_CALPULSE_DEFAULT : std_logic_vector(15 downto 8) := x"14";

    constant REG_TTC_CONFIG_CMD_START_ADDR    : std_logic_vector(5 downto 0) := "00" & x"6";
    constant REG_TTC_CONFIG_CMD_START_MSB    : integer := 23;
    constant REG_TTC_CONFIG_CMD_START_LSB     : integer := 16;
    constant REG_TTC_CONFIG_CMD_START_DEFAULT : std_logic_vector(23 downto 16) := x"18";

    constant REG_TTC_CONFIG_CMD_STOP_ADDR    : std_logic_vector(5 downto 0) := "00" & x"6";
    constant REG_TTC_CONFIG_CMD_STOP_MSB    : integer := 31;
    constant REG_TTC_CONFIG_CMD_STOP_LSB     : integer := 24;
    constant REG_TTC_CONFIG_CMD_STOP_DEFAULT : std_logic_vector(31 downto 24) := x"1c";

    constant REG_TTC_CONFIG_CMD_TEST_SYNC_ADDR    : std_logic_vector(5 downto 0) := "00" & x"7";
    constant REG_TTC_CONFIG_CMD_TEST_SYNC_MSB    : integer := 7;
    constant REG_TTC_CONFIG_CMD_TEST_SYNC_LSB     : integer := 0;
    constant REG_TTC_CONFIG_CMD_TEST_SYNC_DEFAULT : std_logic_vector(7 downto 0) := x"20";

    constant REG_TTC_STATUS_MMCM_LOCKED_ADDR    : std_logic_vector(5 downto 0) := "00" & x"8";
    constant REG_TTC_STATUS_MMCM_LOCKED_BIT    : integer := 0;

    constant REG_TTC_STATUS_TTC_SINGLE_ERROR_CNT_ADDR    : std_logic_vector(5 downto 0) := "00" & x"9";
    constant REG_TTC_STATUS_TTC_SINGLE_ERROR_CNT_MSB    : integer := 15;
    constant REG_TTC_STATUS_TTC_SINGLE_ERROR_CNT_LSB     : integer := 0;

    constant REG_TTC_STATUS_TTC_DOUBLE_ERROR_CNT_ADDR    : std_logic_vector(5 downto 0) := "00" & x"9";
    constant REG_TTC_STATUS_TTC_DOUBLE_ERROR_CNT_MSB    : integer := 31;
    constant REG_TTC_STATUS_TTC_DOUBLE_ERROR_CNT_LSB     : integer := 16;

    constant REG_TTC_STATUS_BC0_LOCKED_ADDR    : std_logic_vector(5 downto 0) := "00" & x"a";
    constant REG_TTC_STATUS_BC0_LOCKED_BIT    : integer := 0;

    constant REG_TTC_STATUS_BC0_UNLOCK_CNT_ADDR    : std_logic_vector(5 downto 0) := "00" & x"b";
    constant REG_TTC_STATUS_BC0_UNLOCK_CNT_MSB    : integer := 15;
    constant REG_TTC_STATUS_BC0_UNLOCK_CNT_LSB     : integer := 0;

    constant REG_TTC_STATUS_BC0_OVERFLOW_CNT_ADDR    : std_logic_vector(5 downto 0) := "00" & x"c";
    constant REG_TTC_STATUS_BC0_OVERFLOW_CNT_MSB    : integer := 15;
    constant REG_TTC_STATUS_BC0_OVERFLOW_CNT_LSB     : integer := 0;

    constant REG_TTC_STATUS_BC0_UNDERFLOW_CNT_ADDR    : std_logic_vector(5 downto 0) := "00" & x"c";
    constant REG_TTC_STATUS_BC0_UNDERFLOW_CNT_MSB    : integer := 31;
    constant REG_TTC_STATUS_BC0_UNDERFLOW_CNT_LSB     : integer := 16;

    constant REG_TTC_CMD_COUNTERS_L1A_ADDR    : std_logic_vector(5 downto 0) := "00" & x"d";
    constant REG_TTC_CMD_COUNTERS_L1A_MSB    : integer := 31;
    constant REG_TTC_CMD_COUNTERS_L1A_LSB     : integer := 0;

    constant REG_TTC_CMD_COUNTERS_BC0_ADDR    : std_logic_vector(5 downto 0) := "00" & x"e";
    constant REG_TTC_CMD_COUNTERS_BC0_MSB    : integer := 31;
    constant REG_TTC_CMD_COUNTERS_BC0_LSB     : integer := 0;

    constant REG_TTC_CMD_COUNTERS_EC0_ADDR    : std_logic_vector(5 downto 0) := "00" & x"f";
    constant REG_TTC_CMD_COUNTERS_EC0_MSB    : integer := 31;
    constant REG_TTC_CMD_COUNTERS_EC0_LSB     : integer := 0;

    constant REG_TTC_CMD_COUNTERS_RESYNC_ADDR    : std_logic_vector(5 downto 0) := "01" & x"0";
    constant REG_TTC_CMD_COUNTERS_RESYNC_MSB    : integer := 31;
    constant REG_TTC_CMD_COUNTERS_RESYNC_LSB     : integer := 0;

    constant REG_TTC_CMD_COUNTERS_OC0_ADDR    : std_logic_vector(5 downto 0) := "01" & x"1";
    constant REG_TTC_CMD_COUNTERS_OC0_MSB    : integer := 31;
    constant REG_TTC_CMD_COUNTERS_OC0_LSB     : integer := 0;

    constant REG_TTC_CMD_COUNTERS_HARD_RESET_ADDR    : std_logic_vector(5 downto 0) := "01" & x"2";
    constant REG_TTC_CMD_COUNTERS_HARD_RESET_MSB    : integer := 31;
    constant REG_TTC_CMD_COUNTERS_HARD_RESET_LSB     : integer := 0;

    constant REG_TTC_CMD_COUNTERS_CALPULSE_ADDR    : std_logic_vector(5 downto 0) := "01" & x"3";
    constant REG_TTC_CMD_COUNTERS_CALPULSE_MSB    : integer := 31;
    constant REG_TTC_CMD_COUNTERS_CALPULSE_LSB     : integer := 0;

    constant REG_TTC_CMD_COUNTERS_START_ADDR    : std_logic_vector(5 downto 0) := "01" & x"4";
    constant REG_TTC_CMD_COUNTERS_START_MSB    : integer := 31;
    constant REG_TTC_CMD_COUNTERS_START_LSB     : integer := 0;

    constant REG_TTC_CMD_COUNTERS_STOP_ADDR    : std_logic_vector(5 downto 0) := "01" & x"5";
    constant REG_TTC_CMD_COUNTERS_STOP_MSB    : integer := 31;
    constant REG_TTC_CMD_COUNTERS_STOP_LSB     : integer := 0;

    constant REG_TTC_CMD_COUNTERS_TEST_SYNC_ADDR    : std_logic_vector(5 downto 0) := "01" & x"6";
    constant REG_TTC_CMD_COUNTERS_TEST_SYNC_MSB    : integer := 31;
    constant REG_TTC_CMD_COUNTERS_TEST_SYNC_LSB     : integer := 0;

    constant REG_TTC_L1A_ID_ADDR    : std_logic_vector(5 downto 0) := "01" & x"7";
    constant REG_TTC_L1A_ID_MSB    : integer := 23;
    constant REG_TTC_L1A_ID_LSB     : integer := 0;

    constant REG_TTC_L1A_RATE_ADDR    : std_logic_vector(5 downto 0) := "01" & x"8";
    constant REG_TTC_L1A_RATE_MSB    : integer := 31;
    constant REG_TTC_L1A_RATE_LSB     : integer := 0;

    constant REG_TTC_TTC_SPY_BUFFER_ADDR    : std_logic_vector(5 downto 0) := "01" & x"9";
    constant REG_TTC_TTC_SPY_BUFFER_MSB    : integer := 31;
    constant REG_TTC_TTC_SPY_BUFFER_LSB     : integer := 0;


    --============================================================================
    --       >>> SYSTEM Module <<<    base address: 0x00100000
    --
    -- This module is controlling CSC FED system wide settings
    --============================================================================

    constant REG_SYSTEM_NUM_REGS : integer := 4;
    constant REG_SYSTEM_ADDRESS_MSB : integer := 12;
    constant REG_SYSTEM_ADDRESS_LSB : integer := 0;
    constant REG_SYSTEM_BOARD_ID_ADDR    : std_logic_vector(12 downto 0) := '0' & x"002";
    constant REG_SYSTEM_BOARD_ID_MSB    : integer := 15;
    constant REG_SYSTEM_BOARD_ID_LSB     : integer := 0;
    constant REG_SYSTEM_BOARD_ID_DEFAULT : std_logic_vector(15 downto 0) := x"cfed";

    constant REG_SYSTEM_BOARD_TYPE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"002";
    constant REG_SYSTEM_BOARD_TYPE_MSB    : integer := 19;
    constant REG_SYSTEM_BOARD_TYPE_LSB     : integer := 16;

    constant REG_SYSTEM_RELEASE_BUILD_ADDR    : std_logic_vector(12 downto 0) := '0' & x"003";
    constant REG_SYSTEM_RELEASE_BUILD_MSB    : integer := 7;
    constant REG_SYSTEM_RELEASE_BUILD_LSB     : integer := 0;

    constant REG_SYSTEM_RELEASE_MINOR_ADDR    : std_logic_vector(12 downto 0) := '0' & x"003";
    constant REG_SYSTEM_RELEASE_MINOR_MSB    : integer := 15;
    constant REG_SYSTEM_RELEASE_MINOR_LSB     : integer := 8;

    constant REG_SYSTEM_RELEASE_MAJOR_ADDR    : std_logic_vector(12 downto 0) := '0' & x"003";
    constant REG_SYSTEM_RELEASE_MAJOR_MSB    : integer := 23;
    constant REG_SYSTEM_RELEASE_MAJOR_LSB     : integer := 16;

    constant REG_SYSTEM_RELEASE_DATE_ADDR    : std_logic_vector(12 downto 0) := '0' & x"004";
    constant REG_SYSTEM_RELEASE_DATE_MSB    : integer := 31;
    constant REG_SYSTEM_RELEASE_DATE_LSB     : integer := 0;

    constant REG_SYSTEM_CONFIG_NUM_OF_DMBS_ADDR    : std_logic_vector(12 downto 0) := '0' & x"005";
    constant REG_SYSTEM_CONFIG_NUM_OF_DMBS_MSB    : integer := 7;
    constant REG_SYSTEM_CONFIG_NUM_OF_DMBS_LSB     : integer := 0;


    --============================================================================
    --       >>> LINKS Module <<<    base address: 0x00200000
    --
    -- Link monitoring registers
    --============================================================================

    constant REG_LINKS_NUM_REGS : integer := 10;
    constant REG_LINKS_ADDRESS_MSB : integer := 12;
    constant REG_LINKS_ADDRESS_LSB : integer := 0;
    constant REG_LINKS_CTRL_CNT_RESET_ADDR    : std_logic_vector(12 downto 0) := '0' & x"000";
    constant REG_LINKS_CTRL_CNT_RESET_BIT    : integer := 31;

    constant REG_LINKS_DMB0_MGT_BUF_OVF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"010";
    constant REG_LINKS_DMB0_MGT_BUF_OVF_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB0_MGT_BUF_OVF_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB0_MGT_BUF_UNF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"010";
    constant REG_LINKS_DMB0_MGT_BUF_UNF_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB0_MGT_BUF_UNF_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB0_CLK_CORR_ADD_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"011";
    constant REG_LINKS_DMB0_CLK_CORR_ADD_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB0_CLK_CORR_ADD_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB0_CLK_CORR_DROP_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"011";
    constant REG_LINKS_DMB0_CLK_CORR_DROP_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB0_CLK_CORR_DROP_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB0_NOT_IN_TABLE_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"012";
    constant REG_LINKS_DMB0_NOT_IN_TABLE_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB0_NOT_IN_TABLE_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB0_DISPERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"012";
    constant REG_LINKS_DMB0_DISPERR_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB0_DISPERR_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB1_MGT_BUF_OVF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"020";
    constant REG_LINKS_DMB1_MGT_BUF_OVF_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB1_MGT_BUF_OVF_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB1_MGT_BUF_UNF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"020";
    constant REG_LINKS_DMB1_MGT_BUF_UNF_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB1_MGT_BUF_UNF_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB1_CLK_CORR_ADD_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"021";
    constant REG_LINKS_DMB1_CLK_CORR_ADD_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB1_CLK_CORR_ADD_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB1_CLK_CORR_DROP_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"021";
    constant REG_LINKS_DMB1_CLK_CORR_DROP_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB1_CLK_CORR_DROP_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB1_NOT_IN_TABLE_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"022";
    constant REG_LINKS_DMB1_NOT_IN_TABLE_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB1_NOT_IN_TABLE_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB1_DISPERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"022";
    constant REG_LINKS_DMB1_DISPERR_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB1_DISPERR_CNT_LSB     : integer := 16;

    constant REG_LINKS_SPY_MGT_BUF_OVF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"a00";
    constant REG_LINKS_SPY_MGT_BUF_OVF_CNT_MSB    : integer := 15;
    constant REG_LINKS_SPY_MGT_BUF_OVF_CNT_LSB     : integer := 0;

    constant REG_LINKS_SPY_MGT_BUF_UNF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"a00";
    constant REG_LINKS_SPY_MGT_BUF_UNF_CNT_MSB    : integer := 31;
    constant REG_LINKS_SPY_MGT_BUF_UNF_CNT_LSB     : integer := 16;

    constant REG_LINKS_SPY_CLK_CORR_ADD_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"a01";
    constant REG_LINKS_SPY_CLK_CORR_ADD_CNT_MSB    : integer := 15;
    constant REG_LINKS_SPY_CLK_CORR_ADD_CNT_LSB     : integer := 0;

    constant REG_LINKS_SPY_CLK_CORR_DROP_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"a01";
    constant REG_LINKS_SPY_CLK_CORR_DROP_CNT_MSB    : integer := 31;
    constant REG_LINKS_SPY_CLK_CORR_DROP_CNT_LSB     : integer := 16;

    constant REG_LINKS_SPY_NOT_IN_TABLE_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"a02";
    constant REG_LINKS_SPY_NOT_IN_TABLE_CNT_MSB    : integer := 15;
    constant REG_LINKS_SPY_NOT_IN_TABLE_CNT_LSB     : integer := 0;

    constant REG_LINKS_SPY_DISPERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"a02";
    constant REG_LINKS_SPY_DISPERR_CNT_MSB    : integer := 31;
    constant REG_LINKS_SPY_DISPERR_CNT_LSB     : integer := 16;


end registers;
