library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package csc_pkg is

    --========================--
    --==  Firmware version  ==--
    --========================-- 

    constant C_FIRMWARE_DATE    : std_logic_vector(31 downto 0) := x"20181002";
    constant C_FIRMWARE_MAJOR   : integer range 0 to 255        := 1;
    constant C_FIRMWARE_MINOR   : integer range 0 to 255        := 1;
    constant C_FIRMWARE_BUILD   : integer range 0 to 255        := 5;

    --======================--
    --==      General     ==--
    --======================-- 
        
    constant C_LED_PULSE_LENGTH_TTC_CLK : std_logic_vector(20 downto 0) := std_logic_vector(to_unsigned(1_600_000, 21));

    function count_ones(s : std_logic_vector) return integer;
    function bool_to_std_logic(L : BOOLEAN) return std_logic;

    --======================--
    --== Config Constants ==--
    --======================-- 
    
    -- DAQ
    constant C_DAQ_FORMAT_VERSION     : std_logic_vector(3 downto 0)  := x"0";

    --============--
    --== Common ==--
    --============--   
    
    type t_std_array is array(integer range <>) of std_logic;
  
    type t_std32_array is array(integer range <>) of std_logic_vector(31 downto 0);
        
    type t_std16_array is array(integer range <>) of std_logic_vector(15 downto 0);

    type t_std24_array is array(integer range <>) of std_logic_vector(23 downto 0);

    type t_std4_array is array(integer range <>) of std_logic_vector(3 downto 0);

    type t_std2_array is array(integer range <>) of std_logic_vector(1 downto 0);

    --====================--
    --==     DAQLink    ==--
    --====================--

    type t_daq_to_daqlink is record
        reset           : std_logic;
        ttc_clk         : std_logic;
        ttc_bc0         : std_logic;
        trig            : std_logic_vector(7 downto 0);
        tts_clk         : std_logic;
        tts_state       : std_logic_vector(3 downto 0);
        resync          : std_logic;
        event_clk       : std_logic;
        event_valid     : std_logic;
        event_header    : std_logic;
        event_trailer   : std_logic;
        event_data      : std_logic_vector(63 downto 0);
    end record;

    type t_daqlink_to_daq is record
        ready           : std_logic;
        almost_full     : std_logic;
        disperr_cnt     : std_logic_vector(15 downto 0);
        notintable_cnt  : std_logic_vector(15 downto 0);
    end record;

    --====================--
    --== DAQ data input ==--
    --====================--
    
    type t_data_link is record
        clk        : std_logic;
        data_en    : std_logic;
        data       : std_logic_vector(15 downto 0);
    end record;
    
    type t_data_link_array is array(integer range <>) of t_data_link;    

    --=====================================--
    --==   DAQ input status and control  ==--
    --=====================================--
    
    type t_daq_input_status is record
        evtfifo_empty           : std_logic;
        evtfifo_near_full       : std_logic;
        evtfifo_full            : std_logic;
        evtfifo_underflow       : std_logic;
        evtfifo_near_full_cnt   : std_logic_vector(15 downto 0);
        evtfifo_wr_rate         : std_logic_vector(16 downto 0);
        infifo_empty            : std_logic;
        infifo_near_full        : std_logic;
        infifo_full             : std_logic;
        infifo_underflow        : std_logic;
        infifo_near_full_cnt    : std_logic_vector(15 downto 0);
        infifo_wr_rate          : std_logic_vector(14 downto 0);
        tts_state               : std_logic_vector(3 downto 0);
        err_event_too_big       : std_logic;
        err_evtfifo_full        : std_logic;
        err_infifo_underflow    : std_logic;
        err_infifo_full         : std_logic;
        err_64bit_misaligned    : std_logic;
        eb_event_num            : std_logic_vector(23 downto 0);
    end record;

    type t_daq_input_status_arr is array(integer range <>) of t_daq_input_status;

    type t_daq_input_control is record
        lalala        : std_logic_vector(23 downto 0);
    end record;
    
    type t_daq_input_control_arr is array(integer range <>) of t_daq_input_control;

    --====================--
    --==   DAQ other    ==--
    --====================--

    type t_chamber_infifo_rd is record
        dout          : std_logic_vector(63 downto 0);
        rd_en         : std_logic;
        empty         : std_logic;
        valid         : std_logic;
        underflow     : std_logic;
        data_cnt      : std_logic_vector(13 downto 0);
    end record;

    type t_chamber_infifo_rd_array is array(integer range <>) of t_chamber_infifo_rd;

    type t_chamber_evtfifo_rd is record
        dout          : std_logic_vector(59 downto 0);
        rd_en         : std_logic;
        empty         : std_logic;
        valid         : std_logic;
        underflow     : std_logic;
        data_cnt      : std_logic_vector(11 downto 0);
    end record;

    type t_chamber_evtfifo_rd_array is array(integer range <>) of t_chamber_evtfifo_rd;

    --====================--
    --==     OH Link    ==--
    --====================--

    type t_sync_fifo_status is record
        ovf         : std_logic;
        unf         : std_logic;
    end record;
    
    type t_gt_status is record
        not_in_table    : std_logic;
        disperr         : std_logic;
    end record;

    type t_oh_link_status is record
        tk_error            : std_logic;
        evt_rcvd            : std_logic;
        tk_tx_sync_status   : t_sync_fifo_status;      
        tk_rx_sync_status   : t_sync_fifo_status;      
        tr0_rx_sync_status  : t_sync_fifo_status;      
        tr1_rx_sync_status  : t_sync_fifo_status;
        tk_rx_gt_status     : t_gt_status;     
        tr0_rx_gt_status    : t_gt_status;     
        tr1_rx_gt_status    : t_gt_status;     
    end record;
    
    type t_oh_link_status_arr is array(integer range <>) of t_oh_link_status;    
	
end csc_pkg;
   
package body csc_pkg is

    function count_ones(s : std_logic_vector) return integer is
        variable temp : natural := 0;
    begin
        for i in s'range loop
            if s(i) = '1' then
                temp := temp + 1;
            end if;
        end loop;

        return temp;
    end function count_ones;

    function bool_to_std_logic(L : BOOLEAN) return std_logic is
    begin
        if L then
            return ('1');
        else
            return ('0');
        end if;
    end function bool_to_std_logic;
    
end csc_pkg;