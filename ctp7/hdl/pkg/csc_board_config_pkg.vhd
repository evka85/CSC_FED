------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company: TAMU
-- Engineer: Evaldas Juska (evaldas.juska@cern.ch, evka85@gmail.com)
-- 
-- Create Date:    21:00:00 2016-11-17
-- Module Name:    CSC BOARD CONFIG PACKAGE
-- Description:    This package defines high level CSC FED board configuration for CTP7.
--                 Lower level things like GTH configuration are defined in system_pkg.vhd (e.g. line rates, encoding, buffering, clocking, etc)
------------------------------------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;

--============================================================================
--                                                         Package declaration
--============================================================================
package csc_board_config_package is

    --=============--
    --== General ==--
    --=============--

    constant CFG_BOARD_TYPE         : std_logic_vector(3 downto 0) := x"1"; 

    --======================--
    --== DMB link mapping ==--
    --======================--    

    type t_dmb_rx_fiber_arr is array (0 to 2) of integer range 0 to 71;
    type t_dmb_config is record
        num_fibers  : integer range 0 to 3; -- number of downlink fibers to be used for this DMB (should be 1 for old DMBs/ODMBs, and greater than 1 for multilink ODMBs)
        rx_fibers   : t_dmb_rx_fiber_arr;       -- RX fiber number(s) to be used for this DMB (only items [0 to num_fibers -1] will be used)  
    end record;

    type t_dmb_config_arr is array (integer range <>) of t_dmb_config;
    
    --***********************************************************************************************************
    --***********************************************************************************************************
    --***********************************************************************************************************
    -- This is the meat of this config file: here's where you define the number of DMBs and their fiber numbers
    -- There's no distinction between different types of DMBs here - any type of DMB is simply called a DMB (copper DMBs, 1.6Gbs ODMBs, future 10Gbs ODMBs, and even multilink ODMBs) 
    -- In case of multilink ODMBs just indicate the correct number of fibers in t_dmb_config::num_fibers
    -- Fiber numbers start from 0 and go from the top of the board to the bottom in this order:
    --    CXP0 (0-11), CXP1 (12-23), CXP2 (24-35), MP0 / MP TX (36-47), MP1 (48-59), MP2(60-71)
    --    !!! there are some MiniPOD RX fibers that are not connected to FPGA (see CFG_RX_FIBER_TO_GTH_MAP) !!!
    -- It's very important that the link number of each DMB is corresponding to the correct type of GTH configuration (which is defined in system_pkg.vhd)
    -- See the bottom of the file for fiber to GTH mapping (CFG_RX_FIBER_TO_GTH_MAP and CFG_TX_FIBER_TO_GTH_MAP)

-- ------------------ two input version for 904 --------------------
--    constant CFG_NUM_DMBS           : integer := 2;    -- total number of DMBs to instanciate
--
--    constant CFG_DMB_CONFIG_ARR : t_dmb_config_arr(0 to CFG_NUM_DMBS - 1) := (
--        (num_fibers => 1, rx_fibers => (10, 0, 0)),      -- 904 ME2/1 "copper" DMB
--        (num_fibers => 1, rx_fibers => (11, 0, 0))       -- 904 ME1/1 ODMB
--    );
--
--    constant CFG_USE_SPY_LINK : boolean := true;
--    constant CFG_SPY_LINK     : integer := 35;
---------------------------------------------------------------------

    constant CFG_NUM_DMBS           : integer := 24;    -- total number of DMBs to instanciate

    constant CFG_DMB_CONFIG_ARR : t_dmb_config_arr(0 to CFG_NUM_DMBS - 1) := (
        (num_fibers => 1, rx_fibers => (0, 0, 0)),
        (num_fibers => 1, rx_fibers => (1, 0, 0)),
        (num_fibers => 1, rx_fibers => (2, 0, 0)),
        (num_fibers => 1, rx_fibers => (3, 0, 0)),
        (num_fibers => 1, rx_fibers => (4, 0, 0)),
        (num_fibers => 1, rx_fibers => (5, 0, 0)),
        (num_fibers => 1, rx_fibers => (6, 0, 0)),
        (num_fibers => 1, rx_fibers => (7, 0, 0)),
        (num_fibers => 1, rx_fibers => (8, 0, 0)),
        (num_fibers => 1, rx_fibers => (9, 0, 0)),
        (num_fibers => 1, rx_fibers => (10, 0, 0)),
        (num_fibers => 1, rx_fibers => (11, 0, 0)),

        (num_fibers => 1, rx_fibers => (12, 0, 0)),
        (num_fibers => 1, rx_fibers => (13, 0, 0)),
        (num_fibers => 1, rx_fibers => (14, 0, 0)),
        (num_fibers => 1, rx_fibers => (15, 0, 0)),
        (num_fibers => 1, rx_fibers => (16, 0, 0)),
        (num_fibers => 1, rx_fibers => (17, 0, 0)),
        (num_fibers => 1, rx_fibers => (18, 0, 0)),
        (num_fibers => 1, rx_fibers => (19, 0, 0)),
        (num_fibers => 1, rx_fibers => (20, 0, 0)),
        (num_fibers => 1, rx_fibers => (21, 0, 0)),
        (num_fibers => 1, rx_fibers => (22, 0, 0)),
        (num_fibers => 1, rx_fibers => (23, 0, 0))
    );

    constant CFG_USE_SPY_LINK : boolean := false;
    constant CFG_SPY_LINK : integer := 35;

    
    --***********************************************************************************************************
    --***********************************************************************************************************
    --***********************************************************************************************************

    --===================================--
    --== Physical fiber to GTH mapping ==--
    --===================================--

    type t_fiber_to_gth_map is array (integer range <>) of integer range 0 to 99;

    -- this constant holds the mapping of physical downlink fiber number (array index) to the GTH instance number.
    -- GTH #99 is a special value indicating non-existing GTH (used in the case of fibers that are physically not connected to the FPGA -- there are some of these in MiniPODs)    
    constant CFG_RX_FIBER_TO_GTH_MAP : t_fiber_to_gth_map(0 to 71) := (
        --=== CXP0 ===--
        2,  -- fiber 0
        0,  -- fiber 1
        4,  -- fiber 2
        3,  -- fiber 3
        5,  -- fiber 4
        1,  -- fiber 5
        7,  -- fiber 6
        9,  -- fiber 7
        10, -- fiber 8
        6,  -- fiber 9
        8,  -- fiber 10
        11, -- fiber 11
        --=== CXP1 ===--
        15, -- fiber 12
        12, -- fiber 13
        16, -- fiber 14
        14, -- fiber 15 
        18, -- fiber 16
        13, -- fiber 17
        19, -- fiber 18
        23, -- fiber 19
        20, -- fiber 20
        17, -- fiber 21
        21, -- fiber 22
        22, -- fiber 23
        --=== CXP2 ===--
        27, -- fiber 24
        24, -- fiber 25
        28, -- fiber 26
        26, -- fiber 27
        30, -- fiber 28
        25, -- fiber 29
        31, -- fiber 30
        35, -- fiber 31
        32, -- fiber 32
        29, -- fiber 33
        33, -- fiber 34
        34, -- fiber 35
        --=== MP0 ===--
        56, -- fiber 36
        57, -- fiber 37
        58, -- fiber 38
        59, -- fiber 39
        60, -- fiber 40
        61, -- fiber 41
        63, -- fiber 42
        62, -- fiber 43
        99, -- fiber 44 -- RX NULL (GTH not instanciated, should be 65)
        99, -- fiber 45 -- RX NULL (GTH not instanciated, should be 64)
        99, -- fiber 46 -- RX NULL (GTH not instanciated, should be 66)
        99, -- fiber 47 -- RX NULL (not connected to FPGA)
        --=== MP1 ===--
        44, -- fiber 48
        45, -- fiber 49
        46, -- fiber 50
        47, -- fiber 51
        48, -- fiber 52
        49, -- fiber 53
        51, -- fiber 54
        50, -- fiber 55
        53, -- fiber 56
        52, -- fiber 57
        55, -- fiber 58
        54, -- fiber 59
        --=== MP2 ===--
        39, -- fiber 60
        38, -- fiber 61
        37, -- fiber 62
        41, -- fiber 63
        36, -- fiber 64
        40, -- fiber 65
        99, -- fiber 66 -- NULL (not connected to FPGA)
        42, -- fiber 67 
        99, -- fiber 68 -- NULL (not connected to FPGA)
        43, -- fiber 69
        99, -- fiber 70 -- NULL (not connected to FPGA)
        99  -- fiber 71 -- NULL (not connected to FPGA)
    );

    -- this constant holds the mapping of physical uplink fiber number (array index) to the GTH instance number.
    constant CFG_TX_FIBER_TO_GTH_MAP : t_fiber_to_gth_map(0 to 47) := (
        --=== CXP0 ===--
        1,   -- fiber 0
        3,   -- fiber 1
        5,   -- fiber 2
        0,   -- fiber 3
        2,   -- fiber 4
        4,   -- fiber 5
        10,  -- fiber 6
        8,   -- fiber 7
        6,   -- fiber 8
        11,  -- fiber 9
        9,   -- fiber 10
        7,   -- fiber 11
        --=== CXP1 ===--
        13,  -- fiber 12
        15,  -- fiber 13
        17,  -- fiber 14
        12,  -- fiber 15 
        14,  -- fiber 16
        16,  -- fiber 17
        22,  -- fiber 18
        20,  -- fiber 19
        18,  -- fiber 20
        23,  -- fiber 21
        21,  -- fiber 22
        19,  -- fiber 23
        --=== CXP2 ===--
        25,  -- fiber 24
        27,  -- fiber 25
        29,  -- fiber 26
        24,  -- fiber 27
        26,  -- fiber 28
        28,  -- fiber 29
        34,  -- fiber 30
        32,  -- fiber 31
        30,  -- fiber 32
        35,  -- fiber 33
        33,  -- fiber 34
        31,  -- fiber 35
        --=== MiniPOD TX ===--
        57,  -- fiber 36
        58,  -- fiber 37
        55,  -- fiber 38
        60,  -- fiber 39
        54,  -- fiber 40
        61,  -- fiber 41
        53,  -- fiber 42
        62,  -- fiber 43 
        52,  -- fiber 44
        63,  -- fiber 45
        56,  -- fiber 46
        59   -- fiber 47
    );
    
end package csc_board_config_package;
--============================================================================
--                                                                 Package end 
--============================================================================

