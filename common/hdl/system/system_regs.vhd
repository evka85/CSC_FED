------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company: TAMU
-- Engineer: Evaldas Juska (evaldas.juska@cern.ch, evka85@gmail.com)
-- 
-- Create Date:    15:04 2016-05-10
-- Module Name:    System Registers
-- Description:    this module provides registers for CSC FED system-wide setting  
------------------------------------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.ipbus.all;
use work.csc_pkg.all;
use work.registers.all;
use work.ttc_pkg.all;

entity system_regs is
    generic(
        g_NUM_OF_DMBs   : integer;
        g_BOARD_TYPE    : std_logic_vector(3 downto 0) 
    );
    port(
        
        reset_i                     : in std_logic;
    
        ttc_clks_i                  : in t_ttc_clks;
    
        board_id_o                  : out std_logic_vector(15 downto 0) := (others => '0');
    
        ipb_clk_i                   : in std_logic;
        ipb_reset_i                 : in std_logic;
        ipb_mosi_i                  : in ipb_wbus;
        ipb_miso_o                  : out ipb_rbus
    );
end system_regs;

architecture system_regs_arch of system_regs is

    signal board_type               : std_logic_vector(3 downto 0);
    signal board_id                 : std_logic_vector(15 downto 0) := (others => '0');

    signal version_major            : integer range 0 to 255; 
    signal version_minor            : integer range 0 to 255; 
    signal version_build            : integer range 0 to 255;
    signal firmware_date            : std_logic_vector(31 downto 0);

    signal num_of_dmbs              : std_logic_vector(7 downto 0);
    
    ------ Register signals begin (this section is generated by <csc_amc_repo_root>/scripts/generate_registers.py -- do not edit)
    signal regs_read_arr        : t_std32_array(REG_SYSTEM_NUM_REGS - 1 downto 0);
    signal regs_write_arr       : t_std32_array(REG_SYSTEM_NUM_REGS - 1 downto 0);
    signal regs_addresses       : t_std32_array(REG_SYSTEM_NUM_REGS - 1 downto 0);
    signal regs_defaults        : t_std32_array(REG_SYSTEM_NUM_REGS - 1 downto 0) := (others => (others => '0'));
    signal regs_read_pulse_arr  : std_logic_vector(REG_SYSTEM_NUM_REGS - 1 downto 0);
    signal regs_write_pulse_arr : std_logic_vector(REG_SYSTEM_NUM_REGS - 1 downto 0);
    signal regs_read_ready_arr  : std_logic_vector(REG_SYSTEM_NUM_REGS - 1 downto 0) := (others => '1');
    signal regs_write_done_arr  : std_logic_vector(REG_SYSTEM_NUM_REGS - 1 downto 0) := (others => '1');
    signal regs_writable_arr    : std_logic_vector(REG_SYSTEM_NUM_REGS - 1 downto 0) := (others => '0');
    ------ Register signals end ----------------------------------------------
    
begin

    board_id_o <= board_id;

    --=== version and date === --
    
    firmware_date <= C_FIRMWARE_DATE;
    version_major <= C_FIRMWARE_MAJOR;
    version_minor <= C_FIRMWARE_MINOR;
    version_build <= C_FIRMWARE_BUILD;

    --=== board type and configuration parameters ===--
    board_type     <= g_BOARD_TYPE;
    num_of_dmbs    <= std_logic_vector(to_unsigned(g_NUM_OF_DMBs, 8));
    
    --===============================================================================================
    -- this section is generated by <csc_amc_repo_root>/scripts/generate_registers.py (do not edit) 
    --==== Registers begin ==========================================================================

    -- IPbus slave instanciation
    ipbus_slave_inst : entity work.ipbus_slave
        generic map(
           g_NUM_REGS             => REG_SYSTEM_NUM_REGS,
           g_ADDR_HIGH_BIT        => REG_SYSTEM_ADDRESS_MSB,
           g_ADDR_LOW_BIT         => REG_SYSTEM_ADDRESS_LSB,
           g_USE_INDIVIDUAL_ADDRS => true
       )
       port map(
           ipb_reset_i            => ipb_reset_i,
           ipb_clk_i              => ipb_clk_i,
           ipb_mosi_i             => ipb_mosi_i,
           ipb_miso_o             => ipb_miso_o,
           usr_clk_i              => ipb_clk_i,
           regs_read_arr_i        => regs_read_arr,
           regs_write_arr_o       => regs_write_arr,
           read_pulse_arr_o       => regs_read_pulse_arr,
           write_pulse_arr_o      => regs_write_pulse_arr,
           regs_read_ready_arr_i  => regs_read_ready_arr,
           regs_write_done_arr_i  => regs_write_done_arr,
           individual_addrs_arr_i => regs_addresses,
           regs_defaults_arr_i    => regs_defaults,
           writable_regs_i        => regs_writable_arr
      );

    -- Addresses
    regs_addresses(0)(REG_SYSTEM_ADDRESS_MSB downto REG_SYSTEM_ADDRESS_LSB) <= '0' & x"002";
    regs_addresses(1)(REG_SYSTEM_ADDRESS_MSB downto REG_SYSTEM_ADDRESS_LSB) <= '0' & x"003";
    regs_addresses(2)(REG_SYSTEM_ADDRESS_MSB downto REG_SYSTEM_ADDRESS_LSB) <= '0' & x"004";
    regs_addresses(3)(REG_SYSTEM_ADDRESS_MSB downto REG_SYSTEM_ADDRESS_LSB) <= '0' & x"005";

    -- Connect read signals
    regs_read_arr(0)(REG_SYSTEM_BOARD_ID_MSB downto REG_SYSTEM_BOARD_ID_LSB) <= board_id;
    regs_read_arr(0)(REG_SYSTEM_BOARD_TYPE_MSB downto REG_SYSTEM_BOARD_TYPE_LSB) <= board_type;
    regs_read_arr(1)(REG_SYSTEM_RELEASE_BUILD_MSB downto REG_SYSTEM_RELEASE_BUILD_LSB) <= std_logic_vector(to_unsigned(version_build, 8));
    regs_read_arr(1)(REG_SYSTEM_RELEASE_MINOR_MSB downto REG_SYSTEM_RELEASE_MINOR_LSB) <= std_logic_vector(to_unsigned(version_minor, 8));
    regs_read_arr(1)(REG_SYSTEM_RELEASE_MAJOR_MSB downto REG_SYSTEM_RELEASE_MAJOR_LSB) <= std_logic_vector(to_unsigned(version_major, 8));
    regs_read_arr(2)(REG_SYSTEM_RELEASE_DATE_MSB downto REG_SYSTEM_RELEASE_DATE_LSB) <= firmware_date;
    regs_read_arr(3)(REG_SYSTEM_CONFIG_NUM_OF_DMBS_MSB downto REG_SYSTEM_CONFIG_NUM_OF_DMBS_LSB) <= num_of_dmbs;

    -- Connect write signals
    board_id <= regs_write_arr(0)(REG_SYSTEM_BOARD_ID_MSB downto REG_SYSTEM_BOARD_ID_LSB);

    -- Connect write pulse signals

    -- Connect write done signals

    -- Connect read pulse signals

    -- Connect read ready signals

    -- Defaults
    regs_defaults(0)(REG_SYSTEM_BOARD_ID_MSB downto REG_SYSTEM_BOARD_ID_LSB) <= REG_SYSTEM_BOARD_ID_DEFAULT;

    -- Define writable regs
    regs_writable_arr(0) <= '1';

    --==== Registers end ============================================================================

end system_regs_arch;