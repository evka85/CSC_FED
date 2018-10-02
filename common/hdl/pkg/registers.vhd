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

    constant REG_LINKS_NUM_REGS : integer := 49;
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

    constant REG_LINKS_DMB2_MGT_BUF_OVF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"030";
    constant REG_LINKS_DMB2_MGT_BUF_OVF_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB2_MGT_BUF_OVF_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB2_MGT_BUF_UNF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"030";
    constant REG_LINKS_DMB2_MGT_BUF_UNF_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB2_MGT_BUF_UNF_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB2_CLK_CORR_ADD_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"031";
    constant REG_LINKS_DMB2_CLK_CORR_ADD_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB2_CLK_CORR_ADD_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB2_CLK_CORR_DROP_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"031";
    constant REG_LINKS_DMB2_CLK_CORR_DROP_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB2_CLK_CORR_DROP_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB2_NOT_IN_TABLE_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"032";
    constant REG_LINKS_DMB2_NOT_IN_TABLE_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB2_NOT_IN_TABLE_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB2_DISPERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"032";
    constant REG_LINKS_DMB2_DISPERR_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB2_DISPERR_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB3_MGT_BUF_OVF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"040";
    constant REG_LINKS_DMB3_MGT_BUF_OVF_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB3_MGT_BUF_OVF_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB3_MGT_BUF_UNF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"040";
    constant REG_LINKS_DMB3_MGT_BUF_UNF_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB3_MGT_BUF_UNF_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB3_CLK_CORR_ADD_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"041";
    constant REG_LINKS_DMB3_CLK_CORR_ADD_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB3_CLK_CORR_ADD_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB3_CLK_CORR_DROP_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"041";
    constant REG_LINKS_DMB3_CLK_CORR_DROP_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB3_CLK_CORR_DROP_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB3_NOT_IN_TABLE_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"042";
    constant REG_LINKS_DMB3_NOT_IN_TABLE_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB3_NOT_IN_TABLE_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB3_DISPERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"042";
    constant REG_LINKS_DMB3_DISPERR_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB3_DISPERR_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB4_MGT_BUF_OVF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"050";
    constant REG_LINKS_DMB4_MGT_BUF_OVF_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB4_MGT_BUF_OVF_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB4_MGT_BUF_UNF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"050";
    constant REG_LINKS_DMB4_MGT_BUF_UNF_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB4_MGT_BUF_UNF_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB4_CLK_CORR_ADD_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"051";
    constant REG_LINKS_DMB4_CLK_CORR_ADD_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB4_CLK_CORR_ADD_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB4_CLK_CORR_DROP_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"051";
    constant REG_LINKS_DMB4_CLK_CORR_DROP_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB4_CLK_CORR_DROP_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB4_NOT_IN_TABLE_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"052";
    constant REG_LINKS_DMB4_NOT_IN_TABLE_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB4_NOT_IN_TABLE_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB4_DISPERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"052";
    constant REG_LINKS_DMB4_DISPERR_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB4_DISPERR_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB5_MGT_BUF_OVF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"060";
    constant REG_LINKS_DMB5_MGT_BUF_OVF_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB5_MGT_BUF_OVF_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB5_MGT_BUF_UNF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"060";
    constant REG_LINKS_DMB5_MGT_BUF_UNF_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB5_MGT_BUF_UNF_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB5_CLK_CORR_ADD_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"061";
    constant REG_LINKS_DMB5_CLK_CORR_ADD_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB5_CLK_CORR_ADD_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB5_CLK_CORR_DROP_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"061";
    constant REG_LINKS_DMB5_CLK_CORR_DROP_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB5_CLK_CORR_DROP_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB5_NOT_IN_TABLE_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"062";
    constant REG_LINKS_DMB5_NOT_IN_TABLE_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB5_NOT_IN_TABLE_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB5_DISPERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"062";
    constant REG_LINKS_DMB5_DISPERR_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB5_DISPERR_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB6_MGT_BUF_OVF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"070";
    constant REG_LINKS_DMB6_MGT_BUF_OVF_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB6_MGT_BUF_OVF_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB6_MGT_BUF_UNF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"070";
    constant REG_LINKS_DMB6_MGT_BUF_UNF_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB6_MGT_BUF_UNF_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB6_CLK_CORR_ADD_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"071";
    constant REG_LINKS_DMB6_CLK_CORR_ADD_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB6_CLK_CORR_ADD_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB6_CLK_CORR_DROP_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"071";
    constant REG_LINKS_DMB6_CLK_CORR_DROP_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB6_CLK_CORR_DROP_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB6_NOT_IN_TABLE_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"072";
    constant REG_LINKS_DMB6_NOT_IN_TABLE_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB6_NOT_IN_TABLE_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB6_DISPERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"072";
    constant REG_LINKS_DMB6_DISPERR_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB6_DISPERR_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB7_MGT_BUF_OVF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"080";
    constant REG_LINKS_DMB7_MGT_BUF_OVF_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB7_MGT_BUF_OVF_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB7_MGT_BUF_UNF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"080";
    constant REG_LINKS_DMB7_MGT_BUF_UNF_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB7_MGT_BUF_UNF_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB7_CLK_CORR_ADD_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"081";
    constant REG_LINKS_DMB7_CLK_CORR_ADD_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB7_CLK_CORR_ADD_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB7_CLK_CORR_DROP_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"081";
    constant REG_LINKS_DMB7_CLK_CORR_DROP_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB7_CLK_CORR_DROP_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB7_NOT_IN_TABLE_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"082";
    constant REG_LINKS_DMB7_NOT_IN_TABLE_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB7_NOT_IN_TABLE_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB7_DISPERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"082";
    constant REG_LINKS_DMB7_DISPERR_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB7_DISPERR_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB8_MGT_BUF_OVF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"090";
    constant REG_LINKS_DMB8_MGT_BUF_OVF_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB8_MGT_BUF_OVF_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB8_MGT_BUF_UNF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"090";
    constant REG_LINKS_DMB8_MGT_BUF_UNF_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB8_MGT_BUF_UNF_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB8_CLK_CORR_ADD_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"091";
    constant REG_LINKS_DMB8_CLK_CORR_ADD_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB8_CLK_CORR_ADD_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB8_CLK_CORR_DROP_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"091";
    constant REG_LINKS_DMB8_CLK_CORR_DROP_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB8_CLK_CORR_DROP_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB8_NOT_IN_TABLE_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"092";
    constant REG_LINKS_DMB8_NOT_IN_TABLE_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB8_NOT_IN_TABLE_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB8_DISPERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"092";
    constant REG_LINKS_DMB8_DISPERR_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB8_DISPERR_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB9_MGT_BUF_OVF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0a0";
    constant REG_LINKS_DMB9_MGT_BUF_OVF_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB9_MGT_BUF_OVF_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB9_MGT_BUF_UNF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0a0";
    constant REG_LINKS_DMB9_MGT_BUF_UNF_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB9_MGT_BUF_UNF_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB9_CLK_CORR_ADD_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0a1";
    constant REG_LINKS_DMB9_CLK_CORR_ADD_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB9_CLK_CORR_ADD_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB9_CLK_CORR_DROP_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0a1";
    constant REG_LINKS_DMB9_CLK_CORR_DROP_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB9_CLK_CORR_DROP_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB9_NOT_IN_TABLE_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0a2";
    constant REG_LINKS_DMB9_NOT_IN_TABLE_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB9_NOT_IN_TABLE_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB9_DISPERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0a2";
    constant REG_LINKS_DMB9_DISPERR_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB9_DISPERR_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB10_MGT_BUF_OVF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0b0";
    constant REG_LINKS_DMB10_MGT_BUF_OVF_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB10_MGT_BUF_OVF_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB10_MGT_BUF_UNF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0b0";
    constant REG_LINKS_DMB10_MGT_BUF_UNF_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB10_MGT_BUF_UNF_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB10_CLK_CORR_ADD_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0b1";
    constant REG_LINKS_DMB10_CLK_CORR_ADD_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB10_CLK_CORR_ADD_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB10_CLK_CORR_DROP_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0b1";
    constant REG_LINKS_DMB10_CLK_CORR_DROP_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB10_CLK_CORR_DROP_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB10_NOT_IN_TABLE_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0b2";
    constant REG_LINKS_DMB10_NOT_IN_TABLE_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB10_NOT_IN_TABLE_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB10_DISPERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0b2";
    constant REG_LINKS_DMB10_DISPERR_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB10_DISPERR_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB11_MGT_BUF_OVF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0c0";
    constant REG_LINKS_DMB11_MGT_BUF_OVF_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB11_MGT_BUF_OVF_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB11_MGT_BUF_UNF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0c0";
    constant REG_LINKS_DMB11_MGT_BUF_UNF_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB11_MGT_BUF_UNF_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB11_CLK_CORR_ADD_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0c1";
    constant REG_LINKS_DMB11_CLK_CORR_ADD_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB11_CLK_CORR_ADD_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB11_CLK_CORR_DROP_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0c1";
    constant REG_LINKS_DMB11_CLK_CORR_DROP_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB11_CLK_CORR_DROP_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB11_NOT_IN_TABLE_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0c2";
    constant REG_LINKS_DMB11_NOT_IN_TABLE_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB11_NOT_IN_TABLE_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB11_DISPERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0c2";
    constant REG_LINKS_DMB11_DISPERR_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB11_DISPERR_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB12_MGT_BUF_OVF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0d0";
    constant REG_LINKS_DMB12_MGT_BUF_OVF_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB12_MGT_BUF_OVF_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB12_MGT_BUF_UNF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0d0";
    constant REG_LINKS_DMB12_MGT_BUF_UNF_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB12_MGT_BUF_UNF_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB12_CLK_CORR_ADD_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0d1";
    constant REG_LINKS_DMB12_CLK_CORR_ADD_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB12_CLK_CORR_ADD_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB12_CLK_CORR_DROP_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0d1";
    constant REG_LINKS_DMB12_CLK_CORR_DROP_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB12_CLK_CORR_DROP_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB12_NOT_IN_TABLE_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0d2";
    constant REG_LINKS_DMB12_NOT_IN_TABLE_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB12_NOT_IN_TABLE_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB12_DISPERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0d2";
    constant REG_LINKS_DMB12_DISPERR_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB12_DISPERR_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB13_MGT_BUF_OVF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0e0";
    constant REG_LINKS_DMB13_MGT_BUF_OVF_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB13_MGT_BUF_OVF_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB13_MGT_BUF_UNF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0e0";
    constant REG_LINKS_DMB13_MGT_BUF_UNF_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB13_MGT_BUF_UNF_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB13_CLK_CORR_ADD_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0e1";
    constant REG_LINKS_DMB13_CLK_CORR_ADD_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB13_CLK_CORR_ADD_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB13_CLK_CORR_DROP_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0e1";
    constant REG_LINKS_DMB13_CLK_CORR_DROP_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB13_CLK_CORR_DROP_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB13_NOT_IN_TABLE_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0e2";
    constant REG_LINKS_DMB13_NOT_IN_TABLE_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB13_NOT_IN_TABLE_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB13_DISPERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0e2";
    constant REG_LINKS_DMB13_DISPERR_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB13_DISPERR_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB14_MGT_BUF_OVF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0f0";
    constant REG_LINKS_DMB14_MGT_BUF_OVF_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB14_MGT_BUF_OVF_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB14_MGT_BUF_UNF_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0f0";
    constant REG_LINKS_DMB14_MGT_BUF_UNF_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB14_MGT_BUF_UNF_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB14_CLK_CORR_ADD_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0f1";
    constant REG_LINKS_DMB14_CLK_CORR_ADD_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB14_CLK_CORR_ADD_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB14_CLK_CORR_DROP_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0f1";
    constant REG_LINKS_DMB14_CLK_CORR_DROP_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB14_CLK_CORR_DROP_CNT_LSB     : integer := 16;

    constant REG_LINKS_DMB14_NOT_IN_TABLE_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0f2";
    constant REG_LINKS_DMB14_NOT_IN_TABLE_CNT_MSB    : integer := 15;
    constant REG_LINKS_DMB14_NOT_IN_TABLE_CNT_LSB     : integer := 0;

    constant REG_LINKS_DMB14_DISPERR_CNT_ADDR    : std_logic_vector(12 downto 0) := '0' & x"0f2";
    constant REG_LINKS_DMB14_DISPERR_CNT_MSB    : integer := 31;
    constant REG_LINKS_DMB14_DISPERR_CNT_LSB     : integer := 16;

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


    --============================================================================
    --       >>> DAQ Module <<<    base address: 0x00400000
    --
    -- DAQ module buffers track data, builds events, analyses the data for
    -- consistency and ships off the events with all the needed headers and
    -- trailers to AMC13 over DAQLink
    --============================================================================

    constant REG_DAQ_NUM_REGS : integer := 91;
    constant REG_DAQ_ADDRESS_MSB : integer := 8;
    constant REG_DAQ_ADDRESS_LSB : integer := 0;
    constant REG_DAQ_CONTROL_DAQ_ENABLE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"00";
    constant REG_DAQ_CONTROL_DAQ_ENABLE_BIT    : integer := 0;
    constant REG_DAQ_CONTROL_DAQ_ENABLE_DEFAULT : std_logic := '0';

    constant REG_DAQ_CONTROL_IGNORE_AMC13_ADDR    : std_logic_vector(8 downto 0) := '0' & x"00";
    constant REG_DAQ_CONTROL_IGNORE_AMC13_BIT    : integer := 1;
    constant REG_DAQ_CONTROL_IGNORE_AMC13_DEFAULT : std_logic := '0';

    constant REG_DAQ_CONTROL_DAQ_LINK_RESET_ADDR    : std_logic_vector(8 downto 0) := '0' & x"00";
    constant REG_DAQ_CONTROL_DAQ_LINK_RESET_BIT    : integer := 2;
    constant REG_DAQ_CONTROL_DAQ_LINK_RESET_DEFAULT : std_logic := '0';

    constant REG_DAQ_CONTROL_RESET_ADDR    : std_logic_vector(8 downto 0) := '0' & x"00";
    constant REG_DAQ_CONTROL_RESET_BIT    : integer := 3;
    constant REG_DAQ_CONTROL_RESET_DEFAULT : std_logic := '0';

    constant REG_DAQ_CONTROL_TTS_OVERRIDE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"00";
    constant REG_DAQ_CONTROL_TTS_OVERRIDE_MSB    : integer := 7;
    constant REG_DAQ_CONTROL_TTS_OVERRIDE_LSB     : integer := 4;
    constant REG_DAQ_CONTROL_TTS_OVERRIDE_DEFAULT : std_logic_vector(7 downto 4) := x"0";

    constant REG_DAQ_CONTROL_INPUT_ENABLE_MASK_ADDR    : std_logic_vector(8 downto 0) := '0' & x"00";
    constant REG_DAQ_CONTROL_INPUT_ENABLE_MASK_MSB    : integer := 31;
    constant REG_DAQ_CONTROL_INPUT_ENABLE_MASK_LSB     : integer := 8;
    constant REG_DAQ_CONTROL_INPUT_ENABLE_MASK_DEFAULT : std_logic_vector(31 downto 8) := x"000001";

    constant REG_DAQ_STATUS_DAQ_LINK_RDY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_DAQ_LINK_RDY_BIT    : integer := 0;

    constant REG_DAQ_STATUS_DAQ_CLK_LOCKED_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_DAQ_CLK_LOCKED_BIT    : integer := 1;

    constant REG_DAQ_STATUS_TTC_RDY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_TTC_RDY_BIT    : integer := 2;

    constant REG_DAQ_STATUS_DAQ_LINK_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_DAQ_LINK_AFULL_BIT    : integer := 3;

    constant REG_DAQ_STATUS_DAQ_OUTPUT_FIFO_HAD_OVERFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_DAQ_OUTPUT_FIFO_HAD_OVERFLOW_BIT    : integer := 4;

    constant REG_DAQ_STATUS_TTC_BC0_LOCKED_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_TTC_BC0_LOCKED_BIT    : integer := 5;

    constant REG_DAQ_STATUS_L1A_FIFO_HAD_OVERFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_L1A_FIFO_HAD_OVERFLOW_BIT    : integer := 23;

    constant REG_DAQ_STATUS_L1A_FIFO_IS_UNDERFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_L1A_FIFO_IS_UNDERFLOW_BIT    : integer := 24;

    constant REG_DAQ_STATUS_L1A_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_L1A_FIFO_IS_FULL_BIT    : integer := 25;

    constant REG_DAQ_STATUS_L1A_FIFO_IS_NEAR_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_L1A_FIFO_IS_NEAR_FULL_BIT    : integer := 26;

    constant REG_DAQ_STATUS_L1A_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_L1A_FIFO_IS_EMPTY_BIT    : integer := 27;

    constant REG_DAQ_STATUS_TTS_STATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"01";
    constant REG_DAQ_STATUS_TTS_STATE_MSB    : integer := 31;
    constant REG_DAQ_STATUS_TTS_STATE_LSB     : integer := 28;

    constant REG_DAQ_EXT_STATUS_NOTINTABLE_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"02";
    constant REG_DAQ_EXT_STATUS_NOTINTABLE_ERR_MSB    : integer := 15;
    constant REG_DAQ_EXT_STATUS_NOTINTABLE_ERR_LSB     : integer := 0;

    constant REG_DAQ_EXT_STATUS_DISPER_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"03";
    constant REG_DAQ_EXT_STATUS_DISPER_ERR_MSB    : integer := 15;
    constant REG_DAQ_EXT_STATUS_DISPER_ERR_LSB     : integer := 0;

    constant REG_DAQ_EXT_STATUS_L1AID_ADDR    : std_logic_vector(8 downto 0) := '0' & x"04";
    constant REG_DAQ_EXT_STATUS_L1AID_MSB    : integer := 23;
    constant REG_DAQ_EXT_STATUS_L1AID_LSB     : integer := 0;

    constant REG_DAQ_EXT_STATUS_EVT_SENT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"05";
    constant REG_DAQ_EXT_STATUS_EVT_SENT_MSB    : integer := 31;
    constant REG_DAQ_EXT_STATUS_EVT_SENT_LSB     : integer := 0;

    constant REG_DAQ_CONTROL_DAV_TIMEOUT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"06";
    constant REG_DAQ_CONTROL_DAV_TIMEOUT_MSB    : integer := 23;
    constant REG_DAQ_CONTROL_DAV_TIMEOUT_LSB     : integer := 0;
    constant REG_DAQ_CONTROL_DAV_TIMEOUT_DEFAULT : std_logic_vector(23 downto 0) := x"03d090";

    constant REG_DAQ_CONTROL_FREEZE_ON_ERROR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"06";
    constant REG_DAQ_CONTROL_FREEZE_ON_ERROR_BIT    : integer := 24;
    constant REG_DAQ_CONTROL_FREEZE_ON_ERROR_DEFAULT : std_logic := '0';

    constant REG_DAQ_CONTROL_RESET_TILL_RESYNC_ADDR    : std_logic_vector(8 downto 0) := '0' & x"06";
    constant REG_DAQ_CONTROL_RESET_TILL_RESYNC_BIT    : integer := 25;
    constant REG_DAQ_CONTROL_RESET_TILL_RESYNC_DEFAULT : std_logic := '0';

    constant REG_DAQ_EXT_STATUS_MAX_DAV_TIMER_ADDR    : std_logic_vector(8 downto 0) := '0' & x"07";
    constant REG_DAQ_EXT_STATUS_MAX_DAV_TIMER_MSB    : integer := 23;
    constant REG_DAQ_EXT_STATUS_MAX_DAV_TIMER_LSB     : integer := 0;

    constant REG_DAQ_EXT_STATUS_LAST_DAV_TIMER_ADDR    : std_logic_vector(8 downto 0) := '0' & x"08";
    constant REG_DAQ_EXT_STATUS_LAST_DAV_TIMER_MSB    : integer := 23;
    constant REG_DAQ_EXT_STATUS_LAST_DAV_TIMER_LSB     : integer := 0;

    constant REG_DAQ_EXT_STATUS_L1A_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"09";
    constant REG_DAQ_EXT_STATUS_L1A_FIFO_DATA_CNT_MSB    : integer := 12;
    constant REG_DAQ_EXT_STATUS_L1A_FIFO_DATA_CNT_LSB     : integer := 0;

    constant REG_DAQ_EXT_STATUS_DAQ_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"09";
    constant REG_DAQ_EXT_STATUS_DAQ_FIFO_DATA_CNT_MSB    : integer := 28;
    constant REG_DAQ_EXT_STATUS_DAQ_FIFO_DATA_CNT_LSB     : integer := 16;

    constant REG_DAQ_EXT_STATUS_L1A_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"0a";
    constant REG_DAQ_EXT_STATUS_L1A_FIFO_NEAR_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_EXT_STATUS_L1A_FIFO_NEAR_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_EXT_STATUS_DAQ_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"0a";
    constant REG_DAQ_EXT_STATUS_DAQ_FIFO_NEAR_FULL_CNT_MSB    : integer := 31;
    constant REG_DAQ_EXT_STATUS_DAQ_FIFO_NEAR_FULL_CNT_LSB     : integer := 16;

    constant REG_DAQ_EXT_STATUS_DAQ_ALMOST_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"0b";
    constant REG_DAQ_EXT_STATUS_DAQ_ALMOST_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_EXT_STATUS_DAQ_ALMOST_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_EXT_STATUS_TTS_WARN_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"0b";
    constant REG_DAQ_EXT_STATUS_TTS_WARN_CNT_MSB    : integer := 31;
    constant REG_DAQ_EXT_STATUS_TTS_WARN_CNT_LSB     : integer := 16;

    constant REG_DAQ_EXT_STATUS_DAQ_WORD_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"0c";
    constant REG_DAQ_EXT_STATUS_DAQ_WORD_RATE_MSB    : integer := 31;
    constant REG_DAQ_EXT_STATUS_DAQ_WORD_RATE_LSB     : integer := 0;

    constant REG_DAQ_EXT_CONTROL_RUN_PARAMS_ADDR    : std_logic_vector(8 downto 0) := '0' & x"0d";
    constant REG_DAQ_EXT_CONTROL_RUN_PARAMS_MSB    : integer := 23;
    constant REG_DAQ_EXT_CONTROL_RUN_PARAMS_LSB     : integer := 0;
    constant REG_DAQ_EXT_CONTROL_RUN_PARAMS_DEFAULT : std_logic_vector(23 downto 0) := x"000000";

    constant REG_DAQ_EXT_CONTROL_RUN_TYPE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"0d";
    constant REG_DAQ_EXT_CONTROL_RUN_TYPE_MSB    : integer := 27;
    constant REG_DAQ_EXT_CONTROL_RUN_TYPE_LSB     : integer := 24;
    constant REG_DAQ_EXT_CONTROL_RUN_TYPE_DEFAULT : std_logic_vector(27 downto 24) := x"0";

    constant REG_DAQ_LAST_EVENT_FIFO_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"0e";
    constant REG_DAQ_LAST_EVENT_FIFO_EMPTY_BIT    : integer := 0;

    constant REG_DAQ_LAST_EVENT_FIFO_DISABLE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"0e";
    constant REG_DAQ_LAST_EVENT_FIFO_DISABLE_BIT    : integer := 31;
    constant REG_DAQ_LAST_EVENT_FIFO_DISABLE_DEFAULT : std_logic := '0';

    constant REG_DAQ_LAST_EVENT_FIFO_DATA_ADDR    : std_logic_vector(8 downto 0) := '0' & x"0f";
    constant REG_DAQ_LAST_EVENT_FIFO_DATA_MSB    : integer := 31;
    constant REG_DAQ_LAST_EVENT_FIFO_DATA_LSB     : integer := 0;

    constant REG_DAQ_DMB0_STATUS_EVT_64BIT_ALIGN_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_DMB0_STATUS_EVT_64BIT_ALIGN_ERR_BIT    : integer := 0;

    constant REG_DAQ_DMB0_STATUS_INPUT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_DMB0_STATUS_INPUT_FIFO_HAD_OFLOW_BIT    : integer := 8;

    constant REG_DAQ_DMB0_STATUS_INPUT_FIFO_HAD_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_DMB0_STATUS_INPUT_FIFO_HAD_UFLOW_BIT    : integer := 9;

    constant REG_DAQ_DMB0_STATUS_EVENT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_DMB0_STATUS_EVENT_FIFO_HAD_OFLOW_BIT    : integer := 10;

    constant REG_DAQ_DMB0_STATUS_EVT_SIZE_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_DMB0_STATUS_EVT_SIZE_ERR_BIT    : integer := 11;

    constant REG_DAQ_DMB0_STATUS_TTS_STATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_DMB0_STATUS_TTS_STATE_MSB    : integer := 15;
    constant REG_DAQ_DMB0_STATUS_TTS_STATE_LSB     : integer := 12;

    constant REG_DAQ_DMB0_STATUS_INPUT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_DMB0_STATUS_INPUT_FIFO_IS_UFLOW_BIT    : integer := 24;

    constant REG_DAQ_DMB0_STATUS_INPUT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_DMB0_STATUS_INPUT_FIFO_IS_FULL_BIT    : integer := 25;

    constant REG_DAQ_DMB0_STATUS_INPUT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_DMB0_STATUS_INPUT_FIFO_IS_AFULL_BIT    : integer := 26;

    constant REG_DAQ_DMB0_STATUS_INPUT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_DMB0_STATUS_INPUT_FIFO_IS_EMPTY_BIT    : integer := 27;

    constant REG_DAQ_DMB0_STATUS_EVENT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_DMB0_STATUS_EVENT_FIFO_IS_UFLOW_BIT    : integer := 28;

    constant REG_DAQ_DMB0_STATUS_EVENT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_DMB0_STATUS_EVENT_FIFO_IS_FULL_BIT    : integer := 29;

    constant REG_DAQ_DMB0_STATUS_EVENT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_DMB0_STATUS_EVENT_FIFO_IS_AFULL_BIT    : integer := 30;

    constant REG_DAQ_DMB0_STATUS_EVENT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"10";
    constant REG_DAQ_DMB0_STATUS_EVENT_FIFO_IS_EMPTY_BIT    : integer := 31;

    constant REG_DAQ_DMB0_COUNTERS_EVN_ADDR    : std_logic_vector(8 downto 0) := '0' & x"12";
    constant REG_DAQ_DMB0_COUNTERS_EVN_MSB    : integer := 23;
    constant REG_DAQ_DMB0_COUNTERS_EVN_LSB     : integer := 0;

    constant REG_DAQ_DMB0_COUNTERS_INPUT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"14";
    constant REG_DAQ_DMB0_COUNTERS_INPUT_FIFO_DATA_CNT_MSB    : integer := 13;
    constant REG_DAQ_DMB0_COUNTERS_INPUT_FIFO_DATA_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB0_COUNTERS_EVT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"14";
    constant REG_DAQ_DMB0_COUNTERS_EVT_FIFO_DATA_CNT_MSB    : integer := 27;
    constant REG_DAQ_DMB0_COUNTERS_EVT_FIFO_DATA_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB0_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"15";
    constant REG_DAQ_DMB0_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_DMB0_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB0_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"15";
    constant REG_DAQ_DMB0_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB    : integer := 31;
    constant REG_DAQ_DMB0_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB0_COUNTERS_DATA_WORD_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"16";
    constant REG_DAQ_DMB0_COUNTERS_DATA_WORD_RATE_MSB    : integer := 14;
    constant REG_DAQ_DMB0_COUNTERS_DATA_WORD_RATE_LSB     : integer := 0;

    constant REG_DAQ_DMB0_COUNTERS_EVT_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"16";
    constant REG_DAQ_DMB0_COUNTERS_EVT_RATE_MSB    : integer := 31;
    constant REG_DAQ_DMB0_COUNTERS_EVT_RATE_LSB     : integer := 15;

    constant REG_DAQ_DMB1_STATUS_EVT_64BIT_ALIGN_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_DMB1_STATUS_EVT_64BIT_ALIGN_ERR_BIT    : integer := 0;

    constant REG_DAQ_DMB1_STATUS_INPUT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_DMB1_STATUS_INPUT_FIFO_HAD_OFLOW_BIT    : integer := 8;

    constant REG_DAQ_DMB1_STATUS_INPUT_FIFO_HAD_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_DMB1_STATUS_INPUT_FIFO_HAD_UFLOW_BIT    : integer := 9;

    constant REG_DAQ_DMB1_STATUS_EVENT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_DMB1_STATUS_EVENT_FIFO_HAD_OFLOW_BIT    : integer := 10;

    constant REG_DAQ_DMB1_STATUS_EVT_SIZE_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_DMB1_STATUS_EVT_SIZE_ERR_BIT    : integer := 11;

    constant REG_DAQ_DMB1_STATUS_TTS_STATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_DMB1_STATUS_TTS_STATE_MSB    : integer := 15;
    constant REG_DAQ_DMB1_STATUS_TTS_STATE_LSB     : integer := 12;

    constant REG_DAQ_DMB1_STATUS_INPUT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_DMB1_STATUS_INPUT_FIFO_IS_UFLOW_BIT    : integer := 24;

    constant REG_DAQ_DMB1_STATUS_INPUT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_DMB1_STATUS_INPUT_FIFO_IS_FULL_BIT    : integer := 25;

    constant REG_DAQ_DMB1_STATUS_INPUT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_DMB1_STATUS_INPUT_FIFO_IS_AFULL_BIT    : integer := 26;

    constant REG_DAQ_DMB1_STATUS_INPUT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_DMB1_STATUS_INPUT_FIFO_IS_EMPTY_BIT    : integer := 27;

    constant REG_DAQ_DMB1_STATUS_EVENT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_DMB1_STATUS_EVENT_FIFO_IS_UFLOW_BIT    : integer := 28;

    constant REG_DAQ_DMB1_STATUS_EVENT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_DMB1_STATUS_EVENT_FIFO_IS_FULL_BIT    : integer := 29;

    constant REG_DAQ_DMB1_STATUS_EVENT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_DMB1_STATUS_EVENT_FIFO_IS_AFULL_BIT    : integer := 30;

    constant REG_DAQ_DMB1_STATUS_EVENT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"20";
    constant REG_DAQ_DMB1_STATUS_EVENT_FIFO_IS_EMPTY_BIT    : integer := 31;

    constant REG_DAQ_DMB1_COUNTERS_EVN_ADDR    : std_logic_vector(8 downto 0) := '0' & x"22";
    constant REG_DAQ_DMB1_COUNTERS_EVN_MSB    : integer := 23;
    constant REG_DAQ_DMB1_COUNTERS_EVN_LSB     : integer := 0;

    constant REG_DAQ_DMB1_COUNTERS_INPUT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"24";
    constant REG_DAQ_DMB1_COUNTERS_INPUT_FIFO_DATA_CNT_MSB    : integer := 13;
    constant REG_DAQ_DMB1_COUNTERS_INPUT_FIFO_DATA_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB1_COUNTERS_EVT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"24";
    constant REG_DAQ_DMB1_COUNTERS_EVT_FIFO_DATA_CNT_MSB    : integer := 27;
    constant REG_DAQ_DMB1_COUNTERS_EVT_FIFO_DATA_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB1_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"25";
    constant REG_DAQ_DMB1_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_DMB1_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB1_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"25";
    constant REG_DAQ_DMB1_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB    : integer := 31;
    constant REG_DAQ_DMB1_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB1_COUNTERS_DATA_WORD_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"26";
    constant REG_DAQ_DMB1_COUNTERS_DATA_WORD_RATE_MSB    : integer := 14;
    constant REG_DAQ_DMB1_COUNTERS_DATA_WORD_RATE_LSB     : integer := 0;

    constant REG_DAQ_DMB1_COUNTERS_EVT_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"26";
    constant REG_DAQ_DMB1_COUNTERS_EVT_RATE_MSB    : integer := 31;
    constant REG_DAQ_DMB1_COUNTERS_EVT_RATE_LSB     : integer := 15;

    constant REG_DAQ_DMB2_STATUS_EVT_64BIT_ALIGN_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"30";
    constant REG_DAQ_DMB2_STATUS_EVT_64BIT_ALIGN_ERR_BIT    : integer := 0;

    constant REG_DAQ_DMB2_STATUS_INPUT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"30";
    constant REG_DAQ_DMB2_STATUS_INPUT_FIFO_HAD_OFLOW_BIT    : integer := 8;

    constant REG_DAQ_DMB2_STATUS_INPUT_FIFO_HAD_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"30";
    constant REG_DAQ_DMB2_STATUS_INPUT_FIFO_HAD_UFLOW_BIT    : integer := 9;

    constant REG_DAQ_DMB2_STATUS_EVENT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"30";
    constant REG_DAQ_DMB2_STATUS_EVENT_FIFO_HAD_OFLOW_BIT    : integer := 10;

    constant REG_DAQ_DMB2_STATUS_EVT_SIZE_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"30";
    constant REG_DAQ_DMB2_STATUS_EVT_SIZE_ERR_BIT    : integer := 11;

    constant REG_DAQ_DMB2_STATUS_TTS_STATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"30";
    constant REG_DAQ_DMB2_STATUS_TTS_STATE_MSB    : integer := 15;
    constant REG_DAQ_DMB2_STATUS_TTS_STATE_LSB     : integer := 12;

    constant REG_DAQ_DMB2_STATUS_INPUT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"30";
    constant REG_DAQ_DMB2_STATUS_INPUT_FIFO_IS_UFLOW_BIT    : integer := 24;

    constant REG_DAQ_DMB2_STATUS_INPUT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"30";
    constant REG_DAQ_DMB2_STATUS_INPUT_FIFO_IS_FULL_BIT    : integer := 25;

    constant REG_DAQ_DMB2_STATUS_INPUT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"30";
    constant REG_DAQ_DMB2_STATUS_INPUT_FIFO_IS_AFULL_BIT    : integer := 26;

    constant REG_DAQ_DMB2_STATUS_INPUT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"30";
    constant REG_DAQ_DMB2_STATUS_INPUT_FIFO_IS_EMPTY_BIT    : integer := 27;

    constant REG_DAQ_DMB2_STATUS_EVENT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"30";
    constant REG_DAQ_DMB2_STATUS_EVENT_FIFO_IS_UFLOW_BIT    : integer := 28;

    constant REG_DAQ_DMB2_STATUS_EVENT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"30";
    constant REG_DAQ_DMB2_STATUS_EVENT_FIFO_IS_FULL_BIT    : integer := 29;

    constant REG_DAQ_DMB2_STATUS_EVENT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"30";
    constant REG_DAQ_DMB2_STATUS_EVENT_FIFO_IS_AFULL_BIT    : integer := 30;

    constant REG_DAQ_DMB2_STATUS_EVENT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"30";
    constant REG_DAQ_DMB2_STATUS_EVENT_FIFO_IS_EMPTY_BIT    : integer := 31;

    constant REG_DAQ_DMB2_COUNTERS_EVN_ADDR    : std_logic_vector(8 downto 0) := '0' & x"32";
    constant REG_DAQ_DMB2_COUNTERS_EVN_MSB    : integer := 23;
    constant REG_DAQ_DMB2_COUNTERS_EVN_LSB     : integer := 0;

    constant REG_DAQ_DMB2_COUNTERS_INPUT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"34";
    constant REG_DAQ_DMB2_COUNTERS_INPUT_FIFO_DATA_CNT_MSB    : integer := 13;
    constant REG_DAQ_DMB2_COUNTERS_INPUT_FIFO_DATA_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB2_COUNTERS_EVT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"34";
    constant REG_DAQ_DMB2_COUNTERS_EVT_FIFO_DATA_CNT_MSB    : integer := 27;
    constant REG_DAQ_DMB2_COUNTERS_EVT_FIFO_DATA_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB2_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"35";
    constant REG_DAQ_DMB2_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_DMB2_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB2_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"35";
    constant REG_DAQ_DMB2_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB    : integer := 31;
    constant REG_DAQ_DMB2_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB2_COUNTERS_DATA_WORD_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"36";
    constant REG_DAQ_DMB2_COUNTERS_DATA_WORD_RATE_MSB    : integer := 14;
    constant REG_DAQ_DMB2_COUNTERS_DATA_WORD_RATE_LSB     : integer := 0;

    constant REG_DAQ_DMB2_COUNTERS_EVT_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"36";
    constant REG_DAQ_DMB2_COUNTERS_EVT_RATE_MSB    : integer := 31;
    constant REG_DAQ_DMB2_COUNTERS_EVT_RATE_LSB     : integer := 15;

    constant REG_DAQ_DMB3_STATUS_EVT_64BIT_ALIGN_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"40";
    constant REG_DAQ_DMB3_STATUS_EVT_64BIT_ALIGN_ERR_BIT    : integer := 0;

    constant REG_DAQ_DMB3_STATUS_INPUT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"40";
    constant REG_DAQ_DMB3_STATUS_INPUT_FIFO_HAD_OFLOW_BIT    : integer := 8;

    constant REG_DAQ_DMB3_STATUS_INPUT_FIFO_HAD_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"40";
    constant REG_DAQ_DMB3_STATUS_INPUT_FIFO_HAD_UFLOW_BIT    : integer := 9;

    constant REG_DAQ_DMB3_STATUS_EVENT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"40";
    constant REG_DAQ_DMB3_STATUS_EVENT_FIFO_HAD_OFLOW_BIT    : integer := 10;

    constant REG_DAQ_DMB3_STATUS_EVT_SIZE_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"40";
    constant REG_DAQ_DMB3_STATUS_EVT_SIZE_ERR_BIT    : integer := 11;

    constant REG_DAQ_DMB3_STATUS_TTS_STATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"40";
    constant REG_DAQ_DMB3_STATUS_TTS_STATE_MSB    : integer := 15;
    constant REG_DAQ_DMB3_STATUS_TTS_STATE_LSB     : integer := 12;

    constant REG_DAQ_DMB3_STATUS_INPUT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"40";
    constant REG_DAQ_DMB3_STATUS_INPUT_FIFO_IS_UFLOW_BIT    : integer := 24;

    constant REG_DAQ_DMB3_STATUS_INPUT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"40";
    constant REG_DAQ_DMB3_STATUS_INPUT_FIFO_IS_FULL_BIT    : integer := 25;

    constant REG_DAQ_DMB3_STATUS_INPUT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"40";
    constant REG_DAQ_DMB3_STATUS_INPUT_FIFO_IS_AFULL_BIT    : integer := 26;

    constant REG_DAQ_DMB3_STATUS_INPUT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"40";
    constant REG_DAQ_DMB3_STATUS_INPUT_FIFO_IS_EMPTY_BIT    : integer := 27;

    constant REG_DAQ_DMB3_STATUS_EVENT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"40";
    constant REG_DAQ_DMB3_STATUS_EVENT_FIFO_IS_UFLOW_BIT    : integer := 28;

    constant REG_DAQ_DMB3_STATUS_EVENT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"40";
    constant REG_DAQ_DMB3_STATUS_EVENT_FIFO_IS_FULL_BIT    : integer := 29;

    constant REG_DAQ_DMB3_STATUS_EVENT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"40";
    constant REG_DAQ_DMB3_STATUS_EVENT_FIFO_IS_AFULL_BIT    : integer := 30;

    constant REG_DAQ_DMB3_STATUS_EVENT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"40";
    constant REG_DAQ_DMB3_STATUS_EVENT_FIFO_IS_EMPTY_BIT    : integer := 31;

    constant REG_DAQ_DMB3_COUNTERS_EVN_ADDR    : std_logic_vector(8 downto 0) := '0' & x"42";
    constant REG_DAQ_DMB3_COUNTERS_EVN_MSB    : integer := 23;
    constant REG_DAQ_DMB3_COUNTERS_EVN_LSB     : integer := 0;

    constant REG_DAQ_DMB3_COUNTERS_INPUT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"44";
    constant REG_DAQ_DMB3_COUNTERS_INPUT_FIFO_DATA_CNT_MSB    : integer := 13;
    constant REG_DAQ_DMB3_COUNTERS_INPUT_FIFO_DATA_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB3_COUNTERS_EVT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"44";
    constant REG_DAQ_DMB3_COUNTERS_EVT_FIFO_DATA_CNT_MSB    : integer := 27;
    constant REG_DAQ_DMB3_COUNTERS_EVT_FIFO_DATA_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB3_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"45";
    constant REG_DAQ_DMB3_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_DMB3_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB3_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"45";
    constant REG_DAQ_DMB3_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB    : integer := 31;
    constant REG_DAQ_DMB3_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB3_COUNTERS_DATA_WORD_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"46";
    constant REG_DAQ_DMB3_COUNTERS_DATA_WORD_RATE_MSB    : integer := 14;
    constant REG_DAQ_DMB3_COUNTERS_DATA_WORD_RATE_LSB     : integer := 0;

    constant REG_DAQ_DMB3_COUNTERS_EVT_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"46";
    constant REG_DAQ_DMB3_COUNTERS_EVT_RATE_MSB    : integer := 31;
    constant REG_DAQ_DMB3_COUNTERS_EVT_RATE_LSB     : integer := 15;

    constant REG_DAQ_DMB4_STATUS_EVT_64BIT_ALIGN_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"50";
    constant REG_DAQ_DMB4_STATUS_EVT_64BIT_ALIGN_ERR_BIT    : integer := 0;

    constant REG_DAQ_DMB4_STATUS_INPUT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"50";
    constant REG_DAQ_DMB4_STATUS_INPUT_FIFO_HAD_OFLOW_BIT    : integer := 8;

    constant REG_DAQ_DMB4_STATUS_INPUT_FIFO_HAD_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"50";
    constant REG_DAQ_DMB4_STATUS_INPUT_FIFO_HAD_UFLOW_BIT    : integer := 9;

    constant REG_DAQ_DMB4_STATUS_EVENT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"50";
    constant REG_DAQ_DMB4_STATUS_EVENT_FIFO_HAD_OFLOW_BIT    : integer := 10;

    constant REG_DAQ_DMB4_STATUS_EVT_SIZE_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"50";
    constant REG_DAQ_DMB4_STATUS_EVT_SIZE_ERR_BIT    : integer := 11;

    constant REG_DAQ_DMB4_STATUS_TTS_STATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"50";
    constant REG_DAQ_DMB4_STATUS_TTS_STATE_MSB    : integer := 15;
    constant REG_DAQ_DMB4_STATUS_TTS_STATE_LSB     : integer := 12;

    constant REG_DAQ_DMB4_STATUS_INPUT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"50";
    constant REG_DAQ_DMB4_STATUS_INPUT_FIFO_IS_UFLOW_BIT    : integer := 24;

    constant REG_DAQ_DMB4_STATUS_INPUT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"50";
    constant REG_DAQ_DMB4_STATUS_INPUT_FIFO_IS_FULL_BIT    : integer := 25;

    constant REG_DAQ_DMB4_STATUS_INPUT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"50";
    constant REG_DAQ_DMB4_STATUS_INPUT_FIFO_IS_AFULL_BIT    : integer := 26;

    constant REG_DAQ_DMB4_STATUS_INPUT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"50";
    constant REG_DAQ_DMB4_STATUS_INPUT_FIFO_IS_EMPTY_BIT    : integer := 27;

    constant REG_DAQ_DMB4_STATUS_EVENT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"50";
    constant REG_DAQ_DMB4_STATUS_EVENT_FIFO_IS_UFLOW_BIT    : integer := 28;

    constant REG_DAQ_DMB4_STATUS_EVENT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"50";
    constant REG_DAQ_DMB4_STATUS_EVENT_FIFO_IS_FULL_BIT    : integer := 29;

    constant REG_DAQ_DMB4_STATUS_EVENT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"50";
    constant REG_DAQ_DMB4_STATUS_EVENT_FIFO_IS_AFULL_BIT    : integer := 30;

    constant REG_DAQ_DMB4_STATUS_EVENT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"50";
    constant REG_DAQ_DMB4_STATUS_EVENT_FIFO_IS_EMPTY_BIT    : integer := 31;

    constant REG_DAQ_DMB4_COUNTERS_EVN_ADDR    : std_logic_vector(8 downto 0) := '0' & x"52";
    constant REG_DAQ_DMB4_COUNTERS_EVN_MSB    : integer := 23;
    constant REG_DAQ_DMB4_COUNTERS_EVN_LSB     : integer := 0;

    constant REG_DAQ_DMB4_COUNTERS_INPUT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"54";
    constant REG_DAQ_DMB4_COUNTERS_INPUT_FIFO_DATA_CNT_MSB    : integer := 13;
    constant REG_DAQ_DMB4_COUNTERS_INPUT_FIFO_DATA_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB4_COUNTERS_EVT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"54";
    constant REG_DAQ_DMB4_COUNTERS_EVT_FIFO_DATA_CNT_MSB    : integer := 27;
    constant REG_DAQ_DMB4_COUNTERS_EVT_FIFO_DATA_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB4_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"55";
    constant REG_DAQ_DMB4_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_DMB4_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB4_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"55";
    constant REG_DAQ_DMB4_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB    : integer := 31;
    constant REG_DAQ_DMB4_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB4_COUNTERS_DATA_WORD_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"56";
    constant REG_DAQ_DMB4_COUNTERS_DATA_WORD_RATE_MSB    : integer := 14;
    constant REG_DAQ_DMB4_COUNTERS_DATA_WORD_RATE_LSB     : integer := 0;

    constant REG_DAQ_DMB4_COUNTERS_EVT_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"56";
    constant REG_DAQ_DMB4_COUNTERS_EVT_RATE_MSB    : integer := 31;
    constant REG_DAQ_DMB4_COUNTERS_EVT_RATE_LSB     : integer := 15;

    constant REG_DAQ_DMB5_STATUS_EVT_64BIT_ALIGN_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"60";
    constant REG_DAQ_DMB5_STATUS_EVT_64BIT_ALIGN_ERR_BIT    : integer := 0;

    constant REG_DAQ_DMB5_STATUS_INPUT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"60";
    constant REG_DAQ_DMB5_STATUS_INPUT_FIFO_HAD_OFLOW_BIT    : integer := 8;

    constant REG_DAQ_DMB5_STATUS_INPUT_FIFO_HAD_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"60";
    constant REG_DAQ_DMB5_STATUS_INPUT_FIFO_HAD_UFLOW_BIT    : integer := 9;

    constant REG_DAQ_DMB5_STATUS_EVENT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"60";
    constant REG_DAQ_DMB5_STATUS_EVENT_FIFO_HAD_OFLOW_BIT    : integer := 10;

    constant REG_DAQ_DMB5_STATUS_EVT_SIZE_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"60";
    constant REG_DAQ_DMB5_STATUS_EVT_SIZE_ERR_BIT    : integer := 11;

    constant REG_DAQ_DMB5_STATUS_TTS_STATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"60";
    constant REG_DAQ_DMB5_STATUS_TTS_STATE_MSB    : integer := 15;
    constant REG_DAQ_DMB5_STATUS_TTS_STATE_LSB     : integer := 12;

    constant REG_DAQ_DMB5_STATUS_INPUT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"60";
    constant REG_DAQ_DMB5_STATUS_INPUT_FIFO_IS_UFLOW_BIT    : integer := 24;

    constant REG_DAQ_DMB5_STATUS_INPUT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"60";
    constant REG_DAQ_DMB5_STATUS_INPUT_FIFO_IS_FULL_BIT    : integer := 25;

    constant REG_DAQ_DMB5_STATUS_INPUT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"60";
    constant REG_DAQ_DMB5_STATUS_INPUT_FIFO_IS_AFULL_BIT    : integer := 26;

    constant REG_DAQ_DMB5_STATUS_INPUT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"60";
    constant REG_DAQ_DMB5_STATUS_INPUT_FIFO_IS_EMPTY_BIT    : integer := 27;

    constant REG_DAQ_DMB5_STATUS_EVENT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"60";
    constant REG_DAQ_DMB5_STATUS_EVENT_FIFO_IS_UFLOW_BIT    : integer := 28;

    constant REG_DAQ_DMB5_STATUS_EVENT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"60";
    constant REG_DAQ_DMB5_STATUS_EVENT_FIFO_IS_FULL_BIT    : integer := 29;

    constant REG_DAQ_DMB5_STATUS_EVENT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"60";
    constant REG_DAQ_DMB5_STATUS_EVENT_FIFO_IS_AFULL_BIT    : integer := 30;

    constant REG_DAQ_DMB5_STATUS_EVENT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"60";
    constant REG_DAQ_DMB5_STATUS_EVENT_FIFO_IS_EMPTY_BIT    : integer := 31;

    constant REG_DAQ_DMB5_COUNTERS_EVN_ADDR    : std_logic_vector(8 downto 0) := '0' & x"62";
    constant REG_DAQ_DMB5_COUNTERS_EVN_MSB    : integer := 23;
    constant REG_DAQ_DMB5_COUNTERS_EVN_LSB     : integer := 0;

    constant REG_DAQ_DMB5_COUNTERS_INPUT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"64";
    constant REG_DAQ_DMB5_COUNTERS_INPUT_FIFO_DATA_CNT_MSB    : integer := 13;
    constant REG_DAQ_DMB5_COUNTERS_INPUT_FIFO_DATA_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB5_COUNTERS_EVT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"64";
    constant REG_DAQ_DMB5_COUNTERS_EVT_FIFO_DATA_CNT_MSB    : integer := 27;
    constant REG_DAQ_DMB5_COUNTERS_EVT_FIFO_DATA_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB5_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"65";
    constant REG_DAQ_DMB5_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_DMB5_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB5_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"65";
    constant REG_DAQ_DMB5_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB    : integer := 31;
    constant REG_DAQ_DMB5_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB5_COUNTERS_DATA_WORD_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"66";
    constant REG_DAQ_DMB5_COUNTERS_DATA_WORD_RATE_MSB    : integer := 14;
    constant REG_DAQ_DMB5_COUNTERS_DATA_WORD_RATE_LSB     : integer := 0;

    constant REG_DAQ_DMB5_COUNTERS_EVT_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"66";
    constant REG_DAQ_DMB5_COUNTERS_EVT_RATE_MSB    : integer := 31;
    constant REG_DAQ_DMB5_COUNTERS_EVT_RATE_LSB     : integer := 15;

    constant REG_DAQ_DMB6_STATUS_EVT_64BIT_ALIGN_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"70";
    constant REG_DAQ_DMB6_STATUS_EVT_64BIT_ALIGN_ERR_BIT    : integer := 0;

    constant REG_DAQ_DMB6_STATUS_INPUT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"70";
    constant REG_DAQ_DMB6_STATUS_INPUT_FIFO_HAD_OFLOW_BIT    : integer := 8;

    constant REG_DAQ_DMB6_STATUS_INPUT_FIFO_HAD_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"70";
    constant REG_DAQ_DMB6_STATUS_INPUT_FIFO_HAD_UFLOW_BIT    : integer := 9;

    constant REG_DAQ_DMB6_STATUS_EVENT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"70";
    constant REG_DAQ_DMB6_STATUS_EVENT_FIFO_HAD_OFLOW_BIT    : integer := 10;

    constant REG_DAQ_DMB6_STATUS_EVT_SIZE_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"70";
    constant REG_DAQ_DMB6_STATUS_EVT_SIZE_ERR_BIT    : integer := 11;

    constant REG_DAQ_DMB6_STATUS_TTS_STATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"70";
    constant REG_DAQ_DMB6_STATUS_TTS_STATE_MSB    : integer := 15;
    constant REG_DAQ_DMB6_STATUS_TTS_STATE_LSB     : integer := 12;

    constant REG_DAQ_DMB6_STATUS_INPUT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"70";
    constant REG_DAQ_DMB6_STATUS_INPUT_FIFO_IS_UFLOW_BIT    : integer := 24;

    constant REG_DAQ_DMB6_STATUS_INPUT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"70";
    constant REG_DAQ_DMB6_STATUS_INPUT_FIFO_IS_FULL_BIT    : integer := 25;

    constant REG_DAQ_DMB6_STATUS_INPUT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"70";
    constant REG_DAQ_DMB6_STATUS_INPUT_FIFO_IS_AFULL_BIT    : integer := 26;

    constant REG_DAQ_DMB6_STATUS_INPUT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"70";
    constant REG_DAQ_DMB6_STATUS_INPUT_FIFO_IS_EMPTY_BIT    : integer := 27;

    constant REG_DAQ_DMB6_STATUS_EVENT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"70";
    constant REG_DAQ_DMB6_STATUS_EVENT_FIFO_IS_UFLOW_BIT    : integer := 28;

    constant REG_DAQ_DMB6_STATUS_EVENT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"70";
    constant REG_DAQ_DMB6_STATUS_EVENT_FIFO_IS_FULL_BIT    : integer := 29;

    constant REG_DAQ_DMB6_STATUS_EVENT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"70";
    constant REG_DAQ_DMB6_STATUS_EVENT_FIFO_IS_AFULL_BIT    : integer := 30;

    constant REG_DAQ_DMB6_STATUS_EVENT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"70";
    constant REG_DAQ_DMB6_STATUS_EVENT_FIFO_IS_EMPTY_BIT    : integer := 31;

    constant REG_DAQ_DMB6_COUNTERS_EVN_ADDR    : std_logic_vector(8 downto 0) := '0' & x"72";
    constant REG_DAQ_DMB6_COUNTERS_EVN_MSB    : integer := 23;
    constant REG_DAQ_DMB6_COUNTERS_EVN_LSB     : integer := 0;

    constant REG_DAQ_DMB6_COUNTERS_INPUT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"74";
    constant REG_DAQ_DMB6_COUNTERS_INPUT_FIFO_DATA_CNT_MSB    : integer := 13;
    constant REG_DAQ_DMB6_COUNTERS_INPUT_FIFO_DATA_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB6_COUNTERS_EVT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"74";
    constant REG_DAQ_DMB6_COUNTERS_EVT_FIFO_DATA_CNT_MSB    : integer := 27;
    constant REG_DAQ_DMB6_COUNTERS_EVT_FIFO_DATA_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB6_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"75";
    constant REG_DAQ_DMB6_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_DMB6_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB6_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"75";
    constant REG_DAQ_DMB6_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB    : integer := 31;
    constant REG_DAQ_DMB6_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB6_COUNTERS_DATA_WORD_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"76";
    constant REG_DAQ_DMB6_COUNTERS_DATA_WORD_RATE_MSB    : integer := 14;
    constant REG_DAQ_DMB6_COUNTERS_DATA_WORD_RATE_LSB     : integer := 0;

    constant REG_DAQ_DMB6_COUNTERS_EVT_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"76";
    constant REG_DAQ_DMB6_COUNTERS_EVT_RATE_MSB    : integer := 31;
    constant REG_DAQ_DMB6_COUNTERS_EVT_RATE_LSB     : integer := 15;

    constant REG_DAQ_DMB7_STATUS_EVT_64BIT_ALIGN_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"80";
    constant REG_DAQ_DMB7_STATUS_EVT_64BIT_ALIGN_ERR_BIT    : integer := 0;

    constant REG_DAQ_DMB7_STATUS_INPUT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"80";
    constant REG_DAQ_DMB7_STATUS_INPUT_FIFO_HAD_OFLOW_BIT    : integer := 8;

    constant REG_DAQ_DMB7_STATUS_INPUT_FIFO_HAD_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"80";
    constant REG_DAQ_DMB7_STATUS_INPUT_FIFO_HAD_UFLOW_BIT    : integer := 9;

    constant REG_DAQ_DMB7_STATUS_EVENT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"80";
    constant REG_DAQ_DMB7_STATUS_EVENT_FIFO_HAD_OFLOW_BIT    : integer := 10;

    constant REG_DAQ_DMB7_STATUS_EVT_SIZE_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"80";
    constant REG_DAQ_DMB7_STATUS_EVT_SIZE_ERR_BIT    : integer := 11;

    constant REG_DAQ_DMB7_STATUS_TTS_STATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"80";
    constant REG_DAQ_DMB7_STATUS_TTS_STATE_MSB    : integer := 15;
    constant REG_DAQ_DMB7_STATUS_TTS_STATE_LSB     : integer := 12;

    constant REG_DAQ_DMB7_STATUS_INPUT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"80";
    constant REG_DAQ_DMB7_STATUS_INPUT_FIFO_IS_UFLOW_BIT    : integer := 24;

    constant REG_DAQ_DMB7_STATUS_INPUT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"80";
    constant REG_DAQ_DMB7_STATUS_INPUT_FIFO_IS_FULL_BIT    : integer := 25;

    constant REG_DAQ_DMB7_STATUS_INPUT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"80";
    constant REG_DAQ_DMB7_STATUS_INPUT_FIFO_IS_AFULL_BIT    : integer := 26;

    constant REG_DAQ_DMB7_STATUS_INPUT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"80";
    constant REG_DAQ_DMB7_STATUS_INPUT_FIFO_IS_EMPTY_BIT    : integer := 27;

    constant REG_DAQ_DMB7_STATUS_EVENT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"80";
    constant REG_DAQ_DMB7_STATUS_EVENT_FIFO_IS_UFLOW_BIT    : integer := 28;

    constant REG_DAQ_DMB7_STATUS_EVENT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"80";
    constant REG_DAQ_DMB7_STATUS_EVENT_FIFO_IS_FULL_BIT    : integer := 29;

    constant REG_DAQ_DMB7_STATUS_EVENT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"80";
    constant REG_DAQ_DMB7_STATUS_EVENT_FIFO_IS_AFULL_BIT    : integer := 30;

    constant REG_DAQ_DMB7_STATUS_EVENT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"80";
    constant REG_DAQ_DMB7_STATUS_EVENT_FIFO_IS_EMPTY_BIT    : integer := 31;

    constant REG_DAQ_DMB7_COUNTERS_EVN_ADDR    : std_logic_vector(8 downto 0) := '0' & x"82";
    constant REG_DAQ_DMB7_COUNTERS_EVN_MSB    : integer := 23;
    constant REG_DAQ_DMB7_COUNTERS_EVN_LSB     : integer := 0;

    constant REG_DAQ_DMB7_COUNTERS_INPUT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"84";
    constant REG_DAQ_DMB7_COUNTERS_INPUT_FIFO_DATA_CNT_MSB    : integer := 13;
    constant REG_DAQ_DMB7_COUNTERS_INPUT_FIFO_DATA_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB7_COUNTERS_EVT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"84";
    constant REG_DAQ_DMB7_COUNTERS_EVT_FIFO_DATA_CNT_MSB    : integer := 27;
    constant REG_DAQ_DMB7_COUNTERS_EVT_FIFO_DATA_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB7_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"85";
    constant REG_DAQ_DMB7_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_DMB7_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB7_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"85";
    constant REG_DAQ_DMB7_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB    : integer := 31;
    constant REG_DAQ_DMB7_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB7_COUNTERS_DATA_WORD_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"86";
    constant REG_DAQ_DMB7_COUNTERS_DATA_WORD_RATE_MSB    : integer := 14;
    constant REG_DAQ_DMB7_COUNTERS_DATA_WORD_RATE_LSB     : integer := 0;

    constant REG_DAQ_DMB7_COUNTERS_EVT_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"86";
    constant REG_DAQ_DMB7_COUNTERS_EVT_RATE_MSB    : integer := 31;
    constant REG_DAQ_DMB7_COUNTERS_EVT_RATE_LSB     : integer := 15;

    constant REG_DAQ_DMB8_STATUS_EVT_64BIT_ALIGN_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"90";
    constant REG_DAQ_DMB8_STATUS_EVT_64BIT_ALIGN_ERR_BIT    : integer := 0;

    constant REG_DAQ_DMB8_STATUS_INPUT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"90";
    constant REG_DAQ_DMB8_STATUS_INPUT_FIFO_HAD_OFLOW_BIT    : integer := 8;

    constant REG_DAQ_DMB8_STATUS_INPUT_FIFO_HAD_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"90";
    constant REG_DAQ_DMB8_STATUS_INPUT_FIFO_HAD_UFLOW_BIT    : integer := 9;

    constant REG_DAQ_DMB8_STATUS_EVENT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"90";
    constant REG_DAQ_DMB8_STATUS_EVENT_FIFO_HAD_OFLOW_BIT    : integer := 10;

    constant REG_DAQ_DMB8_STATUS_EVT_SIZE_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"90";
    constant REG_DAQ_DMB8_STATUS_EVT_SIZE_ERR_BIT    : integer := 11;

    constant REG_DAQ_DMB8_STATUS_TTS_STATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"90";
    constant REG_DAQ_DMB8_STATUS_TTS_STATE_MSB    : integer := 15;
    constant REG_DAQ_DMB8_STATUS_TTS_STATE_LSB     : integer := 12;

    constant REG_DAQ_DMB8_STATUS_INPUT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"90";
    constant REG_DAQ_DMB8_STATUS_INPUT_FIFO_IS_UFLOW_BIT    : integer := 24;

    constant REG_DAQ_DMB8_STATUS_INPUT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"90";
    constant REG_DAQ_DMB8_STATUS_INPUT_FIFO_IS_FULL_BIT    : integer := 25;

    constant REG_DAQ_DMB8_STATUS_INPUT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"90";
    constant REG_DAQ_DMB8_STATUS_INPUT_FIFO_IS_AFULL_BIT    : integer := 26;

    constant REG_DAQ_DMB8_STATUS_INPUT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"90";
    constant REG_DAQ_DMB8_STATUS_INPUT_FIFO_IS_EMPTY_BIT    : integer := 27;

    constant REG_DAQ_DMB8_STATUS_EVENT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"90";
    constant REG_DAQ_DMB8_STATUS_EVENT_FIFO_IS_UFLOW_BIT    : integer := 28;

    constant REG_DAQ_DMB8_STATUS_EVENT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"90";
    constant REG_DAQ_DMB8_STATUS_EVENT_FIFO_IS_FULL_BIT    : integer := 29;

    constant REG_DAQ_DMB8_STATUS_EVENT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"90";
    constant REG_DAQ_DMB8_STATUS_EVENT_FIFO_IS_AFULL_BIT    : integer := 30;

    constant REG_DAQ_DMB8_STATUS_EVENT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"90";
    constant REG_DAQ_DMB8_STATUS_EVENT_FIFO_IS_EMPTY_BIT    : integer := 31;

    constant REG_DAQ_DMB8_COUNTERS_EVN_ADDR    : std_logic_vector(8 downto 0) := '0' & x"92";
    constant REG_DAQ_DMB8_COUNTERS_EVN_MSB    : integer := 23;
    constant REG_DAQ_DMB8_COUNTERS_EVN_LSB     : integer := 0;

    constant REG_DAQ_DMB8_COUNTERS_INPUT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"94";
    constant REG_DAQ_DMB8_COUNTERS_INPUT_FIFO_DATA_CNT_MSB    : integer := 13;
    constant REG_DAQ_DMB8_COUNTERS_INPUT_FIFO_DATA_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB8_COUNTERS_EVT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"94";
    constant REG_DAQ_DMB8_COUNTERS_EVT_FIFO_DATA_CNT_MSB    : integer := 27;
    constant REG_DAQ_DMB8_COUNTERS_EVT_FIFO_DATA_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB8_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"95";
    constant REG_DAQ_DMB8_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_DMB8_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB8_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"95";
    constant REG_DAQ_DMB8_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB    : integer := 31;
    constant REG_DAQ_DMB8_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB8_COUNTERS_DATA_WORD_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"96";
    constant REG_DAQ_DMB8_COUNTERS_DATA_WORD_RATE_MSB    : integer := 14;
    constant REG_DAQ_DMB8_COUNTERS_DATA_WORD_RATE_LSB     : integer := 0;

    constant REG_DAQ_DMB8_COUNTERS_EVT_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"96";
    constant REG_DAQ_DMB8_COUNTERS_EVT_RATE_MSB    : integer := 31;
    constant REG_DAQ_DMB8_COUNTERS_EVT_RATE_LSB     : integer := 15;

    constant REG_DAQ_DMB9_STATUS_EVT_64BIT_ALIGN_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a0";
    constant REG_DAQ_DMB9_STATUS_EVT_64BIT_ALIGN_ERR_BIT    : integer := 0;

    constant REG_DAQ_DMB9_STATUS_INPUT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a0";
    constant REG_DAQ_DMB9_STATUS_INPUT_FIFO_HAD_OFLOW_BIT    : integer := 8;

    constant REG_DAQ_DMB9_STATUS_INPUT_FIFO_HAD_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a0";
    constant REG_DAQ_DMB9_STATUS_INPUT_FIFO_HAD_UFLOW_BIT    : integer := 9;

    constant REG_DAQ_DMB9_STATUS_EVENT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a0";
    constant REG_DAQ_DMB9_STATUS_EVENT_FIFO_HAD_OFLOW_BIT    : integer := 10;

    constant REG_DAQ_DMB9_STATUS_EVT_SIZE_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a0";
    constant REG_DAQ_DMB9_STATUS_EVT_SIZE_ERR_BIT    : integer := 11;

    constant REG_DAQ_DMB9_STATUS_TTS_STATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a0";
    constant REG_DAQ_DMB9_STATUS_TTS_STATE_MSB    : integer := 15;
    constant REG_DAQ_DMB9_STATUS_TTS_STATE_LSB     : integer := 12;

    constant REG_DAQ_DMB9_STATUS_INPUT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a0";
    constant REG_DAQ_DMB9_STATUS_INPUT_FIFO_IS_UFLOW_BIT    : integer := 24;

    constant REG_DAQ_DMB9_STATUS_INPUT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a0";
    constant REG_DAQ_DMB9_STATUS_INPUT_FIFO_IS_FULL_BIT    : integer := 25;

    constant REG_DAQ_DMB9_STATUS_INPUT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a0";
    constant REG_DAQ_DMB9_STATUS_INPUT_FIFO_IS_AFULL_BIT    : integer := 26;

    constant REG_DAQ_DMB9_STATUS_INPUT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a0";
    constant REG_DAQ_DMB9_STATUS_INPUT_FIFO_IS_EMPTY_BIT    : integer := 27;

    constant REG_DAQ_DMB9_STATUS_EVENT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a0";
    constant REG_DAQ_DMB9_STATUS_EVENT_FIFO_IS_UFLOW_BIT    : integer := 28;

    constant REG_DAQ_DMB9_STATUS_EVENT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a0";
    constant REG_DAQ_DMB9_STATUS_EVENT_FIFO_IS_FULL_BIT    : integer := 29;

    constant REG_DAQ_DMB9_STATUS_EVENT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a0";
    constant REG_DAQ_DMB9_STATUS_EVENT_FIFO_IS_AFULL_BIT    : integer := 30;

    constant REG_DAQ_DMB9_STATUS_EVENT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a0";
    constant REG_DAQ_DMB9_STATUS_EVENT_FIFO_IS_EMPTY_BIT    : integer := 31;

    constant REG_DAQ_DMB9_COUNTERS_EVN_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a2";
    constant REG_DAQ_DMB9_COUNTERS_EVN_MSB    : integer := 23;
    constant REG_DAQ_DMB9_COUNTERS_EVN_LSB     : integer := 0;

    constant REG_DAQ_DMB9_COUNTERS_INPUT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a4";
    constant REG_DAQ_DMB9_COUNTERS_INPUT_FIFO_DATA_CNT_MSB    : integer := 13;
    constant REG_DAQ_DMB9_COUNTERS_INPUT_FIFO_DATA_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB9_COUNTERS_EVT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a4";
    constant REG_DAQ_DMB9_COUNTERS_EVT_FIFO_DATA_CNT_MSB    : integer := 27;
    constant REG_DAQ_DMB9_COUNTERS_EVT_FIFO_DATA_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB9_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a5";
    constant REG_DAQ_DMB9_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_DMB9_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB9_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a5";
    constant REG_DAQ_DMB9_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB    : integer := 31;
    constant REG_DAQ_DMB9_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB9_COUNTERS_DATA_WORD_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a6";
    constant REG_DAQ_DMB9_COUNTERS_DATA_WORD_RATE_MSB    : integer := 14;
    constant REG_DAQ_DMB9_COUNTERS_DATA_WORD_RATE_LSB     : integer := 0;

    constant REG_DAQ_DMB9_COUNTERS_EVT_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"a6";
    constant REG_DAQ_DMB9_COUNTERS_EVT_RATE_MSB    : integer := 31;
    constant REG_DAQ_DMB9_COUNTERS_EVT_RATE_LSB     : integer := 15;

    constant REG_DAQ_DMB10_STATUS_EVT_64BIT_ALIGN_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b0";
    constant REG_DAQ_DMB10_STATUS_EVT_64BIT_ALIGN_ERR_BIT    : integer := 0;

    constant REG_DAQ_DMB10_STATUS_INPUT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b0";
    constant REG_DAQ_DMB10_STATUS_INPUT_FIFO_HAD_OFLOW_BIT    : integer := 8;

    constant REG_DAQ_DMB10_STATUS_INPUT_FIFO_HAD_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b0";
    constant REG_DAQ_DMB10_STATUS_INPUT_FIFO_HAD_UFLOW_BIT    : integer := 9;

    constant REG_DAQ_DMB10_STATUS_EVENT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b0";
    constant REG_DAQ_DMB10_STATUS_EVENT_FIFO_HAD_OFLOW_BIT    : integer := 10;

    constant REG_DAQ_DMB10_STATUS_EVT_SIZE_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b0";
    constant REG_DAQ_DMB10_STATUS_EVT_SIZE_ERR_BIT    : integer := 11;

    constant REG_DAQ_DMB10_STATUS_TTS_STATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b0";
    constant REG_DAQ_DMB10_STATUS_TTS_STATE_MSB    : integer := 15;
    constant REG_DAQ_DMB10_STATUS_TTS_STATE_LSB     : integer := 12;

    constant REG_DAQ_DMB10_STATUS_INPUT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b0";
    constant REG_DAQ_DMB10_STATUS_INPUT_FIFO_IS_UFLOW_BIT    : integer := 24;

    constant REG_DAQ_DMB10_STATUS_INPUT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b0";
    constant REG_DAQ_DMB10_STATUS_INPUT_FIFO_IS_FULL_BIT    : integer := 25;

    constant REG_DAQ_DMB10_STATUS_INPUT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b0";
    constant REG_DAQ_DMB10_STATUS_INPUT_FIFO_IS_AFULL_BIT    : integer := 26;

    constant REG_DAQ_DMB10_STATUS_INPUT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b0";
    constant REG_DAQ_DMB10_STATUS_INPUT_FIFO_IS_EMPTY_BIT    : integer := 27;

    constant REG_DAQ_DMB10_STATUS_EVENT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b0";
    constant REG_DAQ_DMB10_STATUS_EVENT_FIFO_IS_UFLOW_BIT    : integer := 28;

    constant REG_DAQ_DMB10_STATUS_EVENT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b0";
    constant REG_DAQ_DMB10_STATUS_EVENT_FIFO_IS_FULL_BIT    : integer := 29;

    constant REG_DAQ_DMB10_STATUS_EVENT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b0";
    constant REG_DAQ_DMB10_STATUS_EVENT_FIFO_IS_AFULL_BIT    : integer := 30;

    constant REG_DAQ_DMB10_STATUS_EVENT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b0";
    constant REG_DAQ_DMB10_STATUS_EVENT_FIFO_IS_EMPTY_BIT    : integer := 31;

    constant REG_DAQ_DMB10_COUNTERS_EVN_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b2";
    constant REG_DAQ_DMB10_COUNTERS_EVN_MSB    : integer := 23;
    constant REG_DAQ_DMB10_COUNTERS_EVN_LSB     : integer := 0;

    constant REG_DAQ_DMB10_COUNTERS_INPUT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b4";
    constant REG_DAQ_DMB10_COUNTERS_INPUT_FIFO_DATA_CNT_MSB    : integer := 13;
    constant REG_DAQ_DMB10_COUNTERS_INPUT_FIFO_DATA_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB10_COUNTERS_EVT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b4";
    constant REG_DAQ_DMB10_COUNTERS_EVT_FIFO_DATA_CNT_MSB    : integer := 27;
    constant REG_DAQ_DMB10_COUNTERS_EVT_FIFO_DATA_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB10_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b5";
    constant REG_DAQ_DMB10_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_DMB10_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB10_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b5";
    constant REG_DAQ_DMB10_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB    : integer := 31;
    constant REG_DAQ_DMB10_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB10_COUNTERS_DATA_WORD_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b6";
    constant REG_DAQ_DMB10_COUNTERS_DATA_WORD_RATE_MSB    : integer := 14;
    constant REG_DAQ_DMB10_COUNTERS_DATA_WORD_RATE_LSB     : integer := 0;

    constant REG_DAQ_DMB10_COUNTERS_EVT_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"b6";
    constant REG_DAQ_DMB10_COUNTERS_EVT_RATE_MSB    : integer := 31;
    constant REG_DAQ_DMB10_COUNTERS_EVT_RATE_LSB     : integer := 15;

    constant REG_DAQ_DMB11_STATUS_EVT_64BIT_ALIGN_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c0";
    constant REG_DAQ_DMB11_STATUS_EVT_64BIT_ALIGN_ERR_BIT    : integer := 0;

    constant REG_DAQ_DMB11_STATUS_INPUT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c0";
    constant REG_DAQ_DMB11_STATUS_INPUT_FIFO_HAD_OFLOW_BIT    : integer := 8;

    constant REG_DAQ_DMB11_STATUS_INPUT_FIFO_HAD_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c0";
    constant REG_DAQ_DMB11_STATUS_INPUT_FIFO_HAD_UFLOW_BIT    : integer := 9;

    constant REG_DAQ_DMB11_STATUS_EVENT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c0";
    constant REG_DAQ_DMB11_STATUS_EVENT_FIFO_HAD_OFLOW_BIT    : integer := 10;

    constant REG_DAQ_DMB11_STATUS_EVT_SIZE_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c0";
    constant REG_DAQ_DMB11_STATUS_EVT_SIZE_ERR_BIT    : integer := 11;

    constant REG_DAQ_DMB11_STATUS_TTS_STATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c0";
    constant REG_DAQ_DMB11_STATUS_TTS_STATE_MSB    : integer := 15;
    constant REG_DAQ_DMB11_STATUS_TTS_STATE_LSB     : integer := 12;

    constant REG_DAQ_DMB11_STATUS_INPUT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c0";
    constant REG_DAQ_DMB11_STATUS_INPUT_FIFO_IS_UFLOW_BIT    : integer := 24;

    constant REG_DAQ_DMB11_STATUS_INPUT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c0";
    constant REG_DAQ_DMB11_STATUS_INPUT_FIFO_IS_FULL_BIT    : integer := 25;

    constant REG_DAQ_DMB11_STATUS_INPUT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c0";
    constant REG_DAQ_DMB11_STATUS_INPUT_FIFO_IS_AFULL_BIT    : integer := 26;

    constant REG_DAQ_DMB11_STATUS_INPUT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c0";
    constant REG_DAQ_DMB11_STATUS_INPUT_FIFO_IS_EMPTY_BIT    : integer := 27;

    constant REG_DAQ_DMB11_STATUS_EVENT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c0";
    constant REG_DAQ_DMB11_STATUS_EVENT_FIFO_IS_UFLOW_BIT    : integer := 28;

    constant REG_DAQ_DMB11_STATUS_EVENT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c0";
    constant REG_DAQ_DMB11_STATUS_EVENT_FIFO_IS_FULL_BIT    : integer := 29;

    constant REG_DAQ_DMB11_STATUS_EVENT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c0";
    constant REG_DAQ_DMB11_STATUS_EVENT_FIFO_IS_AFULL_BIT    : integer := 30;

    constant REG_DAQ_DMB11_STATUS_EVENT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c0";
    constant REG_DAQ_DMB11_STATUS_EVENT_FIFO_IS_EMPTY_BIT    : integer := 31;

    constant REG_DAQ_DMB11_COUNTERS_EVN_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c2";
    constant REG_DAQ_DMB11_COUNTERS_EVN_MSB    : integer := 23;
    constant REG_DAQ_DMB11_COUNTERS_EVN_LSB     : integer := 0;

    constant REG_DAQ_DMB11_COUNTERS_INPUT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c4";
    constant REG_DAQ_DMB11_COUNTERS_INPUT_FIFO_DATA_CNT_MSB    : integer := 13;
    constant REG_DAQ_DMB11_COUNTERS_INPUT_FIFO_DATA_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB11_COUNTERS_EVT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c4";
    constant REG_DAQ_DMB11_COUNTERS_EVT_FIFO_DATA_CNT_MSB    : integer := 27;
    constant REG_DAQ_DMB11_COUNTERS_EVT_FIFO_DATA_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB11_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c5";
    constant REG_DAQ_DMB11_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_DMB11_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB11_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c5";
    constant REG_DAQ_DMB11_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB    : integer := 31;
    constant REG_DAQ_DMB11_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB11_COUNTERS_DATA_WORD_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c6";
    constant REG_DAQ_DMB11_COUNTERS_DATA_WORD_RATE_MSB    : integer := 14;
    constant REG_DAQ_DMB11_COUNTERS_DATA_WORD_RATE_LSB     : integer := 0;

    constant REG_DAQ_DMB11_COUNTERS_EVT_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"c6";
    constant REG_DAQ_DMB11_COUNTERS_EVT_RATE_MSB    : integer := 31;
    constant REG_DAQ_DMB11_COUNTERS_EVT_RATE_LSB     : integer := 15;

    constant REG_DAQ_DMB12_STATUS_EVT_64BIT_ALIGN_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d0";
    constant REG_DAQ_DMB12_STATUS_EVT_64BIT_ALIGN_ERR_BIT    : integer := 0;

    constant REG_DAQ_DMB12_STATUS_INPUT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d0";
    constant REG_DAQ_DMB12_STATUS_INPUT_FIFO_HAD_OFLOW_BIT    : integer := 8;

    constant REG_DAQ_DMB12_STATUS_INPUT_FIFO_HAD_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d0";
    constant REG_DAQ_DMB12_STATUS_INPUT_FIFO_HAD_UFLOW_BIT    : integer := 9;

    constant REG_DAQ_DMB12_STATUS_EVENT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d0";
    constant REG_DAQ_DMB12_STATUS_EVENT_FIFO_HAD_OFLOW_BIT    : integer := 10;

    constant REG_DAQ_DMB12_STATUS_EVT_SIZE_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d0";
    constant REG_DAQ_DMB12_STATUS_EVT_SIZE_ERR_BIT    : integer := 11;

    constant REG_DAQ_DMB12_STATUS_TTS_STATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d0";
    constant REG_DAQ_DMB12_STATUS_TTS_STATE_MSB    : integer := 15;
    constant REG_DAQ_DMB12_STATUS_TTS_STATE_LSB     : integer := 12;

    constant REG_DAQ_DMB12_STATUS_INPUT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d0";
    constant REG_DAQ_DMB12_STATUS_INPUT_FIFO_IS_UFLOW_BIT    : integer := 24;

    constant REG_DAQ_DMB12_STATUS_INPUT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d0";
    constant REG_DAQ_DMB12_STATUS_INPUT_FIFO_IS_FULL_BIT    : integer := 25;

    constant REG_DAQ_DMB12_STATUS_INPUT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d0";
    constant REG_DAQ_DMB12_STATUS_INPUT_FIFO_IS_AFULL_BIT    : integer := 26;

    constant REG_DAQ_DMB12_STATUS_INPUT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d0";
    constant REG_DAQ_DMB12_STATUS_INPUT_FIFO_IS_EMPTY_BIT    : integer := 27;

    constant REG_DAQ_DMB12_STATUS_EVENT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d0";
    constant REG_DAQ_DMB12_STATUS_EVENT_FIFO_IS_UFLOW_BIT    : integer := 28;

    constant REG_DAQ_DMB12_STATUS_EVENT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d0";
    constant REG_DAQ_DMB12_STATUS_EVENT_FIFO_IS_FULL_BIT    : integer := 29;

    constant REG_DAQ_DMB12_STATUS_EVENT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d0";
    constant REG_DAQ_DMB12_STATUS_EVENT_FIFO_IS_AFULL_BIT    : integer := 30;

    constant REG_DAQ_DMB12_STATUS_EVENT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d0";
    constant REG_DAQ_DMB12_STATUS_EVENT_FIFO_IS_EMPTY_BIT    : integer := 31;

    constant REG_DAQ_DMB12_COUNTERS_EVN_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d2";
    constant REG_DAQ_DMB12_COUNTERS_EVN_MSB    : integer := 23;
    constant REG_DAQ_DMB12_COUNTERS_EVN_LSB     : integer := 0;

    constant REG_DAQ_DMB12_COUNTERS_INPUT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d4";
    constant REG_DAQ_DMB12_COUNTERS_INPUT_FIFO_DATA_CNT_MSB    : integer := 13;
    constant REG_DAQ_DMB12_COUNTERS_INPUT_FIFO_DATA_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB12_COUNTERS_EVT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d4";
    constant REG_DAQ_DMB12_COUNTERS_EVT_FIFO_DATA_CNT_MSB    : integer := 27;
    constant REG_DAQ_DMB12_COUNTERS_EVT_FIFO_DATA_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB12_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d5";
    constant REG_DAQ_DMB12_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_DMB12_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB12_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d5";
    constant REG_DAQ_DMB12_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB    : integer := 31;
    constant REG_DAQ_DMB12_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB12_COUNTERS_DATA_WORD_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d6";
    constant REG_DAQ_DMB12_COUNTERS_DATA_WORD_RATE_MSB    : integer := 14;
    constant REG_DAQ_DMB12_COUNTERS_DATA_WORD_RATE_LSB     : integer := 0;

    constant REG_DAQ_DMB12_COUNTERS_EVT_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"d6";
    constant REG_DAQ_DMB12_COUNTERS_EVT_RATE_MSB    : integer := 31;
    constant REG_DAQ_DMB12_COUNTERS_EVT_RATE_LSB     : integer := 15;

    constant REG_DAQ_DMB13_STATUS_EVT_64BIT_ALIGN_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e0";
    constant REG_DAQ_DMB13_STATUS_EVT_64BIT_ALIGN_ERR_BIT    : integer := 0;

    constant REG_DAQ_DMB13_STATUS_INPUT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e0";
    constant REG_DAQ_DMB13_STATUS_INPUT_FIFO_HAD_OFLOW_BIT    : integer := 8;

    constant REG_DAQ_DMB13_STATUS_INPUT_FIFO_HAD_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e0";
    constant REG_DAQ_DMB13_STATUS_INPUT_FIFO_HAD_UFLOW_BIT    : integer := 9;

    constant REG_DAQ_DMB13_STATUS_EVENT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e0";
    constant REG_DAQ_DMB13_STATUS_EVENT_FIFO_HAD_OFLOW_BIT    : integer := 10;

    constant REG_DAQ_DMB13_STATUS_EVT_SIZE_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e0";
    constant REG_DAQ_DMB13_STATUS_EVT_SIZE_ERR_BIT    : integer := 11;

    constant REG_DAQ_DMB13_STATUS_TTS_STATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e0";
    constant REG_DAQ_DMB13_STATUS_TTS_STATE_MSB    : integer := 15;
    constant REG_DAQ_DMB13_STATUS_TTS_STATE_LSB     : integer := 12;

    constant REG_DAQ_DMB13_STATUS_INPUT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e0";
    constant REG_DAQ_DMB13_STATUS_INPUT_FIFO_IS_UFLOW_BIT    : integer := 24;

    constant REG_DAQ_DMB13_STATUS_INPUT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e0";
    constant REG_DAQ_DMB13_STATUS_INPUT_FIFO_IS_FULL_BIT    : integer := 25;

    constant REG_DAQ_DMB13_STATUS_INPUT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e0";
    constant REG_DAQ_DMB13_STATUS_INPUT_FIFO_IS_AFULL_BIT    : integer := 26;

    constant REG_DAQ_DMB13_STATUS_INPUT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e0";
    constant REG_DAQ_DMB13_STATUS_INPUT_FIFO_IS_EMPTY_BIT    : integer := 27;

    constant REG_DAQ_DMB13_STATUS_EVENT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e0";
    constant REG_DAQ_DMB13_STATUS_EVENT_FIFO_IS_UFLOW_BIT    : integer := 28;

    constant REG_DAQ_DMB13_STATUS_EVENT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e0";
    constant REG_DAQ_DMB13_STATUS_EVENT_FIFO_IS_FULL_BIT    : integer := 29;

    constant REG_DAQ_DMB13_STATUS_EVENT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e0";
    constant REG_DAQ_DMB13_STATUS_EVENT_FIFO_IS_AFULL_BIT    : integer := 30;

    constant REG_DAQ_DMB13_STATUS_EVENT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e0";
    constant REG_DAQ_DMB13_STATUS_EVENT_FIFO_IS_EMPTY_BIT    : integer := 31;

    constant REG_DAQ_DMB13_COUNTERS_EVN_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e2";
    constant REG_DAQ_DMB13_COUNTERS_EVN_MSB    : integer := 23;
    constant REG_DAQ_DMB13_COUNTERS_EVN_LSB     : integer := 0;

    constant REG_DAQ_DMB13_COUNTERS_INPUT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e4";
    constant REG_DAQ_DMB13_COUNTERS_INPUT_FIFO_DATA_CNT_MSB    : integer := 13;
    constant REG_DAQ_DMB13_COUNTERS_INPUT_FIFO_DATA_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB13_COUNTERS_EVT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e4";
    constant REG_DAQ_DMB13_COUNTERS_EVT_FIFO_DATA_CNT_MSB    : integer := 27;
    constant REG_DAQ_DMB13_COUNTERS_EVT_FIFO_DATA_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB13_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e5";
    constant REG_DAQ_DMB13_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_DMB13_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB13_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e5";
    constant REG_DAQ_DMB13_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB    : integer := 31;
    constant REG_DAQ_DMB13_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB13_COUNTERS_DATA_WORD_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e6";
    constant REG_DAQ_DMB13_COUNTERS_DATA_WORD_RATE_MSB    : integer := 14;
    constant REG_DAQ_DMB13_COUNTERS_DATA_WORD_RATE_LSB     : integer := 0;

    constant REG_DAQ_DMB13_COUNTERS_EVT_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"e6";
    constant REG_DAQ_DMB13_COUNTERS_EVT_RATE_MSB    : integer := 31;
    constant REG_DAQ_DMB13_COUNTERS_EVT_RATE_LSB     : integer := 15;

    constant REG_DAQ_DMB14_STATUS_EVT_64BIT_ALIGN_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f0";
    constant REG_DAQ_DMB14_STATUS_EVT_64BIT_ALIGN_ERR_BIT    : integer := 0;

    constant REG_DAQ_DMB14_STATUS_INPUT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f0";
    constant REG_DAQ_DMB14_STATUS_INPUT_FIFO_HAD_OFLOW_BIT    : integer := 8;

    constant REG_DAQ_DMB14_STATUS_INPUT_FIFO_HAD_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f0";
    constant REG_DAQ_DMB14_STATUS_INPUT_FIFO_HAD_UFLOW_BIT    : integer := 9;

    constant REG_DAQ_DMB14_STATUS_EVENT_FIFO_HAD_OFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f0";
    constant REG_DAQ_DMB14_STATUS_EVENT_FIFO_HAD_OFLOW_BIT    : integer := 10;

    constant REG_DAQ_DMB14_STATUS_EVT_SIZE_ERR_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f0";
    constant REG_DAQ_DMB14_STATUS_EVT_SIZE_ERR_BIT    : integer := 11;

    constant REG_DAQ_DMB14_STATUS_TTS_STATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f0";
    constant REG_DAQ_DMB14_STATUS_TTS_STATE_MSB    : integer := 15;
    constant REG_DAQ_DMB14_STATUS_TTS_STATE_LSB     : integer := 12;

    constant REG_DAQ_DMB14_STATUS_INPUT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f0";
    constant REG_DAQ_DMB14_STATUS_INPUT_FIFO_IS_UFLOW_BIT    : integer := 24;

    constant REG_DAQ_DMB14_STATUS_INPUT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f0";
    constant REG_DAQ_DMB14_STATUS_INPUT_FIFO_IS_FULL_BIT    : integer := 25;

    constant REG_DAQ_DMB14_STATUS_INPUT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f0";
    constant REG_DAQ_DMB14_STATUS_INPUT_FIFO_IS_AFULL_BIT    : integer := 26;

    constant REG_DAQ_DMB14_STATUS_INPUT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f0";
    constant REG_DAQ_DMB14_STATUS_INPUT_FIFO_IS_EMPTY_BIT    : integer := 27;

    constant REG_DAQ_DMB14_STATUS_EVENT_FIFO_IS_UFLOW_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f0";
    constant REG_DAQ_DMB14_STATUS_EVENT_FIFO_IS_UFLOW_BIT    : integer := 28;

    constant REG_DAQ_DMB14_STATUS_EVENT_FIFO_IS_FULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f0";
    constant REG_DAQ_DMB14_STATUS_EVENT_FIFO_IS_FULL_BIT    : integer := 29;

    constant REG_DAQ_DMB14_STATUS_EVENT_FIFO_IS_AFULL_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f0";
    constant REG_DAQ_DMB14_STATUS_EVENT_FIFO_IS_AFULL_BIT    : integer := 30;

    constant REG_DAQ_DMB14_STATUS_EVENT_FIFO_IS_EMPTY_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f0";
    constant REG_DAQ_DMB14_STATUS_EVENT_FIFO_IS_EMPTY_BIT    : integer := 31;

    constant REG_DAQ_DMB14_COUNTERS_EVN_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f2";
    constant REG_DAQ_DMB14_COUNTERS_EVN_MSB    : integer := 23;
    constant REG_DAQ_DMB14_COUNTERS_EVN_LSB     : integer := 0;

    constant REG_DAQ_DMB14_COUNTERS_INPUT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f4";
    constant REG_DAQ_DMB14_COUNTERS_INPUT_FIFO_DATA_CNT_MSB    : integer := 13;
    constant REG_DAQ_DMB14_COUNTERS_INPUT_FIFO_DATA_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB14_COUNTERS_EVT_FIFO_DATA_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f4";
    constant REG_DAQ_DMB14_COUNTERS_EVT_FIFO_DATA_CNT_MSB    : integer := 27;
    constant REG_DAQ_DMB14_COUNTERS_EVT_FIFO_DATA_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB14_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f5";
    constant REG_DAQ_DMB14_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB    : integer := 15;
    constant REG_DAQ_DMB14_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB     : integer := 0;

    constant REG_DAQ_DMB14_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f5";
    constant REG_DAQ_DMB14_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB    : integer := 31;
    constant REG_DAQ_DMB14_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB     : integer := 16;

    constant REG_DAQ_DMB14_COUNTERS_DATA_WORD_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f6";
    constant REG_DAQ_DMB14_COUNTERS_DATA_WORD_RATE_MSB    : integer := 14;
    constant REG_DAQ_DMB14_COUNTERS_DATA_WORD_RATE_LSB     : integer := 0;

    constant REG_DAQ_DMB14_COUNTERS_EVT_RATE_ADDR    : std_logic_vector(8 downto 0) := '0' & x"f6";
    constant REG_DAQ_DMB14_COUNTERS_EVT_RATE_MSB    : integer := 31;
    constant REG_DAQ_DMB14_COUNTERS_EVT_RATE_LSB     : integer := 15;


    --============================================================================
    --       >>> TEST Module <<<    base address: 0x00500000
    --
    -- This module is controling various system tests, like loopbacks, user
    -- defined eth packet sending, etc
    --============================================================================

    constant REG_TEST_NUM_REGS : integer := 7;
    constant REG_TEST_ADDRESS_MSB : integer := 7;
    constant REG_TEST_ADDRESS_LSB : integer := 0;
    constant REG_TEST_CTRL_MODULE_RESET_ADDR    : std_logic_vector(7 downto 0) := x"00";
    constant REG_TEST_CTRL_MODULE_RESET_BIT    : integer := 31;

    constant REG_TEST_GBE_TEST_ENABLE_ADDR    : std_logic_vector(7 downto 0) := x"10";
    constant REG_TEST_GBE_TEST_ENABLE_BIT    : integer := 0;
    constant REG_TEST_GBE_TEST_ENABLE_DEFAULT : std_logic := '1';

    constant REG_TEST_GBE_TEST_PUSH_GBE_DATA_ADDR    : std_logic_vector(7 downto 0) := x"11";
    constant REG_TEST_GBE_TEST_PUSH_GBE_DATA_MSB    : integer := 17;
    constant REG_TEST_GBE_TEST_PUSH_GBE_DATA_LSB     : integer := 0;
    constant REG_TEST_GBE_TEST_PUSH_GBE_DATA_DEFAULT : std_logic_vector(17 downto 0) := "00" & x"0000";

    constant REG_TEST_GBE_TEST_START_TRANSMIT_ADDR    : std_logic_vector(7 downto 0) := x"12";
    constant REG_TEST_GBE_TEST_START_TRANSMIT_BIT    : integer := 31;

    constant REG_TEST_GBE_TEST_BUSY_ADDR    : std_logic_vector(7 downto 0) := x"13";
    constant REG_TEST_GBE_TEST_BUSY_BIT    : integer := 0;

    constant REG_TEST_GBE_TEST_EMPTY_ADDR    : std_logic_vector(7 downto 0) := x"13";
    constant REG_TEST_GBE_TEST_EMPTY_BIT    : integer := 1;

    constant REG_TEST_GBE_TEST_MANUAL_READ_ENABLE_ADDR    : std_logic_vector(7 downto 0) := x"14";
    constant REG_TEST_GBE_TEST_MANUAL_READ_ENABLE_BIT    : integer := 0;
    constant REG_TEST_GBE_TEST_MANUAL_READ_ENABLE_DEFAULT : std_logic := '0';

    constant REG_TEST_GBE_TEST_MANUAL_READ_ADDR    : std_logic_vector(7 downto 0) := x"15";
    constant REG_TEST_GBE_TEST_MANUAL_READ_MSB    : integer := 17;
    constant REG_TEST_GBE_TEST_MANUAL_READ_LSB     : integer := 0;


end registers;
