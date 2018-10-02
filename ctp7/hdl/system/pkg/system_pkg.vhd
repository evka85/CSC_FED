-------------------------------------------------------------------------------
--                                                                            
--       Unit Name: system_package                                           
--                                                                            
--     Description: 
--
--                                                                            
-------------------------------------------------------------------------------
--                                                                            
--           Notes:                                                           
--                                                                            
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

--============================================================================
--                                                         Package declaration
--============================================================================
package system_package is

  constant g_NUM_OF_GTH_COMMONs : integer := 16;
  constant g_NUM_OF_GTH_GTs     : integer := 36;

  constant BCFG_FW_PROJECT_CODE : std_logic_vector(31 downto 0) := X"B1050001";  -- BIOS 0x1 

  constant BCFG_FW_VERSION_MAJOR : std_logic_vector(7 downto 0) := X"01";
  constant BCFG_FW_VERSION_MINOR : std_logic_vector(7 downto 0) := X"01";
  constant BCFG_FW_VERSION_PATCH : std_logic_vector(7 downto 0) := X"00";

  constant BCFG_LINK_ERR_CNT_WIDTH : integer := 32;

  constant C_ERR_CNT_MAX_COUNT : std_logic_vector(BCFG_LINK_ERR_CNT_WIDTH-1 downto 0) := (others => '1');

  type t_gth_link_type is (gth_1p6g_8b10b_buf, gth_1p25g_8b10b_buf, gth_4p8g_raw_nobuf, gth_3p2g_8b10b_nobuf);

  type t_gth_config is
  record
    gth_link_type        : t_gth_link_type;
    gth_txclk_out_master : boolean;
  end record;

  type t_gth_config_arr is array (0 to g_NUM_OF_GTH_GTs-1) of t_gth_config;

  constant c_gth_config_arr : t_gth_config_arr := (
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 0
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 1
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 2
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 3
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 4
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 5
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 6
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 7
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 8
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 9
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 10
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 11

    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 12
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 13
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 14
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 15
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 16
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 17
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 18
    (gth_1p25g_8b10b_buf, TRUE),                  -- GTH FW Ch 19
    (gth_1p25g_8b10b_buf, false),                  -- GTH FW Ch 20
    (gth_1p25g_8b10b_buf, false),                  -- GTH FW Ch 21
    (gth_1p25g_8b10b_buf, false),                  -- GTH FW Ch 22
    (gth_1p25g_8b10b_buf, false),                  -- GTH FW Ch 23
    
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 24
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 25
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 26
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 27
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 28
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 29
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 30
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 31
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 32
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 33
    (gth_1p6g_8b10b_buf, false),                  -- GTH FW Ch 34
    (gth_1p6g_8b10b_buf, TRUE)                    -- GTH FW Ch 35
    );

end package system_package;
--============================================================================
--                                                                 Package end 
--============================================================================

