------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company: TAMU
-- Engineer: Evaldas Juska (evaldas.juska@cern.ch, evka85@gmail.com)
-- 
-- Create Date:    20:18 2015-09-17
-- Module Name:    DAQ
-- Description:    This module buffers input data, builds events, analyses the data for consistency and ships off the events with all the needed headers and trailers to AMC13 over DAQLink  
------------------------------------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_misc.all;
use ieee.numeric_std.all;

use work.gth_pkg.all;
use work.csc_pkg.all;
use work.ttc_pkg.all;
use work.ipbus.all;
use work.registers.all;

entity daq is
generic(
    g_NUM_OF_DMBs        : integer;
    g_DAQ_CLK_FREQ       : integer
);
port(

    -- Reset
    reset_i                     : in  std_logic;

    -- DAQ clock
    daq_clk_i                   : in  std_logic;
    daq_clk_locked_i            : in  std_logic;

    -- DAQLink
    daq_to_daqlink_o            : out t_daq_to_daqlink;
    daqlink_to_daq_i            : in  t_daqlink_to_daq;
        
    -- TTC
    ttc_clks_i                  : in  t_ttc_clks;
    ttc_cmds_i                  : in  t_ttc_cmds;
    ttc_daq_cntrs_i             : in  t_ttc_daq_cntrs;
    ttc_status_i                : in  t_ttc_status;

    -- Data
    input_clk_arr_i             : in std_logic_vector(g_NUM_OF_DMBs - 1 downto 0);
    input_link_arr_i            : in t_gt_8b10b_rx_data_arr(g_NUM_OF_DMBs - 1 downto 0);
    
    -- Spy
    spy_clk_i                   : in  std_logic;
    spy_link_o                  : out t_gt_8b10b_tx_data;
    
    -- IPbus
    ipb_reset_i                 : in  std_logic;
    ipb_clk_i                   : in  std_logic;
	ipb_mosi_i                  : in  ipb_wbus;
	ipb_miso_o                  : out ipb_rbus;
    
    -- Other
    board_id_i                  : in  std_logic_vector(15 downto 0); -- board ID
    tts_ready_o                 : out std_logic
    
);
end daq;

architecture Behavioral of daq is

    --================== COMPONENTS ==================--

    component daq_l1a_fifo is
        port(
            rst           : in  std_logic;
            wr_clk        : in  std_logic;
            rd_clk        : in  std_logic;
            din           : in  std_logic_vector(52 downto 0);
            wr_en         : in  std_logic;
            wr_ack        : out std_logic;
            rd_en         : in  std_logic;
            dout          : out std_logic_vector(52 downto 0);
            full          : out std_logic;
            overflow      : out std_logic;
            almost_full   : out std_logic;
            empty         : out std_logic;
            valid         : out std_logic;
            underflow     : out std_logic;
            prog_full     : out std_logic;
            rd_data_count : out std_logic_vector(12 downto 0)
        );
    end component daq_l1a_fifo;  

    component daq_output_fifo
        port(
            clk           : in  std_logic;
            rst           : in  std_logic;
            din           : in  std_logic_vector(65 downto 0);
            wr_en         : in  std_logic;
            rd_en         : in  std_logic;
            dout          : out std_logic_vector(65 downto 0);
            full          : out std_logic;
            empty         : out std_logic;
            valid         : out std_logic;
            prog_full     : out std_logic;
            data_count    : out std_logic_vector(12 downto 0)
        );
    end component;

    component daq_last_event_fifo
        port(
            rst      : in  std_logic;
            wr_clk   : in  std_logic;
            rd_clk   : in  std_logic;
            din      : in  std_logic_vector(63 downto 0);
            wr_en    : in  std_logic;
            rd_en    : in  std_logic;
            dout     : out std_logic_vector(31 downto 0);
            full     : out std_logic;
            overflow : out std_logic;
            empty    : out std_logic;
            valid    : out std_logic
        );
    end component;

    component daq_spy_fifo
        port(
            rst          : in  std_logic;
            wr_clk       : in  std_logic;
            rd_clk       : in  std_logic;
            din          : in  std_logic_vector(63 downto 0);
            wr_en        : in  std_logic;
            rd_en        : in  std_logic;
            dout         : out std_logic_vector(15 downto 0);
            full         : out std_logic;
            overflow     : out std_logic;
            empty        : out std_logic;
            almost_empty : out std_logic;
            prog_full    : out std_logic
        );
    end component;

    --================== SIGNALS ==================--

    -- Reset
    signal reset_global         : std_logic := '1';
    signal reset_daq_async      : std_logic := '1';
    signal reset_daq_async_dly  : std_logic := '1';
    signal reset_daq            : std_logic := '1';
    signal reset_daqlink        : std_logic := '1'; -- should only be done once at powerup
    signal reset_pwrup          : std_logic := '1';
    signal reset_local          : std_logic := '1';
    signal reset_local_latched  : std_logic := '0';
    signal reset_daqlink_ipb    : std_logic := '0';

    -- DAQlink
    signal daq_event_data       : std_logic_vector(63 downto 0) := (others => '0');
    signal daq_event_write_en   : std_logic := '0';
    signal daq_event_header     : std_logic := '0';
    signal daq_event_trailer    : std_logic := '0';
    signal daq_ready            : std_logic := '0';
    signal daq_almost_full      : std_logic := '0';

    signal daq_disper_err_cnt   : std_logic_vector(15 downto 0) := (others => '0');
    signal daq_notintable_err_cnt: std_logic_vector(15 downto 0) := (others => '0');
    signal daqlink_afull_cnt    : std_logic_vector(15 downto 0) := (others => '0');

    -- Main DAQ FSM signals
    signal daq_not_empty_event  : std_logic := '0';
    signal ddu_crc              : std_logic_vector(15 downto 0) := (others => '0');
  
    -- DAQ Error Flags
    signal err_l1afifo_full     : std_logic := '0';
    signal err_daqfifo_full     : std_logic := '0';

    -- TTS
    signal tts_state            : std_logic_vector(3 downto 0) := "1000";
    signal tts_critical_error   : std_logic := '0'; -- critical error detected - RESYNC/RESET NEEDED
    signal tts_warning          : std_logic := '0'; -- overflow warning - STOP TRIGGERS
    signal tts_out_of_sync      : std_logic := '0'; -- out-of-sync - RESYNC NEEDED
    signal tts_busy             : std_logic := '0'; -- I'm busy - NO TRIGGERS FOR NOW, PLEASE
    signal tts_override         : std_logic_vector(3 downto 0) := x"0"; -- this can be set via IPbus and will override the TTS state if it's not x"0" (regardless of reset_daq and daq_enable)
    
    signal tts_chmb_critical_arr: std_logic_vector(g_NUM_OF_DMBs - 1 downto 0) := (others => '0'); -- input critical error detected - RESYNC/RESET NEEDED
    signal tts_chmb_warning_arr : std_logic_vector(g_NUM_OF_DMBs - 1 downto 0) := (others => '0'); -- input overflow warning - STOP TRIGGERS
    signal tts_chmb_oos_arr     : std_logic_vector(g_NUM_OF_DMBs - 1 downto 0) := (others => '0'); -- input out-of-sync - RESYNC NEEDED
    signal tts_chmb_critical    : std_logic := '0'; -- input critical error detected - RESYNC/RESET NEEDED
    signal tts_chmb_warning     : std_logic := '0'; -- input overflow warning - STOP TRIGGERS
    signal tts_chmb_oos         : std_logic := '0'; -- input out-of-sync - RESYNC NEEDED

    signal tts_start_cntdwn_chmb: unsigned(7 downto 0) := x"ff";
    signal tts_start_cntdwn     : unsigned(7 downto 0) := x"ff";

    signal tts_warning_cnt      : std_logic_vector(15 downto 0);

    -- Resync
    signal resync_mode          : std_logic := '0'; -- when this signal is asserted it means that we received a resync and we're still processing the L1A fifo and holding TTS in BUSY
    signal resync_done          : std_logic := '0'; -- when this is asserted it means that L1As have been drained and we're ready to reset the DAQ and tell AMC13 that we're done
    signal resync_done_delayed  : std_logic := '0';

    -- Error signals transfered to TTS clk domain
    signal tts_chmb_critical_tts_clk    : std_logic := '0'; -- tts_chmb_critical transfered to TTS clock domain
    signal tts_chmb_warning_tts_clk     : std_logic := '0'; -- tts_chmb_warning transfered to TTS clock domain
    signal tts_chmb_out_of_sync_tts_clk : std_logic := '0'; -- tts_chmb_out_of_sync transfered to TTS clock domain
    signal err_daqfifo_full_tts_clk     : std_logic := '0'; -- err_daqfifo_full transfered to TTS clock domain
    
    -- DAQ conf
    signal daq_enable           : std_logic := '1'; -- enable sending data to DAQLink
    signal input_mask           : std_logic_vector(23 downto 0) := x"000000";
    signal run_type             : std_logic_vector(3 downto 0) := x"0"; -- run type (set by software and included in the AMC header)
    signal run_params           : std_logic_vector(23 downto 0) := x"000000"; -- optional run parameters (set by software and included in the AMC header)
    signal ignore_amc13         : std_logic := '0'; -- when this is set to true, DAQLink status is ignored (useful for local spy-only data taking) 
    signal block_last_evt_fifo  : std_logic := '0'; -- if true, then events are not written to the last event fifo (could be useful to toggle this from software in order to know how many events are read exactly because sometimes you may miss empty=true)
    signal freeze_on_error      : std_logic := '0'; -- this is a debug feature which when turned on will start sending only IDLE words to all input processors as soon as TTS error is detected
    signal reset_till_resync    : std_logic := '0'; -- if this is true, then after the user removes the reset, this module will still stay in reset till the resync is received. This is handy for starting to take data in the middle of an active run.
    
    -- DAQ counters
    signal cnt_sent_events      : unsigned(31 downto 0) := (others => '0');

    -- DAQ event sending state machine
    type t_daq_state is (IDLE, AMC13_HEADER_1, AMC13_HEADER_2, FED_HEADER_1, FED_HEADER_2, FED_HEADER_3, PAYLOAD, FED_TRAILER_1, FED_TRAILER_2, FED_TRAILER_3, AMC13_TRAILER);
    signal daq_state            : t_daq_state := IDLE;
    signal daq_curr_infifo_word : unsigned(11 downto 0) := (others => '0');
        
    -- IPbus registers
    type ipb_state_t is (IDLE, RSPD, RST);
    signal ipb_state                : ipb_state_t := IDLE;    
    signal ipb_reg_sel              : integer range 0 to (16 * (g_NUM_OF_DMBs + 10)) + 15;  -- 16 regs for AMC evt builder and 16 regs for each chamber evt builder   
    signal ipb_read_reg_data        : t_std32_array(0 to (16 * (g_NUM_OF_DMBs + 10)) + 15); -- 16 regs for AMC evt builder and 16 regs for each chamber evt builder
    signal ipb_write_reg_data       : t_std32_array(0 to (16 * (g_NUM_OF_DMBs + 10)) + 15); -- 16 regs for AMC evt builder and 16 regs for each chamber evt builder
    
    -- L1A FIFO
    signal l1afifo_din          : std_logic_vector(52 downto 0) := (others => '0');
    signal l1afifo_wr_en        : std_logic := '0';
    signal l1afifo_rd_en        : std_logic := '0';
    signal l1afifo_dout         : std_logic_vector(52 downto 0);
    signal l1afifo_full         : std_logic;
    signal l1afifo_overflow     : std_logic;
    signal l1afifo_empty        : std_logic;
    signal l1afifo_valid        : std_logic;
    signal l1afifo_underflow    : std_logic;
    signal l1afifo_near_full    : std_logic;
    signal l1afifo_data_cnt     : std_logic_vector(12 downto 0);
    signal l1afifo_near_full_cnt: std_logic_vector(15 downto 0);
    signal l1a_gap_cntdown      : unsigned(7 downto 0) := (others => '0'); -- this is used to detect close L1As (meaning less than 1000ns apart)
    
    -- DAQ output FIFO
    signal daqfifo_din          : std_logic_vector(65 downto 0) := (others => '0');
    signal daqfifo_wr_en        : std_logic := '0';
    signal daqfifo_rd_en        : std_logic := '0';
    signal daqfifo_dout         : std_logic_vector(65 downto 0);
    signal daqfifo_full         : std_logic;
    signal daqfifo_empty        : std_logic;
    signal daqfifo_valid        : std_logic;
    signal daqfifo_near_full    : std_logic;
    signal daqfifo_data_cnt     : std_logic_vector(12 downto 0);
    signal daqfifo_near_full_cnt: std_logic_vector(15 downto 0);
            
    -- Last event spy fifo
    signal last_evt_fifo_en     : std_logic := '0';
    signal last_evt_fifo_rd_en  : std_logic := '0';
    signal last_evt_fifo_dout   : std_logic_vector(31 downto 0);
    signal last_evt_fifo_empty  : std_logic := '0';
    signal last_evt_fifo_valid  : std_logic := '0';
    
    -- Spy path
    signal spy_fifo_wr_en       : std_logic;
    signal spy_fifo_rd_en       : std_logic;
    signal spy_fifo_dout        : std_logic_vector(15 downto 0);
    signal spy_fifo_ovf         : std_logic;
    signal spy_fifo_empty       : std_logic;
    signal spy_fifo_aempty      : std_logic;
    signal spy_fifo_afull       : std_logic;
    signal err_spy_fifo_ovf     : std_logic;
    signal spy_fifo_afull_cnt   : std_logic_vector(15 downto 0);
    
    signal spy_gbe_skip_headers : std_logic;
    signal spy_prescale         : std_logic_vector(15 downto 0);
    signal spy_skip_empty_evts  : std_logic;
    
    signal spy_err_evt_too_big  : std_logic;
    signal spy_err_eoe_not_found: std_logic;
    signal spy_word_rate        : std_logic_vector(31 downto 0);
    signal spy_evt_sent         : std_logic_vector(31 downto 0);
    signal spy_prescale_counter : unsigned(15 downto 0) := x"0001";    
    signal spy_prescale_keep_evt: std_logic := '0';
                
    -- Timeouts
    signal dav_timer            : unsigned(23 downto 0) := (others => '0'); -- TODO: probably don't need this to be so large.. (need to test)
    signal max_dav_timer        : unsigned(23 downto 0) := (others => '0'); -- TODO: probably don't need this to be so large.. (need to test)
    signal last_dav_timer       : unsigned(23 downto 0) := (others => '0'); -- TODO: probably don't need this to be so large.. (need to test)
    signal dav_timeout          : std_logic_vector(23 downto 0) := x"03d090"; -- 10ms (very large)
    signal dav_timeout_flags    : std_logic_vector(23 downto 0) := (others => '0'); -- inputs which have timed out
    
    ---=== AMC Event Builder signals ===---
    
    -- index of the input currently being processed
    signal e_input_idx                : integer range 0 to 23 := 0;
    -- flag saying if this is the first cycle of payload sending of the current input
    signal e_payload_first_cycle      : std_logic := '1';
    
    -- word count of the event being sent
    signal e_word_count               : unsigned(19 downto 0) := (others => '0');

    -- bitmask indicating chambers with data for the event being sent
    signal e_dav_mask                 : std_logic_vector(23 downto 0) := (others => '0');
    -- number of chambers with data for the event being sent
    signal e_dav_count                : integer range 0 to 24;
           
    ---=== Chamber Event Builder signals ===---
    
    signal chamber_infifos      : t_chamber_infifo_rd_array(0 to g_NUM_OF_DMBs - 1);
    signal chamber_evtfifos     : t_chamber_evtfifo_rd_array(0 to g_NUM_OF_DMBs - 1);
    signal chmb_evtfifos_empty  : std_logic_vector(g_NUM_OF_DMBs - 1 downto 0) := (others => '1'); -- you should probably just move this flag out of the t_chamber_evtfifo_rd_array struct 
    signal chmb_evtfifos_rd_en  : std_logic_vector(g_NUM_OF_DMBs - 1 downto 0) := (others => '0'); -- you should probably just move this flag out of the t_chamber_evtfifo_rd_array struct 
    signal chmb_infifos_rd_en   : std_logic_vector(g_NUM_OF_DMBs - 1 downto 0) := (others => '0'); -- you should probably just move this flag out of the t_chamber_evtfifo_rd_array struct 
    signal chmb_tts_states      : t_std4_array(0 to g_NUM_OF_DMBs - 1);
    
    signal err_event_too_big    : std_logic;
    signal err_evtfifo_underflow: std_logic;

    --=== Input processor status and control ===--
    signal input_status_arr     : t_daq_input_status_arr(g_NUM_OF_DMBs -1 downto 0);
    signal input_control_arr    : t_daq_input_control_arr(g_NUM_OF_DMBs -1 downto 0);

    --=== Rate counters ===--
    signal daq_word_rate        : std_logic_vector(31 downto 0) := (others => '0');
    signal daq_evt_rate         : std_logic_vector(31 downto 0) := (others => '0');

    ------ Register signals begin (this section is generated by <gem_amc_repo_root>/scripts/generate_registers.py -- do not edit)
    signal regs_read_arr        : t_std32_array(REG_DAQ_NUM_REGS - 1 downto 0);
    signal regs_write_arr       : t_std32_array(REG_DAQ_NUM_REGS - 1 downto 0);
    signal regs_addresses       : t_std32_array(REG_DAQ_NUM_REGS - 1 downto 0);
    signal regs_defaults        : t_std32_array(REG_DAQ_NUM_REGS - 1 downto 0) := (others => (others => '0'));
    signal regs_read_pulse_arr  : std_logic_vector(REG_DAQ_NUM_REGS - 1 downto 0);
    signal regs_write_pulse_arr : std_logic_vector(REG_DAQ_NUM_REGS - 1 downto 0);
    signal regs_read_ready_arr  : std_logic_vector(REG_DAQ_NUM_REGS - 1 downto 0) := (others => '1');
    signal regs_write_done_arr  : std_logic_vector(REG_DAQ_NUM_REGS - 1 downto 0) := (others => '1');
    signal regs_writable_arr    : std_logic_vector(REG_DAQ_NUM_REGS - 1 downto 0) := (others => '0');
    ------ Register signals end ----------------------------------------------

begin

    -- TODO DAQ main tasks:
    --   * Handle OOS
    --   * Implement buffer status in the AMC header
    --   * TTS State aggregation
    --   * Check for VFAT and OH BX vs L1A bx mismatches
    --   * Resync handling
    --   * Stop building events if input fifo is full -- let it drain to some level and only then restart building (otherwise you're pointing to inexisting data). I guess it's better to loose some data than to have something that doesn't make any sense..

    --================================--
    -- DAQLink interface
    --================================--
    
    daq_to_daqlink_o.reset <= '0'; -- will need to investigate this later
    daq_to_daqlink_o.resync <= resync_done_delayed;
    daq_to_daqlink_o.trig <= x"00";
    daq_to_daqlink_o.ttc_clk <= ttc_clks_i.clk_40;
    daq_to_daqlink_o.ttc_bc0 <= ttc_cmds_i.bc0;
    daq_to_daqlink_o.tts_clk <= ttc_clks_i.clk_40;
    daq_to_daqlink_o.tts_state <= tts_state;
    daq_to_daqlink_o.event_clk <= daq_clk_i;
    daq_to_daqlink_o.event_data <= daqfifo_dout(63 downto 0);
    daq_to_daqlink_o.event_header <= daqfifo_dout(65);
    daq_to_daqlink_o.event_trailer <= daqfifo_dout(64);
    daq_to_daqlink_o.event_valid <= daqfifo_valid;
    tts_ready_o <= '1' when tts_state = x"8" else '0';

    daq_ready <= daqlink_to_daq_i.ready;
    daq_almost_full <= daqlink_to_daq_i.almost_full;
    daq_disper_err_cnt <= daqlink_to_daq_i.disperr_cnt;
    daq_notintable_err_cnt <= daqlink_to_daq_i.notintable_cnt;
    
    i_resync_delay : entity work.synchronizer
        generic map(
            N_STAGES => 4
        )
        port map(
            async_i => resync_done,
            clk_i   => ttc_clks_i.clk_40,
            sync_o  => resync_done_delayed
        );
    
    --================================--
    -- Resets
    --================================--

    i_reset_sync : entity work.synchronizer
        generic map(
            N_STAGES => 3
        )
        port map(
            async_i => reset_i,
            clk_i   => ttc_clks_i.clk_40,
            sync_o  => reset_global
        );
    
    reset_daq_async <= reset_pwrup or reset_global or reset_local or resync_done_delayed or reset_local_latched;
    reset_daqlink <= reset_pwrup or reset_global or reset_daqlink_ipb;
    
    -- Reset after powerup
    
    process(ttc_clks_i.clk_40)
        variable countdown : integer := 40_000_000; -- probably way too long, but ok for now (this is only used after powerup)
    begin
        if (rising_edge(ttc_clks_i.clk_40)) then
            if (countdown > 0) then
              reset_pwrup <= '1';
              countdown := countdown - 1;
            else
              reset_pwrup <= '0';
            end if;
        end if;
    end process;

    -- delay and extend the reset pulse

    i_rst_delay : entity work.synchronizer
        generic map(
            N_STAGES => 4
        )
        port map(
            async_i => reset_daq_async,
            clk_i   => ttc_clks_i.clk_40,
            sync_o  => reset_daq_async_dly
        );

    i_rst_extend : entity work.pulse_extend
        generic map(
            DELAY_CNT_LENGTH => 3
        )
        port map(
            clk_i          => ttc_clks_i.clk_40,
            rst_i          => '0',
            pulse_length_i => "111",
            pulse_i        => reset_daq_async_dly,
            pulse_o        => reset_daq
        );

    -- if reset_till_resync option is enabled, latch the user requested reset_local till a resync is received
    
    process(ttc_clks_i.clk_40)
    begin
        if (rising_edge(ttc_clks_i.clk_40)) then
            if (reset_till_resync = '1') then
                if (reset_local = '1') then
                    reset_local_latched <= '1'; 
                elsif (ttc_cmds_i.resync = '1') then
                    reset_local_latched  <= '0';
                else 
                    reset_local_latched <= reset_local_latched;
                end if;
            else
                reset_local_latched <= '0';
            end if;
        end if;
    end process;

    --================================--
    -- Last event spy fifo
    --================================--

    i_last_event_fifo : component daq_last_event_fifo
        port map(
            rst      => reset_daq,
            wr_clk   => daq_clk_i,
            rd_clk   => ipb_clk_i,
            din      => daq_event_data,
            wr_en    => daq_event_write_en and last_evt_fifo_en,
            rd_en    => last_evt_fifo_rd_en,
            dout     => last_evt_fifo_dout,
            full     => open,
            overflow => open,
            empty    => last_evt_fifo_empty,
            valid    => last_evt_fifo_valid
        );

    --================================--
    -- DAQ output FIFO
    --================================--
    
    i_daq_fifo : component daq_output_fifo
    port map(
        clk           => daq_clk_i,
        rst           => reset_daq,
        din           => daqfifo_din,
        wr_en         => daqfifo_wr_en,
        rd_en         => daqfifo_rd_en,
        dout          => daqfifo_dout,
        full          => daqfifo_full,
        empty         => daqfifo_empty,
        valid         => daqfifo_valid,
        prog_full     => daqfifo_near_full,
        data_count    => daqfifo_data_cnt
    );

    daqfifo_din <= daq_event_header & daq_event_trailer & daq_event_data;
    daqfifo_wr_en <= daq_event_write_en and (not ignore_amc13);
    
    -- daq fifo read logic
    process(daq_clk_i)
    begin
        if (rising_edge(daq_clk_i)) then
            if (reset_daq = '1') then
                err_daqfifo_full <= '0';
            else
                daqfifo_rd_en <= (not daq_almost_full) and (not daqfifo_empty) and daq_ready;
                if (daqfifo_full = '1') then
                    err_daqfifo_full <= '1';
                end if; 
            end if;
        end if;
    end process;

    -- Near-full counter
    i_daqfifo_near_full_counter : entity work.counter
    generic map(
        g_COUNTER_WIDTH  => 16,
        g_ALLOW_ROLLOVER => FALSE
    )
    port map(
        ref_clk_i => daq_clk_i,
        reset_i   => reset_daq,
        en_i      => daqfifo_near_full,
        count_o   => daqfifo_near_full_cnt
    );

    -- DAQLink almost-full counter
    i_daqlink_afull_counter : entity work.counter
    generic map(
        g_COUNTER_WIDTH  => 16,
        g_ALLOW_ROLLOVER => FALSE
    )
    port map(
        ref_clk_i => daq_clk_i,
        reset_i   => reset_daq,
        en_i      => daq_almost_full,
        count_o   => daqlink_afull_cnt
    );

    -- DAQ word rate
    i_daq_word_rate_counter : entity work.rate_counter
    generic map(
        g_CLK_FREQUENCY => std_logic_vector(to_unsigned(g_DAQ_CLK_FREQ, 32)),
        g_COUNTER_WIDTH => 32
    )
    port map(
        clk_i   => daq_clk_i,
        reset_i => reset_daq,
        en_i    => daqfifo_wr_en,
        rate_o  => daq_word_rate
    );

    --================================--
    -- L1A FIFO
    --================================--
    
    i_l1a_fifo : component daq_l1a_fifo
    port map (
        rst           => reset_daq,
        wr_clk        => ttc_clks_i.clk_40,
        rd_clk        => daq_clk_i,
        din           => l1afifo_din,
        wr_en         => l1afifo_wr_en,
        wr_ack        => open,
        rd_en         => l1afifo_rd_en,
        dout          => l1afifo_dout,
        full          => l1afifo_full,
        overflow      => l1afifo_overflow,
        almost_full   => open,
        empty         => l1afifo_empty,
        valid         => l1afifo_valid,
        underflow     => l1afifo_underflow,
        prog_full     => l1afifo_near_full,
        rd_data_count => l1afifo_data_cnt
    );
    
    -- fill the L1A FIFO
    process(ttc_clks_i.clk_40)
        variable close_l1as : std_logic := '0';
    begin
        if (rising_edge(ttc_clks_i.clk_40)) then
            if (reset_daq = '1') then
                err_l1afifo_full <= '0';
                l1afifo_wr_en <= '0';
                l1a_gap_cntdown <= (others => '0');
            else                
                if ((ttc_cmds_i.l1a = '1') and (freeze_on_error = '0' or tts_critical_error = '0')) then
                    l1a_gap_cntdown <= x"27";
                    if l1a_gap_cntdown = x"00" then
                        close_l1as := '0';
                    else
                        close_l1as := '1';
                    end if;
                    
                    l1afifo_din <= close_l1as & ttc_daq_cntrs_i.l1id & ttc_daq_cntrs_i.orbit & ttc_daq_cntrs_i.bx;
                    if (l1afifo_full = '0') then
                        l1afifo_wr_en <= '1';
                        err_l1afifo_full <= err_l1afifo_full;
                    else
                        l1afifo_wr_en <= '0';
                        err_l1afifo_full <= '1';
                    end if;
                else
                    l1afifo_wr_en <= '0';
                    err_l1afifo_full <= err_l1afifo_full;
                    if l1a_gap_cntdown /= x"00" then
                        l1a_gap_cntdown <= l1a_gap_cntdown - 1;
                    else
                        l1a_gap_cntdown <= x"00";
                    end if;                    
                end if;
            end if;
        end if;
    end process;

    -- Near-full counter    
    i_l1afifo_near_full_counter : entity work.counter
    generic map(
        g_COUNTER_WIDTH  => 16,
        g_ALLOW_ROLLOVER => FALSE
    )
    port map(
        ref_clk_i => ttc_clks_i.clk_40,
        reset_i   => reset_daq,
        en_i      => l1afifo_near_full,
        count_o   => l1afifo_near_full_cnt
    );
    
    --================================--
    -- Spy Path
    --================================--
    
    i_spy_fifo : component daq_spy_fifo
        port map(
            rst          => reset_daq,
            wr_clk       => daq_clk_i,
            rd_clk       => spy_clk_i,
            din          => daq_event_data(15 downto 0) & daq_event_data(31 downto 16) & daq_event_data(47 downto 32) & daq_event_data(63 downto 48),
            wr_en        => spy_fifo_wr_en and spy_prescale_keep_evt,
            rd_en        => spy_fifo_rd_en,
            dout         => spy_fifo_dout,
            full         => open,
            overflow     => spy_fifo_ovf,
            empty        => spy_fifo_empty,
            almost_empty => spy_fifo_aempty,
            prog_full    => spy_fifo_afull
        );
    
    i_spy_ethernet_driver : entity work.gbe_tx_driver
        generic map(
            g_MAX_PAYLOAD_WORDS   => 3976,
            g_MIN_PAYLOAD_WORDS   => 32,
            g_MAX_EVT_WORDS       => 50000,
            g_NUM_IDLES_SMALL_EVT => 2,
            g_NUM_IDLES_BIG_EVT   => 7,
            g_SMALL_EVT_MAX_WORDS => 24
        )
        port map(
            reset_i             => reset_daq,
            gbe_clk_i           => spy_clk_i,
            gbe_tx_data_o       => spy_link_o,
            skip_eth_header_i   => spy_gbe_skip_headers,
            data_empty_i        => spy_fifo_empty,
            data_i              => spy_fifo_dout,
            data_rd_en          => spy_fifo_rd_en,
            last_valid_word_i   => spy_fifo_aempty,
            err_event_too_big_o => spy_err_evt_too_big,
            err_eoe_not_found_o => spy_err_eoe_not_found,
            word_rate_o         => spy_word_rate,
            evt_cnt_o           => spy_evt_sent
        );
    
    -- Near-full counter
    i_spy_near_full_counter : entity work.counter
    generic map(
        g_COUNTER_WIDTH  => 16,
        g_ALLOW_ROLLOVER => FALSE
    )
    port map(
        ref_clk_i => daq_clk_i,
        reset_i   => reset_daq,
        en_i      => spy_fifo_afull,
        count_o   => spy_fifo_afull_cnt
    );
        
    -- latch the spy fifo overflow error
    process(daq_clk_i)
    begin
        if (rising_edge(daq_clk_i)) then
            if (reset_daq = '1') then
                err_spy_fifo_ovf <= '0';
            else
                if (spy_fifo_ovf = '1') then
                    err_spy_fifo_ovf <= '1';
                else
                    err_spy_fifo_ovf <= err_spy_fifo_ovf;
                end if;
            end if;
        end if;
    end process;
        
    --================================--
    -- Chamber Event Builders
    --================================--

    g_chamber_evt_builders : for i in 0 to (g_NUM_OF_DMBs - 1) generate
    begin

        i_input_processor : entity work.input_processor
        generic map (
            g_input_clk_freq => 80_000_000
        )
        port map
        (
            -- Reset
            reset_i                     => reset_daq,

            -- Config
            input_enable_i              => input_mask(i) and not (freeze_on_error and tts_critical_error),

            -- FIFOs
            fifo_rd_clk_i               => daq_clk_i,
            infifo_dout_o               => chamber_infifos(i).dout,
            infifo_rd_en_i              => chamber_infifos(i).rd_en,
            infifo_empty_o              => chamber_infifos(i).empty,
            infifo_valid_o              => chamber_infifos(i).valid,
            infifo_underflow_o          => chamber_infifos(i).underflow,
            infifo_data_cnt_o           => chamber_infifos(i).data_cnt,
            evtfifo_dout_o              => chamber_evtfifos(i).dout,
            evtfifo_rd_en_i             => chamber_evtfifos(i).rd_en,
            evtfifo_empty_o             => chamber_evtfifos(i).empty,
            evtfifo_valid_o             => chamber_evtfifos(i).valid,
            evtfifo_underflow_o         => chamber_evtfifos(i).underflow,
            evtfifo_data_cnt_o          => chamber_evtfifos(i).data_cnt,

            -- Track data
            input_clk_i                 => input_clk_arr_i(i),
            input_data_link_i           => input_link_arr_i(i),
            
            -- Status and control
            status_o                    => input_status_arr(i),
            control_i                   => input_control_arr(i)
        );
    
        chmb_evtfifos_empty(i) <= chamber_evtfifos(i).empty;
        chamber_evtfifos(i).rd_en <= chmb_evtfifos_rd_en(i);
        chamber_infifos(i).rd_en <= chmb_infifos_rd_en(i);
        chmb_tts_states(i) <= input_status_arr(i).tts_state;
        
    end generate;
        
    --================================--
    -- TTS
    --================================--

    -- TODO: this is a cheat -- using the first input clock to aggregate input TTS states 
    process (input_clk_arr_i(0))
    begin
        if (rising_edge(input_clk_arr_i(0))) then
            if (reset_daq = '1') then
                tts_chmb_critical <= '0';
                tts_chmb_oos <= '0';
                tts_chmb_warning <= '0';
                tts_chmb_critical_arr <= (others => '0');
                tts_chmb_oos_arr <= (others => '0');
                tts_chmb_warning_arr <= (others => '0');
                tts_start_cntdwn_chmb <= x"32";
            else
                if (tts_start_cntdwn_chmb = x"00") then
                    for i in 0 to (g_NUM_OF_DMBs - 1) loop
                        tts_chmb_critical_arr(i) <= chmb_tts_states(i)(2) and input_mask(i);
                        tts_chmb_oos_arr(i) <= chmb_tts_states(i)(1) and input_mask(i);
                        tts_chmb_warning_arr(i) <= chmb_tts_states(i)(0) and input_mask(i);
                    end loop;                
                    
                    if (tts_chmb_critical = '1' or or_reduce(tts_chmb_critical_arr) = '1') then
                        tts_chmb_critical <= '1';
                    else
                        tts_chmb_critical <= '0';
                    end if;
                    
                    if (tts_chmb_oos = '1' or or_reduce(tts_chmb_oos_arr) = '1') then
                        tts_chmb_oos <= '1';
                    else
                        tts_chmb_oos <= '0';
                    end if;
                    
                    if (or_reduce(tts_chmb_warning_arr) = '1') then
                        tts_chmb_warning <= '1';
                    else
                        tts_chmb_warning <= '0';
                    end if;
                else
                    tts_start_cntdwn_chmb <= tts_start_cntdwn_chmb - 1;
                end if;
            end if;
        end if;
    end process;

    i_tts_sync_chmb_error   : entity work.synchronizer generic map(N_STAGES => 2) port map(async_i => tts_chmb_critical,    clk_i => ttc_clks_i.clk_40, sync_o  => tts_chmb_critical_tts_clk);
    i_tts_sync_chmb_warn    : entity work.synchronizer generic map(N_STAGES => 2) port map(async_i => tts_chmb_warning,     clk_i => ttc_clks_i.clk_40, sync_o  => tts_chmb_warning_tts_clk);
    i_tts_sync_chmb_oos     : entity work.synchronizer generic map(N_STAGES => 2) port map(async_i => tts_chmb_oos,         clk_i => ttc_clks_i.clk_40, sync_o  => tts_chmb_out_of_sync_tts_clk);
    i_tts_sync_daqfifo_full : entity work.synchronizer generic map(N_STAGES => 2) port map(async_i => err_daqfifo_full,     clk_i => ttc_clks_i.clk_40, sync_o  => err_daqfifo_full_tts_clk);

    process (ttc_clks_i.clk_40)
    begin
        if (rising_edge(ttc_clks_i.clk_40)) then
            if (reset_daq = '1') then
                tts_critical_error <= '0';
                tts_out_of_sync <= '0';
                tts_warning <= '0';
                tts_busy <= '1';
                tts_start_cntdwn <= x"32";
            else
                if (tts_start_cntdwn = x"00") then
                    tts_busy <= '0';
                    tts_critical_error <= err_l1afifo_full or tts_chmb_critical_tts_clk or err_daqfifo_full_tts_clk;
                    tts_out_of_sync <= tts_chmb_out_of_sync_tts_clk;
                    tts_warning <= l1afifo_near_full or tts_chmb_warning_tts_clk;
                else
                    tts_start_cntdwn <= tts_start_cntdwn - 1;
                end if;
            end if;
        end if;
    end process;

    tts_state <= tts_override when (tts_override /= x"0") else
                 x"8" when (daq_enable = '0') else
                 x"4" when (tts_busy = '1' or resync_mode = '1') else
                 x"c" when (tts_critical_error = '1') else
                 x"2" when (tts_out_of_sync = '1') else
                 x"1" when (tts_warning = '1') else
                 x"8"; 
     
    -- warning counter
    i_tts_warning_counter : entity work.counter
    generic map(
        g_COUNTER_WIDTH  => 16,
        g_ALLOW_ROLLOVER => FALSE
    )
    port map(
        ref_clk_i => ttc_clks_i.clk_40,
        reset_i   => reset_daq,
        en_i      => tts_warning,
        count_o   => tts_warning_cnt
    );

    -- resync handling
    process(ttc_clks_i.clk_40)
    begin
        if (rising_edge(ttc_clks_i.clk_40)) then
            if (reset_daq = '1') then
                resync_mode <= '0';
                resync_done <= '0';
            else
                if (ttc_cmds_i.resync = '1') then
                    resync_mode <= '1';
                end if;
                
                -- wait for all L1As to be processed and output buffer drained and then reset everything (resync_done triggers the reset_daq)
                if (resync_mode = '1' and l1afifo_empty = '1' and daq_state = IDLE and (daqfifo_empty = '1' or ignore_amc13 = '1')) then
                    resync_done <= '1';
                end if;
            end if;
        end if;
    end process;
     
    --================================--
    -- DDU CRC16
    --================================--
     
    i_ddu_crc16 : entity work.crc16_usb
        port map(
            data_in     => daq_event_data,
            crc_en      => spy_fifo_wr_en,
            rst         => daq_event_header,
            clk         => daq_clk_i,
            crc_reg     => open,
            crc_current => ddu_crc
        );
     
    --================================--
    -- Event shipping to DAQLink
    --================================--
    
    process(daq_clk_i)
    
        -- event info
        variable e_l1a_id                   : std_logic_vector(23 downto 0) := (others => '0');        
        variable e_bx_id                    : std_logic_vector(11 downto 0) := (others => '0');        
        variable e_orbit_id                 : std_logic_vector(15 downto 0) := (others => '0');
        variable e_close_l1a                : std_logic;        
        
        variable e_dmb_full                 : std_logic_vector(23 downto 0) := (others => '0');
        
        -- event chamber info; TODO: convert these to signals (but would require additional state)
        variable e_chmb_l1a_id              : std_logic_vector(23 downto 0) := (others => '0');
        variable e_chmb_bx_id               : std_logic_vector(11 downto 0) := (others => '0');
        variable e_chmb_payload_size        : unsigned(19 downto 0) := (others => '0');
        variable e_chmb_evtfifo_afull       : std_logic := '0';
        variable e_chmb_evtfifo_full        : std_logic := '0';
        variable e_chmb_infifo_full         : std_logic := '0';
        variable e_chmb_evtfifo_near_full   : std_logic := '0';
        variable e_chmb_infifo_near_full    : std_logic := '0';
        variable e_chmb_infifo_underflow    : std_logic := '0';
        variable e_chmb_64bit_misaligned    : std_logic := '0';
        variable e_chmb_evt_too_big         : std_logic := '0';
        variable e_chmb_evt_bigger_24       : std_logic := '0';
        variable e_chmb_mixed_oh_bc         : std_logic := '0';
        variable e_chmb_mixed_vfat_bc       : std_logic := '0';
        variable e_chmb_mixed_vfat_ec       : std_logic := '0';
        
        variable e_chmb_not_empty_arr       : std_logic_vector(23 downto 0) := (others => '0');
              
    begin
    
        if (rising_edge(daq_clk_i)) then
        
            if (reset_daq = '1') then
                daq_state <= IDLE;
                daq_event_data <= (others => '0');
                daq_event_header <= '0';
                daq_event_trailer <= '0';
                daq_event_write_en <= '0';
                chmb_evtfifos_rd_en <= (others => '0');
                l1afifo_rd_en <= '0';
                daq_curr_infifo_word <= (others => '0');
                chmb_infifos_rd_en <= (others => '0');
                cnt_sent_events <= (others => '0');
                e_word_count <= (others => '0');
                dav_timer <= (others => '0');
                max_dav_timer <= (others => '0');
                last_dav_timer <= (others => '0');
                dav_timeout_flags <= (others => '0');
                spy_fifo_wr_en <= '0';
                spy_prescale_counter <= x"0002";
                spy_prescale_keep_evt <= '0';
                daq_not_empty_event <= '0';
            else
            
                -- output formatting state machine

                if (daq_state = IDLE) then
                
                    -- zero out everything, especially the write enable :)
                    daq_event_data <= (others => '0');
                    daq_event_header <= '0';
                    daq_event_trailer <= '0';
                    daq_event_write_en <= '0';
                    spy_fifo_wr_en <= '0';
                    e_word_count <= (others => '0');
                    e_input_idx <= 0;
                    
                    
                    -- have an L1A and data from all enabled inputs is ready (or these inputs have timed out)
                    if (l1afifo_empty = '0' and ((input_mask(g_NUM_OF_DMBs - 1 downto 0) and ((not chmb_evtfifos_empty) or dav_timeout_flags(g_NUM_OF_DMBs - 1 downto 0))) = input_mask(g_NUM_OF_DMBs - 1 downto 0))) then
                        if (((daq_ready = '1' and daqfifo_near_full = '0') or (ignore_amc13 = '1')) and daq_enable = '1') then -- everybody ready?.... GO! :)
                            -- start the DAQ state machine
                            daq_state <= AMC13_HEADER_1;
                            
                            -- fetch the data from the L1A FIFO
                            l1afifo_rd_en <= '1';
                            
                            -- set the DAV mask
                            e_dav_mask(g_NUM_OF_DMBs - 1 downto 0) <= input_mask(g_NUM_OF_DMBs - 1 downto 0) and ((not chmb_evtfifos_empty) and (not dav_timeout_flags(g_NUM_OF_DMBs - 1 downto 0)));
                            
                            -- save timer stats
                            dav_timer <= (others => '0');
                            last_dav_timer <= dav_timer;
                            if ((dav_timer > max_dav_timer) and (or_reduce(dav_timeout_flags) = '0')) then
                                max_dav_timer <= dav_timer;
                            end if;
                            
                            -- if last event fifo has already been read by the user then enable writing to this fifo for the current event
                            last_evt_fifo_en <= last_evt_fifo_empty and (not block_last_evt_fifo);
                            
                        end if;
                    -- have an L1A, but waiting for data -- start counting the time
                    elsif (l1afifo_empty = '0') then
                        dav_timer <= dav_timer + 1;
                    end if;
                    
                    -- set the timeout flags if the timer has reached the dav_timeout value
                    if (dav_timer >= unsigned(dav_timeout)) then
                        dav_timeout_flags(g_NUM_OF_DMBs - 1 downto 0) <= chmb_evtfifos_empty and input_mask(g_NUM_OF_DMBs - 1 downto 0);
                    end if;
                                        
                else -- lets send some data!
                
                    l1afifo_rd_en <= '0';
                    
                    ----==== send the first AMC header ====----
                    if (daq_state = AMC13_HEADER_1) then
                        
                        -- L1A fifo is a first-word-fallthrough fifo, so no need to check for valid (not empty is the condition to get here anyway)
                        
                        -- fetch the L1A data
                        e_l1a_id        := l1afifo_dout(51 downto 28);
                        e_orbit_id      := l1afifo_dout(27 downto 12);
                        e_bx_id         := l1afifo_dout(11 downto 0);
                        e_close_l1a     := l1afifo_dout(52);

                        -- send the data
                        daq_event_data <= x"00" & 
                                          e_l1a_id &   -- L1A ID
                                          e_bx_id &   -- BX ID
                                          x"fffff";
                        daq_event_header <= '1';
                        daq_event_trailer <= '0';
                        daq_event_write_en <= '1';
                        spy_fifo_wr_en <= '0';
                        
                        -- move to the next state
                        e_word_count <= e_word_count + 1;
                        daq_state <= AMC13_HEADER_2;
                        
                        -- check if this event is empty or not
                        for i in 0 to g_NUM_OF_DMBs - 1 loop
                            e_chmb_not_empty_arr(i) := chamber_evtfifos(i).dout(3);
                        end loop;
                        daq_not_empty_event <= or_reduce(e_chmb_not_empty_arr and e_dav_mask);
                        
                    ----==== send the second AMC header ====----
                    elsif (daq_state = AMC13_HEADER_2) then
                    
                        -- calculate the DAV count (I know it's ugly...)
                        e_dav_count <= to_integer(unsigned(e_chmb_not_empty_arr(0 downto 0) and e_dav_mask(0 downto 0))) + to_integer(unsigned(e_chmb_not_empty_arr(1 downto 1) and e_dav_mask(1 downto 1))) + to_integer(unsigned(e_chmb_not_empty_arr(2 downto 2) and e_dav_mask(2 downto 2))) + to_integer(unsigned(e_chmb_not_empty_arr(3 downto 3) and e_dav_mask(3 downto 3))) + to_integer(unsigned(e_chmb_not_empty_arr(4 downto 4) and e_dav_mask(4 downto 4))) + to_integer(unsigned(e_chmb_not_empty_arr(5 downto 5) and e_dav_mask(5 downto 5))) + to_integer(unsigned(e_chmb_not_empty_arr(6 downto 6) and e_dav_mask(6 downto 6))) + to_integer(unsigned(e_chmb_not_empty_arr(7 downto 7) and e_dav_mask(7 downto 7))) + to_integer(unsigned(e_chmb_not_empty_arr(8 downto 8) and e_dav_mask(8 downto 8))) + to_integer(unsigned(e_chmb_not_empty_arr(8 downto 9) and e_dav_mask(9 downto 9))) + to_integer(unsigned(e_chmb_not_empty_arr(10 downto 10) and e_dav_mask(10 downto 10))) + to_integer(unsigned(e_chmb_not_empty_arr(11 downto 11) and e_dav_mask(11 downto 11))) + to_integer(unsigned(e_chmb_not_empty_arr(12 downto 12) and e_dav_mask(12 downto 12))) + to_integer(unsigned(e_chmb_not_empty_arr(13 downto 13) and e_dav_mask(13 downto 13))) + to_integer(unsigned(e_chmb_not_empty_arr(14 downto 14) and e_dav_mask(14 downto 14))) + to_integer(unsigned(e_chmb_not_empty_arr(15 downto 15) and e_dav_mask(15 downto 15))) + to_integer(unsigned(e_chmb_not_empty_arr(16 downto 16) and e_dav_mask(16 downto 16))) + to_integer(unsigned(e_chmb_not_empty_arr(17 downto 17) and e_dav_mask(17 downto 17))) + to_integer(unsigned(e_chmb_not_empty_arr(18 downto 18) and e_dav_mask(18 downto 18))) + to_integer(unsigned(e_chmb_not_empty_arr(19 downto 19) and e_dav_mask(19 downto 19))) + to_integer(unsigned(e_chmb_not_empty_arr(20 downto 20) and e_dav_mask(20 downto 20))) + to_integer(unsigned(e_chmb_not_empty_arr(21 downto 21) and e_dav_mask(21 downto 21))) + to_integer(unsigned(e_chmb_not_empty_arr(22 downto 22) and e_dav_mask(22 downto 22))) + to_integer(unsigned(e_chmb_not_empty_arr(23 downto 23) and e_dav_mask(23 downto 23)));
                        
                        -- send the data
                        daq_event_data <= C_DAQ_FORMAT_VERSION &
                                          run_type &
                                          run_params &
                                          e_orbit_id & 
                                          board_id_i;
                        daq_event_header <= '0';
                        daq_event_trailer <= '0';
                        daq_event_write_en <= '1';
                        spy_fifo_wr_en <= '0';
                        
                        -- move to the next state
                        e_word_count <= e_word_count + 1;
                        daq_state <= FED_HEADER_1;

                        -- trying to match the DDU logic here somewhat.. so it's kindof convoluted..
                        -- the counter starts at 2 after resync, and then events are accepted when it's equal to the set prescale
                        -- once an event is accepted, the counter is reset to 1 (note not 2)
                        -- prescale values of 0 and 1 just allow all events 
                        if (spy_prescale = x"0000" or spy_prescale = x"0001") then
                            spy_prescale_counter <= x"0001";
                            spy_prescale_keep_evt <= (not spy_skip_empty_evts) or daq_not_empty_event;
                        elsif (std_logic_vector(spy_prescale_counter) = spy_prescale) then
                            spy_prescale_counter <= x"0001";
                            spy_prescale_keep_evt <= (not spy_skip_empty_evts) or daq_not_empty_event;
                        else
                            spy_prescale_counter <= spy_prescale_counter + 1;
                            spy_prescale_keep_evt <= '0';
                        end if;
                                            
                    ----==== send the FED header #1 ====----
                    elsif (daq_state = FED_HEADER_1) then
                    
                        -- send the data
                        daq_event_data <= x"50" &
                                          e_l1a_id &
                                          e_bx_id &
                                          board_id_i(11 downto 0) &
                                          C_DAQ_FORMAT_VERSION &
                                          x"0";
                        daq_event_header <= '0';
                        daq_event_trailer <= '0';
                        daq_event_write_en <= '1';
                        spy_fifo_wr_en <= '1';
                        
                        -- move to the next state
                        e_word_count <= e_word_count + 1;
                        daq_state <= FED_HEADER_2;                        

                    ----==== send the FED header #2 ====----
                    elsif (daq_state = FED_HEADER_2) then
                        
                        e_dmb_full(tts_chmb_critical_arr'left downto tts_chmb_critical_arr'right) := tts_chmb_critical_arr; -- TODO: should be synced to the DAQ clock!
                    
                        -- send the data
                        daq_event_data <= x"800000018000" &
                                          e_dmb_full(15 downto 0);
                        daq_event_header <= '0';
                        daq_event_trailer <= '0';
                        daq_event_write_en <= '1';
                        spy_fifo_wr_en <= '1';
                        
                        -- move to the next state
                        e_word_count <= e_word_count + 1;
                        daq_state <= FED_HEADER_3;

                    ----==== send the FED header #2 ====----
                    elsif (daq_state = FED_HEADER_3) then

                        -- send the data
                        daq_event_data <= input_mask(15 downto 0) & -- which DDU Fiber Inputs have a "Live" fiber (High True, 1 Fiber Input per CSC) 
                                          err_daqfifo_full & -- DDU Output-Limited Buffer Overflow occurred
                                          daq_almost_full & -- DAQ Wait was asserted by S-Link or DCC TODO: use a latched flag here
                                          '0' & -- Link Full (LFF) was asserted by S-Link
                                          '0' & -- DDU S-Link Never Ready
                                          '0' & -- GbE/SPY FIFO Overflow occurred TODO: implement this
                                          '0' & -- GbE/SPY Event was skipped to prevent overflow TODO: implement this
                                          '0' & -- GbE/SPY FIFO Always Empty TODO: implement this
                                          '0' & -- Gbe/SPY Fiber Connection Error occurred
                                          (tts_critical_error and daq_almost_full)  & -- DDU Buffer Overflow caused by DAQ Wait
                                          err_daqfifo_full & -- DAQ Wait is set by DCC/S-Link TODO: transfer to DAQ clk
                                          err_daqfifo_full & -- Link Full (LFF) is set by DDU S-Link TODO: transfer to DAQ clk
                                          (not daq_ready) & --Not Ready is set by DDU S-Link
                                          '0' & -- GbE/SPY FIFO is Full TODO: implement this
                                          '0' & -- GbE/SPY Path was Not Enabled for this event TODO: implement this
                                          '0' & -- GbE/SPY FIFO is Not Empty TODO: implement this
                                          '0' & -- DCC Link is Not Ready 
                                          e_dav_mask(15 downto 0) and e_chmb_not_empty_arr(15 downto 0) & -- which CSCs have data for this event; one bit allocated per DDU fiber input
                                          '0' & -- NOT USED
                                          '0' & -- DDU single event warning *minor format error, fiber/RX error, or the DDU lost it's clock for some time; possible data loss  * consider RESET if this warning continues for consecutive events
                                          err_l1afifo_full & -- DDU SyncError (bad event, RESET req'd) * Multiple L1A errors or FIFO Full; possible data loss
                                          '0' & -- DDU detected Fiber Error * change of fiber connection status or No Live Fibers; a hardware problem probably exists
                                          tts_critical_error & -- DDU detected Critical Error, irrecoverable * OR of all possible "RESET required" cases TODO: transfer to DAQ clk
                                          '0' & --  DDU detected Single Error (bad event) * OR of all possible "bad" cases at Beginning of Event TODO: figure out what this means
                                          '0' & -- DDU detected DMB L1A Match Error *the DDU L1A event number match failed for 1 or more CSCs; possible one-time bit error TODO: implement this
                                          or_reduce(dav_timeout_flags) & -- DDU Timeout Error *data from a CSC never arrived *an unknowable amount of data has been irrevocably lost
                                          tts_state & -- TODO: should be synced to the DAQ clock
                                          std_logic_vector(to_unsigned(e_dav_count, 4));
                        daq_event_header <= '0';
                        daq_event_trailer <= '0';
                        daq_event_write_en <= '1';
                        spy_fifo_wr_en <= '1';                        
                        e_word_count <= e_word_count + 1;
                        
                        -- if this is an empty event, just pop those lone words and go straight to trailer, otherwise go to payload
                        if (daq_not_empty_event = '1') then
                            daq_state <= PAYLOAD;
                            e_payload_first_cycle <= '1';
                        else
                            daq_state <= FED_TRAILER_1;
                            e_payload_first_cycle <= '1';
                            for i in 0 to g_NUM_OF_DMBs - 1 loop
                                chmb_evtfifos_rd_en(i) <= e_dav_mask(i);
                                chmb_infifos_rd_en(i) <= e_dav_mask(i);
                            end loop;
                        end if;

                    ----==== send the payload ====----
                    elsif (daq_state = PAYLOAD) then

                        daq_event_header <= '0';
                        daq_event_trailer <= '0';
                                            
                        -- if there's no data from the current input (or a lone word)
                        if ((e_dav_mask(e_input_idx) = '0') or ((e_dav_mask(e_input_idx) = '1') and (chamber_evtfifos(e_input_idx).dout(23 downto 12) = x"001"))) then
                            
                            e_word_count <= e_word_count;
                            daq_event_data <= (others => '0');
                            daq_event_write_en <= '0';
                            spy_fifo_wr_en <= '0';
                            e_payload_first_cycle <= '1';
                            
                            -- make sure to reset the read enable of the previous input if we're not at the first one 
                            if (e_input_idx > 0) then
                                chmb_evtfifos_rd_en(e_input_idx - 1) <= '0';
                                chmb_infifos_rd_en(e_input_idx - 1) <= '0';                            
                            end if;
                            
                            -- pop the event fifo if there's an event there (lone event in this case)
                            if (e_dav_mask(e_input_idx) = '1') then
                                chmb_evtfifos_rd_en(e_input_idx) <= '1';
                                chmb_infifos_rd_en(e_input_idx) <= '1';                            
                            end if;
                            
                            -- if we're not at the last input yet, just go to the next one
                            if (e_input_idx < g_NUM_OF_DMBs - 1) then
                                e_input_idx <= e_input_idx + 1;
                                daq_state <= PAYLOAD;
                                
                            -- if we are at the last input, then skip to the trailer                                
                            else
                                e_input_idx <= e_input_idx;
                                daq_state <= FED_TRAILER_1;
                            
                            end if;
                        else

                            -- keep reading the input fifo
                            daq_event_write_en <= not e_payload_first_cycle;
                            spy_fifo_wr_en <= not e_payload_first_cycle;                        
                            daq_event_data <= chamber_infifos(e_input_idx).dout;

                            -- make sure to reset the read enables of the previous input
                            if (e_input_idx > 0) then
                                chmb_evtfifos_rd_en(e_input_idx - 1) <= '0';
                                chmb_infifos_rd_en(e_input_idx - 1) <= '0';
                            end if;
                            
                            -- if this is the first cycle at this input, take the size here, otherwise just decrease the word countdown
                            if (e_payload_first_cycle = '1') then
                                daq_curr_infifo_word <= unsigned(chamber_evtfifos(e_input_idx).dout(23 downto 12)) - 1;
                                e_payload_first_cycle <= '0';
                                chmb_evtfifos_rd_en(e_input_idx) <= '0';
                                daq_state <= PAYLOAD;
                                e_input_idx <= e_input_idx;
                                chmb_infifos_rd_en(e_input_idx) <= '1';
                            else
                                daq_curr_infifo_word <= daq_curr_infifo_word - 1;
                                e_word_count <= e_word_count + 1;
                                
                                -- end of event for this input
                                if (daq_curr_infifo_word = x"000") then
                                    chmb_evtfifos_rd_en(e_input_idx) <= '1';
                                    e_payload_first_cycle <= '1';
                                    chmb_infifos_rd_en(e_input_idx) <= '0';
                                    
                                    if (e_input_idx = g_NUM_OF_DMBs - 1) then
                                        daq_state <= FED_TRAILER_1;
                                        e_input_idx <= e_input_idx;
                                    else
                                        daq_state <= PAYLOAD;
                                        e_input_idx <= e_input_idx + 1;
                                    end if;
                                -- still sending the current input event
                                else
                                    chmb_evtfifos_rd_en(e_input_idx) <= '0';
                                    e_payload_first_cycle <= '0';
                                    daq_state <= PAYLOAD;
                                    e_input_idx <= e_input_idx;
                                    chmb_infifos_rd_en(e_input_idx) <= '1';
                                end if;
                                
                            end if;
                            
                        end if;

                    ----==== send the FED trailer 1 ====----
                    elsif (daq_state = FED_TRAILER_1) then

                        for i in 0 to g_NUM_OF_DMBs - 1 loop
                            chmb_evtfifos_rd_en(i) <= '0';
                            chmb_infifos_rd_en(i) <= '0';
                        end loop;

                        -- send the data
                        daq_event_data <= x"8000ffff80008000"; -- unique FED trailer word
                        daq_event_header <= '0';
                        daq_event_trailer <= '0';
                        daq_event_write_en <= '1';
                        spy_fifo_wr_en <= '1';                        
                        
                        -- move to the next state
                        e_word_count <= e_word_count + 1;
                        daq_state <= FED_TRAILER_2;

                    ----==== send the FED trailer 2 ====----
                    elsif (daq_state = FED_TRAILER_2) then

                        -- send the data TODO: implement the missing status flags
                        daq_event_data <= '0' & -- CSC LCT/DAV Mismatch occurred (bad event) 
                                          '0' & -- DDU-CFEB L1 Number Mismatch occurred (bad event) 
                                          '0' & -- No Good DMB CRCs were detected in this Event (perfectly normal empty event or possible bad event?) 
                                          '0' & -- CFEB Count Error occurred (bad event)
                                          '0' & --  DDU Bad First Data Word From CSC Error (bad event)
                                          err_l1afifo_full & -- DDU L1A-FIFO Full Error (RESET req'd) *the DDU L1A-event info FIFO went full; some triggers/events may be lost or garbled
                                          '0' & -- DDU Data Stuck in FIFO Error
                                          (not or_reduce(input_mask)) & -- DDU NoLiveFibers Error *no DDU fiber inputs are connected, something is wrong; will cause other errors...
                                          '0' & -- DDU Special Word Inconsistency Warning (possible bad event?) *a bit-vote failure occured on an input fiber channel
                                          '0' & -- DDU Input FPGA Error (bad event) 
                                          daq_almost_full & -- DCC/S-Link Wait is set 
                                          (not daq_ready) & -- DCC Link is Not Ready
                                          '0' & -- DDU detected TMB Error (bad event) *TMB trail word not found or TMB L1A, CRC or wordcount inconsistent
                                          '0' & -- DDU detected ALCT Error (bad event) *ALCT trail word not found or ALCT L1A, CRC or wordcount inconsistent
                                          '0' & -- DDU detected TMB or ALCT Word Count Error (bad event, RESET?) *TMB/ALCT wordcount inconsistent *if error continues for consecutive events then RESET req'd
                                          '0' & -- DDU detected TMB or ALCT L1A Number Error (bad event, RESET?) *TMB/ALCT L1A Number mismatch with DDU *if error continues for consecutive events then RESET req'd
                                          tts_critical_error & -- DDU detected Critical Error, irrecoverable (RESET req'd) *OR of all possible "RESET required" cases
                                          '0' & -- DDU detected Single Error (bad event) *OR of all possible "bad event" cases
                                          '0' & -- DDU Single Warning (possible bad event?) *OR of bit55, bit42
                                          (tts_warning or daq_almost_full) & --  DDU FIFO Near Full Warning or DAQ Wait is set (status only) *OR of all possible "Near Full" cases
                                          '0' & -- DDU detected Data Alignment Error from 1 or more inputs (bad event) *CSC data violated the 64-bit word boundary
                                          '0' & -- DDU Clock-DLL Error (may be OK, RESET?) *the DDU lost it's clock for an unknown period of time; some triggers/events/data may be lost
                                          or_reduce(dav_timeout_flags) & -- DDU detected CSC Error (bad event) *Timeout, DMB CRC, CFEB Sync/Overflow, or missing CFEB data
                                          '0' & -- DDU Lost In Event Error (bad event, but end was found) *the DDU failed to find an expected control word within the event, NOT fatal
                                          '0' & -- DDU Lost In Data Error (bad event, RESET req'd) *usally Fatal; DDU checking algorithms are irrevocably lost in the data stream *mis-sequenced data structure, possible that different events were run together *found at least one of the following in the event data stream, all of which are very bad: -Extra CSC_First_Word before CSC_Last_Word -Extra DMB_Header2 before DMB_Last_Word -Lone Word before DMB_Last_Word -Extra TMB/ALCT_Trailer before DMB_Last_Word -Extra DMB_Trailer1 before DMB_Last_Word -DMB_Trailer2 before DMB_Trailer1 Note:  CSC_Last_Word == DMB_Trailer2
                                          or_reduce(dav_timeout_flags) & -- DDU Timeout Error (bad event, RESET req'd) *data from a fiber input either never started or never finished *an unknowable amount of data has been irrevocably lost
                                          '0' & -- DDU detected TMB or ALCT CRC Error (bad event, RESET?) *CRC check failed on 1 or more TMB/ALCT; possible one-time bit error *if error continues for consecutive events then RESET req'd
                                          '0' & -- DDU Multiple Transmit Errors (bad event, RESET req'd) *one bit-vote failure (or Rx Error) has occured on multiple occassions for the same CSC
                                          (tts_critical_error or tts_out_of_sync) & -- DDU Sync Lost/Buffer Overflow Error (bad event, RESET req'd) *an unknowable amount of data has been irrevocably lost
                                          '0' & -- DDU detected Fiber Error (hardware configuration change, RESET req'd) *change of connection status on 1 or more DDU fiber inputs; a hardware problem probably exists
                                          '0' & -- DDU detected DMB or CFEB L1A Match Error (bad event, RESET?) *the DDU L1A event number match failed for 1 or more CSC boards; possible one-time bit error *if error continues for consecutive events then RESET req'd
                                          '0' & -- DDU detected DMB or CFEB CRC Error (bad event, RESET?) *CRC check failed for ADC data on 1 or more CFEBs; possible one-time bit error *if error continues for consecutive events then RESET req'd
                                          '0' & -- DMB Full Flag (status only) 
                                          tts_chmb_critical_arr(14 downto 0) & -- shows which CSCs are in an Error state 
                                          '0' & tts_chmb_warning_arr(14 downto 0); -- shows which CSCs are in a Warning state
                        daq_event_header <= '0';
                        daq_event_trailer <= '0';
                        daq_event_write_en <= '1';
                        spy_fifo_wr_en <= '1';                        
                        
                        -- move to the next state
                        e_word_count <= e_word_count + 1;
                        daq_state <= FED_TRAILER_3;

                    ----==== send the FED trailer 3 ====----
                    elsif (daq_state = FED_TRAILER_3) then

                        -- send the data
                        daq_event_data <= x"a" &
                                          "000" & e_close_l1a & 
                                          x"0" & std_logic_vector(e_word_count - 1) &
                                          ddu_crc & -- DDU CRC
                                          x"0" &
                                          tts_critical_error & -- DDU detected Critical Error, irrecoverable (RESET req'd) *OR of all possible "RESET required" cases
                                          '0' & -- DDU detected Single Error (bad event) *OR of all possible "bad event" cases
                                          '0' & -- DDU Single Warning (possible bad event?) *OR of bit55, bit42
                                          (tts_warning or daq_almost_full) & --  DDU FIFO Near Full Warning or DAQ Wait is set (status only) *OR of all possible "Near Full" cases
                                          tts_state &
                                          x"0";
                        daq_event_header <= '0';
                        daq_event_trailer <= '0';
                        daq_event_write_en <= '1';
                        spy_fifo_wr_en <= '1';                        
                        
                        -- move to the next state
                        e_word_count <= e_word_count + 1;
                        daq_state <= AMC13_TRAILER;

                    ----==== send the AMC trailer ====----
                    elsif (daq_state = AMC13_TRAILER) then
                    
                        -- send the AMC trailer data
                        daq_event_data <= x"00000000" & e_l1a_id(7 downto 0) & x"0" & std_logic_vector(e_word_count + 1);
                        daq_event_header <= '0';
                        daq_event_trailer <= '1';
                        daq_event_write_en <= '1';
                        spy_fifo_wr_en <= '0';                        
                        
                        -- go back to DAQ idle state
                        daq_state <= IDLE;
                        
                        -- reset things
                        e_word_count <= (others => '0');
                        e_input_idx <= 0;
                        cnt_sent_events <= cnt_sent_events + 1;
                        dav_timeout_flags <= x"000000";
                        
                    else
                    
                        daq_state <= IDLE;
                        
                    end if;
                    
                end if;

            end if;
        end if;        
    end process;

    --===============================================================================================
    -- this section is generated by <gem_amc_repo_root>/scripts/generate_registers.py (do not edit) 
    --==== Registers begin ==========================================================================

    -- IPbus slave instanciation
    ipbus_slave_inst : entity work.ipbus_slave
        generic map(
           g_NUM_REGS             => REG_DAQ_NUM_REGS,
           g_ADDR_HIGH_BIT        => REG_DAQ_ADDRESS_MSB,
           g_ADDR_LOW_BIT         => REG_DAQ_ADDRESS_LSB,
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
    regs_addresses(0)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"00";
    regs_addresses(1)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"01";
    regs_addresses(2)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"02";
    regs_addresses(3)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"0f";
    regs_addresses(4)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"10";
    regs_addresses(5)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"11";
    regs_addresses(6)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"12";
    regs_addresses(7)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"13";
    regs_addresses(8)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"14";
    regs_addresses(9)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"15";
    regs_addresses(10)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"16";
    regs_addresses(11)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"17";
    regs_addresses(12)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"18";
    regs_addresses(13)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"19";
    regs_addresses(14)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"20";
    regs_addresses(15)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"21";
    regs_addresses(16)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"22";
    regs_addresses(17)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"30";
    regs_addresses(18)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"31";
    regs_addresses(19)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"50";
    regs_addresses(20)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"52";
    regs_addresses(21)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"54";
    regs_addresses(22)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"55";
    regs_addresses(23)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"56";
    regs_addresses(24)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"60";
    regs_addresses(25)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"62";
    regs_addresses(26)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"64";
    regs_addresses(27)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"65";
    regs_addresses(28)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"66";
    regs_addresses(29)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"70";
    regs_addresses(30)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"72";
    regs_addresses(31)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"74";
    regs_addresses(32)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"75";
    regs_addresses(33)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"76";
    regs_addresses(34)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"80";
    regs_addresses(35)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"82";
    regs_addresses(36)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"84";
    regs_addresses(37)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"85";
    regs_addresses(38)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"86";
    regs_addresses(39)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"90";
    regs_addresses(40)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"92";
    regs_addresses(41)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"94";
    regs_addresses(42)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"95";
    regs_addresses(43)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"96";
    regs_addresses(44)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"a0";
    regs_addresses(45)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"a2";
    regs_addresses(46)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"a4";
    regs_addresses(47)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"a5";
    regs_addresses(48)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"a6";
    regs_addresses(49)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"b0";
    regs_addresses(50)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"b2";
    regs_addresses(51)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"b4";
    regs_addresses(52)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"b5";
    regs_addresses(53)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"b6";
    regs_addresses(54)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"c0";
    regs_addresses(55)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"c2";
    regs_addresses(56)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"c4";
    regs_addresses(57)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"c5";
    regs_addresses(58)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"c6";
    regs_addresses(59)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"d0";
    regs_addresses(60)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"d2";
    regs_addresses(61)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"d4";
    regs_addresses(62)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"d5";
    regs_addresses(63)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"d6";
    regs_addresses(64)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"e0";
    regs_addresses(65)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"e2";
    regs_addresses(66)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"e4";
    regs_addresses(67)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"e5";
    regs_addresses(68)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"e6";
    regs_addresses(69)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"f0";
    regs_addresses(70)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"f2";
    regs_addresses(71)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"f4";
    regs_addresses(72)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"f5";
    regs_addresses(73)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '0' & x"f6";
    regs_addresses(74)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '1' & x"00";
    regs_addresses(75)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '1' & x"02";
    regs_addresses(76)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '1' & x"04";
    regs_addresses(77)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '1' & x"05";
    regs_addresses(78)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '1' & x"06";
    regs_addresses(79)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '1' & x"10";
    regs_addresses(80)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '1' & x"12";
    regs_addresses(81)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '1' & x"14";
    regs_addresses(82)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '1' & x"15";
    regs_addresses(83)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '1' & x"16";
    regs_addresses(84)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '1' & x"20";
    regs_addresses(85)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '1' & x"22";
    regs_addresses(86)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '1' & x"24";
    regs_addresses(87)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '1' & x"25";
    regs_addresses(88)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '1' & x"26";
    regs_addresses(89)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '1' & x"30";
    regs_addresses(90)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '1' & x"32";
    regs_addresses(91)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '1' & x"34";
    regs_addresses(92)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '1' & x"35";
    regs_addresses(93)(REG_DAQ_ADDRESS_MSB downto REG_DAQ_ADDRESS_LSB) <= '1' & x"36";

    -- Connect read signals
    regs_read_arr(0)(REG_DAQ_CONTROL_DAQ_ENABLE_BIT) <= daq_enable;
    regs_read_arr(0)(REG_DAQ_CONTROL_IGNORE_AMC13_BIT) <= ignore_amc13;
    regs_read_arr(0)(REG_DAQ_CONTROL_DAQ_LINK_RESET_BIT) <= reset_daqlink_ipb;
    regs_read_arr(0)(REG_DAQ_CONTROL_RESET_BIT) <= reset_local;
    regs_read_arr(0)(REG_DAQ_CONTROL_TTS_OVERRIDE_MSB downto REG_DAQ_CONTROL_TTS_OVERRIDE_LSB) <= tts_override;
    regs_read_arr(0)(REG_DAQ_CONTROL_INPUT_ENABLE_MASK_MSB downto REG_DAQ_CONTROL_INPUT_ENABLE_MASK_LSB) <= input_mask;
    regs_read_arr(1)(REG_DAQ_CONTROL_DAV_TIMEOUT_MSB downto REG_DAQ_CONTROL_DAV_TIMEOUT_LSB) <= dav_timeout;
    regs_read_arr(1)(REG_DAQ_CONTROL_FREEZE_ON_ERROR_BIT) <= freeze_on_error;
    regs_read_arr(1)(REG_DAQ_CONTROL_RESET_TILL_RESYNC_BIT) <= reset_till_resync;
    regs_read_arr(2)(REG_DAQ_CONTROL_RUN_PARAMS_MSB downto REG_DAQ_CONTROL_RUN_PARAMS_LSB) <= run_params;
    regs_read_arr(2)(REG_DAQ_CONTROL_RUN_TYPE_MSB downto REG_DAQ_CONTROL_RUN_TYPE_LSB) <= run_type;
    regs_read_arr(3)(REG_DAQ_CONTROL_SPY_SPY_SKIP_ETH_HEADER_BIT) <= spy_gbe_skip_headers;
    regs_read_arr(3)(REG_DAQ_CONTROL_SPY_SPY_SKIP_EMPTY_EVENTS_BIT) <= spy_skip_empty_evts;
    regs_read_arr(3)(REG_DAQ_CONTROL_SPY_SPY_PRESCALE_MSB downto REG_DAQ_CONTROL_SPY_SPY_PRESCALE_LSB) <= spy_prescale;
    regs_read_arr(4)(REG_DAQ_STATUS_DAQ_LINK_RDY_BIT) <= daq_ready;
    regs_read_arr(4)(REG_DAQ_STATUS_DAQ_CLK_LOCKED_BIT) <= daq_clk_locked_i;
    regs_read_arr(4)(REG_DAQ_STATUS_TTC_RDY_BIT) <= ttc_status_i.mmcm_locked;
    regs_read_arr(4)(REG_DAQ_STATUS_DAQ_LINK_AFULL_BIT) <= daq_almost_full;
    regs_read_arr(4)(REG_DAQ_STATUS_DAQ_OUTPUT_FIFO_HAD_OVERFLOW_BIT) <= err_daqfifo_full;
    regs_read_arr(4)(REG_DAQ_STATUS_TTC_BC0_LOCKED_BIT) <= ttc_status_i.bc0_status.locked;
    regs_read_arr(4)(REG_DAQ_STATUS_L1A_FIFO_HAD_OVERFLOW_BIT) <= err_l1afifo_full;
    regs_read_arr(4)(REG_DAQ_STATUS_L1A_FIFO_IS_UNDERFLOW_BIT) <= l1afifo_underflow;
    regs_read_arr(4)(REG_DAQ_STATUS_L1A_FIFO_IS_FULL_BIT) <= l1afifo_full;
    regs_read_arr(4)(REG_DAQ_STATUS_L1A_FIFO_IS_NEAR_FULL_BIT) <= l1afifo_near_full;
    regs_read_arr(4)(REG_DAQ_STATUS_L1A_FIFO_IS_EMPTY_BIT) <= l1afifo_empty;
    regs_read_arr(4)(REG_DAQ_STATUS_TTS_STATE_MSB downto REG_DAQ_STATUS_TTS_STATE_LSB) <= tts_state;
    regs_read_arr(5)(REG_DAQ_STATUS_NOTINTABLE_ERR_MSB downto REG_DAQ_STATUS_NOTINTABLE_ERR_LSB) <= daq_notintable_err_cnt;
    regs_read_arr(5)(REG_DAQ_STATUS_DISPER_ERR_MSB downto REG_DAQ_STATUS_DISPER_ERR_LSB) <= daq_disper_err_cnt;
    regs_read_arr(6)(REG_DAQ_STATUS_L1AID_MSB downto REG_DAQ_STATUS_L1AID_LSB) <= ttc_daq_cntrs_i.l1id;
    regs_read_arr(7)(REG_DAQ_STATUS_EVT_SENT_MSB downto REG_DAQ_STATUS_EVT_SENT_LSB) <= std_logic_vector(cnt_sent_events);
    regs_read_arr(8)(REG_DAQ_STATUS_MAX_DAV_TIMER_MSB downto REG_DAQ_STATUS_MAX_DAV_TIMER_LSB) <= std_logic_vector(max_dav_timer);
    regs_read_arr(9)(REG_DAQ_STATUS_LAST_DAV_TIMER_MSB downto REG_DAQ_STATUS_LAST_DAV_TIMER_LSB) <= std_logic_vector(last_dav_timer);
    regs_read_arr(10)(REG_DAQ_STATUS_L1A_FIFO_DATA_CNT_MSB downto REG_DAQ_STATUS_L1A_FIFO_DATA_CNT_LSB) <= l1afifo_data_cnt;
    regs_read_arr(10)(REG_DAQ_STATUS_DAQ_FIFO_DATA_CNT_MSB downto REG_DAQ_STATUS_DAQ_FIFO_DATA_CNT_LSB) <= daqfifo_data_cnt;
    regs_read_arr(11)(REG_DAQ_STATUS_L1A_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_STATUS_L1A_FIFO_NEAR_FULL_CNT_LSB) <= l1afifo_near_full_cnt;
    regs_read_arr(11)(REG_DAQ_STATUS_DAQ_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_STATUS_DAQ_FIFO_NEAR_FULL_CNT_LSB) <= daqfifo_near_full_cnt;
    regs_read_arr(12)(REG_DAQ_STATUS_DAQ_ALMOST_FULL_CNT_MSB downto REG_DAQ_STATUS_DAQ_ALMOST_FULL_CNT_LSB) <= daqlink_afull_cnt;
    regs_read_arr(12)(REG_DAQ_STATUS_TTS_WARN_CNT_MSB downto REG_DAQ_STATUS_TTS_WARN_CNT_LSB) <= tts_warning_cnt;
    regs_read_arr(13)(REG_DAQ_STATUS_DAQ_WORD_RATE_MSB downto REG_DAQ_STATUS_DAQ_WORD_RATE_LSB) <= daq_word_rate;
    regs_read_arr(14)(REG_DAQ_STATUS_SPY_SPY_WORD_RATE_MSB downto REG_DAQ_STATUS_SPY_SPY_WORD_RATE_LSB) <= spy_word_rate;
    regs_read_arr(15)(REG_DAQ_STATUS_SPY_SPY_EVENTS_SENT_MSB downto REG_DAQ_STATUS_SPY_SPY_EVENTS_SENT_LSB) <= spy_evt_sent;
    regs_read_arr(16)(REG_DAQ_STATUS_SPY_ERR_BIG_EVENT_BIT) <= spy_err_evt_too_big;
    regs_read_arr(16)(REG_DAQ_STATUS_SPY_ERR_EOE_NOT_FOUND_BIT) <= spy_err_eoe_not_found;
    regs_read_arr(16)(REG_DAQ_STATUS_SPY_ERR_SPY_FIFO_HAD_OFLOW_BIT) <= err_spy_fifo_ovf;
    regs_read_arr(16)(REG_DAQ_STATUS_SPY_SPY_FIFO_IS_EMPTY_BIT) <= spy_fifo_empty;
    regs_read_arr(16)(REG_DAQ_STATUS_SPY_SPY_FIFO_AFULL_CNT_MSB downto REG_DAQ_STATUS_SPY_SPY_FIFO_AFULL_CNT_LSB) <= spy_fifo_afull_cnt;
    regs_read_arr(17)(REG_DAQ_LAST_EVENT_FIFO_EMPTY_BIT) <= last_evt_fifo_empty;
    regs_read_arr(17)(REG_DAQ_LAST_EVENT_FIFO_DISABLE_BIT) <= block_last_evt_fifo;
    regs_read_arr(18)(REG_DAQ_LAST_EVENT_FIFO_DATA_MSB downto REG_DAQ_LAST_EVENT_FIFO_DATA_LSB) <= last_evt_fifo_dout;
    regs_read_arr(19)(REG_DAQ_DMB0_STATUS_EVT_64BIT_ALIGN_ERR_BIT) <= input_status_arr(0).err_64bit_misaligned;
    regs_read_arr(19)(REG_DAQ_DMB0_STATUS_INPUT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(0).err_infifo_full;
    regs_read_arr(19)(REG_DAQ_DMB0_STATUS_INPUT_FIFO_HAD_UFLOW_BIT) <= input_status_arr(0).err_infifo_underflow;
    regs_read_arr(19)(REG_DAQ_DMB0_STATUS_EVENT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(0).err_evtfifo_full;
    regs_read_arr(19)(REG_DAQ_DMB0_STATUS_EVT_SIZE_ERR_BIT) <= input_status_arr(0).err_event_too_big;
    regs_read_arr(19)(REG_DAQ_DMB0_STATUS_TTS_STATE_MSB downto REG_DAQ_DMB0_STATUS_TTS_STATE_LSB) <= input_status_arr(0).tts_state;
    regs_read_arr(19)(REG_DAQ_DMB0_STATUS_INPUT_FIFO_IS_UFLOW_BIT) <= input_status_arr(0).infifo_underflow;
    regs_read_arr(19)(REG_DAQ_DMB0_STATUS_INPUT_FIFO_IS_FULL_BIT) <= input_status_arr(0).infifo_full;
    regs_read_arr(19)(REG_DAQ_DMB0_STATUS_INPUT_FIFO_IS_AFULL_BIT) <= input_status_arr(0).infifo_near_full;
    regs_read_arr(19)(REG_DAQ_DMB0_STATUS_INPUT_FIFO_IS_EMPTY_BIT) <= input_status_arr(0).infifo_empty;
    regs_read_arr(19)(REG_DAQ_DMB0_STATUS_EVENT_FIFO_IS_UFLOW_BIT) <= input_status_arr(0).evtfifo_underflow;
    regs_read_arr(19)(REG_DAQ_DMB0_STATUS_EVENT_FIFO_IS_FULL_BIT) <= input_status_arr(0).evtfifo_full;
    regs_read_arr(19)(REG_DAQ_DMB0_STATUS_EVENT_FIFO_IS_AFULL_BIT) <= input_status_arr(0).evtfifo_near_full;
    regs_read_arr(19)(REG_DAQ_DMB0_STATUS_EVENT_FIFO_IS_EMPTY_BIT) <= input_status_arr(0).evtfifo_empty;
    regs_read_arr(20)(REG_DAQ_DMB0_COUNTERS_EVN_MSB downto REG_DAQ_DMB0_COUNTERS_EVN_LSB) <= input_status_arr(0).eb_event_num;
    regs_read_arr(21)(REG_DAQ_DMB0_COUNTERS_INPUT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB0_COUNTERS_INPUT_FIFO_DATA_CNT_LSB) <= chamber_infifos(0).data_cnt;
    regs_read_arr(21)(REG_DAQ_DMB0_COUNTERS_EVT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB0_COUNTERS_EVT_FIFO_DATA_CNT_LSB) <= chamber_evtfifos(0).data_cnt;
    regs_read_arr(22)(REG_DAQ_DMB0_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB0_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(0).infifo_near_full_cnt;
    regs_read_arr(22)(REG_DAQ_DMB0_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB0_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(0).evtfifo_near_full_cnt;
    regs_read_arr(23)(REG_DAQ_DMB0_COUNTERS_DATA_WORD_RATE_MSB downto REG_DAQ_DMB0_COUNTERS_DATA_WORD_RATE_LSB) <= input_status_arr(0).infifo_wr_rate;
    regs_read_arr(23)(REG_DAQ_DMB0_COUNTERS_EVT_RATE_MSB downto REG_DAQ_DMB0_COUNTERS_EVT_RATE_LSB) <= input_status_arr(0).evtfifo_wr_rate;
    regs_read_arr(24)(REG_DAQ_DMB1_STATUS_EVT_64BIT_ALIGN_ERR_BIT) <= input_status_arr(1).err_64bit_misaligned;
    regs_read_arr(24)(REG_DAQ_DMB1_STATUS_INPUT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(1).err_infifo_full;
    regs_read_arr(24)(REG_DAQ_DMB1_STATUS_INPUT_FIFO_HAD_UFLOW_BIT) <= input_status_arr(1).err_infifo_underflow;
    regs_read_arr(24)(REG_DAQ_DMB1_STATUS_EVENT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(1).err_evtfifo_full;
    regs_read_arr(24)(REG_DAQ_DMB1_STATUS_EVT_SIZE_ERR_BIT) <= input_status_arr(1).err_event_too_big;
    regs_read_arr(24)(REG_DAQ_DMB1_STATUS_TTS_STATE_MSB downto REG_DAQ_DMB1_STATUS_TTS_STATE_LSB) <= input_status_arr(1).tts_state;
    regs_read_arr(24)(REG_DAQ_DMB1_STATUS_INPUT_FIFO_IS_UFLOW_BIT) <= input_status_arr(1).infifo_underflow;
    regs_read_arr(24)(REG_DAQ_DMB1_STATUS_INPUT_FIFO_IS_FULL_BIT) <= input_status_arr(1).infifo_full;
    regs_read_arr(24)(REG_DAQ_DMB1_STATUS_INPUT_FIFO_IS_AFULL_BIT) <= input_status_arr(1).infifo_near_full;
    regs_read_arr(24)(REG_DAQ_DMB1_STATUS_INPUT_FIFO_IS_EMPTY_BIT) <= input_status_arr(1).infifo_empty;
    regs_read_arr(24)(REG_DAQ_DMB1_STATUS_EVENT_FIFO_IS_UFLOW_BIT) <= input_status_arr(1).evtfifo_underflow;
    regs_read_arr(24)(REG_DAQ_DMB1_STATUS_EVENT_FIFO_IS_FULL_BIT) <= input_status_arr(1).evtfifo_full;
    regs_read_arr(24)(REG_DAQ_DMB1_STATUS_EVENT_FIFO_IS_AFULL_BIT) <= input_status_arr(1).evtfifo_near_full;
    regs_read_arr(24)(REG_DAQ_DMB1_STATUS_EVENT_FIFO_IS_EMPTY_BIT) <= input_status_arr(1).evtfifo_empty;
    regs_read_arr(25)(REG_DAQ_DMB1_COUNTERS_EVN_MSB downto REG_DAQ_DMB1_COUNTERS_EVN_LSB) <= input_status_arr(1).eb_event_num;
    regs_read_arr(26)(REG_DAQ_DMB1_COUNTERS_INPUT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB1_COUNTERS_INPUT_FIFO_DATA_CNT_LSB) <= chamber_infifos(1).data_cnt;
    regs_read_arr(26)(REG_DAQ_DMB1_COUNTERS_EVT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB1_COUNTERS_EVT_FIFO_DATA_CNT_LSB) <= chamber_evtfifos(1).data_cnt;
    regs_read_arr(27)(REG_DAQ_DMB1_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB1_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(1).infifo_near_full_cnt;
    regs_read_arr(27)(REG_DAQ_DMB1_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB1_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(1).evtfifo_near_full_cnt;
    regs_read_arr(28)(REG_DAQ_DMB1_COUNTERS_DATA_WORD_RATE_MSB downto REG_DAQ_DMB1_COUNTERS_DATA_WORD_RATE_LSB) <= input_status_arr(1).infifo_wr_rate;
    regs_read_arr(28)(REG_DAQ_DMB1_COUNTERS_EVT_RATE_MSB downto REG_DAQ_DMB1_COUNTERS_EVT_RATE_LSB) <= input_status_arr(1).evtfifo_wr_rate;
    regs_read_arr(29)(REG_DAQ_DMB2_STATUS_EVT_64BIT_ALIGN_ERR_BIT) <= input_status_arr(2).err_64bit_misaligned;
    regs_read_arr(29)(REG_DAQ_DMB2_STATUS_INPUT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(2).err_infifo_full;
    regs_read_arr(29)(REG_DAQ_DMB2_STATUS_INPUT_FIFO_HAD_UFLOW_BIT) <= input_status_arr(2).err_infifo_underflow;
    regs_read_arr(29)(REG_DAQ_DMB2_STATUS_EVENT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(2).err_evtfifo_full;
    regs_read_arr(29)(REG_DAQ_DMB2_STATUS_EVT_SIZE_ERR_BIT) <= input_status_arr(2).err_event_too_big;
    regs_read_arr(29)(REG_DAQ_DMB2_STATUS_TTS_STATE_MSB downto REG_DAQ_DMB2_STATUS_TTS_STATE_LSB) <= input_status_arr(2).tts_state;
    regs_read_arr(29)(REG_DAQ_DMB2_STATUS_INPUT_FIFO_IS_UFLOW_BIT) <= input_status_arr(2).infifo_underflow;
    regs_read_arr(29)(REG_DAQ_DMB2_STATUS_INPUT_FIFO_IS_FULL_BIT) <= input_status_arr(2).infifo_full;
    regs_read_arr(29)(REG_DAQ_DMB2_STATUS_INPUT_FIFO_IS_AFULL_BIT) <= input_status_arr(2).infifo_near_full;
    regs_read_arr(29)(REG_DAQ_DMB2_STATUS_INPUT_FIFO_IS_EMPTY_BIT) <= input_status_arr(2).infifo_empty;
    regs_read_arr(29)(REG_DAQ_DMB2_STATUS_EVENT_FIFO_IS_UFLOW_BIT) <= input_status_arr(2).evtfifo_underflow;
    regs_read_arr(29)(REG_DAQ_DMB2_STATUS_EVENT_FIFO_IS_FULL_BIT) <= input_status_arr(2).evtfifo_full;
    regs_read_arr(29)(REG_DAQ_DMB2_STATUS_EVENT_FIFO_IS_AFULL_BIT) <= input_status_arr(2).evtfifo_near_full;
    regs_read_arr(29)(REG_DAQ_DMB2_STATUS_EVENT_FIFO_IS_EMPTY_BIT) <= input_status_arr(2).evtfifo_empty;
    regs_read_arr(30)(REG_DAQ_DMB2_COUNTERS_EVN_MSB downto REG_DAQ_DMB2_COUNTERS_EVN_LSB) <= input_status_arr(2).eb_event_num;
    regs_read_arr(31)(REG_DAQ_DMB2_COUNTERS_INPUT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB2_COUNTERS_INPUT_FIFO_DATA_CNT_LSB) <= chamber_infifos(2).data_cnt;
    regs_read_arr(31)(REG_DAQ_DMB2_COUNTERS_EVT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB2_COUNTERS_EVT_FIFO_DATA_CNT_LSB) <= chamber_evtfifos(2).data_cnt;
    regs_read_arr(32)(REG_DAQ_DMB2_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB2_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(2).infifo_near_full_cnt;
    regs_read_arr(32)(REG_DAQ_DMB2_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB2_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(2).evtfifo_near_full_cnt;
    regs_read_arr(33)(REG_DAQ_DMB2_COUNTERS_DATA_WORD_RATE_MSB downto REG_DAQ_DMB2_COUNTERS_DATA_WORD_RATE_LSB) <= input_status_arr(2).infifo_wr_rate;
    regs_read_arr(33)(REG_DAQ_DMB2_COUNTERS_EVT_RATE_MSB downto REG_DAQ_DMB2_COUNTERS_EVT_RATE_LSB) <= input_status_arr(2).evtfifo_wr_rate;
    regs_read_arr(34)(REG_DAQ_DMB3_STATUS_EVT_64BIT_ALIGN_ERR_BIT) <= input_status_arr(3).err_64bit_misaligned;
    regs_read_arr(34)(REG_DAQ_DMB3_STATUS_INPUT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(3).err_infifo_full;
    regs_read_arr(34)(REG_DAQ_DMB3_STATUS_INPUT_FIFO_HAD_UFLOW_BIT) <= input_status_arr(3).err_infifo_underflow;
    regs_read_arr(34)(REG_DAQ_DMB3_STATUS_EVENT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(3).err_evtfifo_full;
    regs_read_arr(34)(REG_DAQ_DMB3_STATUS_EVT_SIZE_ERR_BIT) <= input_status_arr(3).err_event_too_big;
    regs_read_arr(34)(REG_DAQ_DMB3_STATUS_TTS_STATE_MSB downto REG_DAQ_DMB3_STATUS_TTS_STATE_LSB) <= input_status_arr(3).tts_state;
    regs_read_arr(34)(REG_DAQ_DMB3_STATUS_INPUT_FIFO_IS_UFLOW_BIT) <= input_status_arr(3).infifo_underflow;
    regs_read_arr(34)(REG_DAQ_DMB3_STATUS_INPUT_FIFO_IS_FULL_BIT) <= input_status_arr(3).infifo_full;
    regs_read_arr(34)(REG_DAQ_DMB3_STATUS_INPUT_FIFO_IS_AFULL_BIT) <= input_status_arr(3).infifo_near_full;
    regs_read_arr(34)(REG_DAQ_DMB3_STATUS_INPUT_FIFO_IS_EMPTY_BIT) <= input_status_arr(3).infifo_empty;
    regs_read_arr(34)(REG_DAQ_DMB3_STATUS_EVENT_FIFO_IS_UFLOW_BIT) <= input_status_arr(3).evtfifo_underflow;
    regs_read_arr(34)(REG_DAQ_DMB3_STATUS_EVENT_FIFO_IS_FULL_BIT) <= input_status_arr(3).evtfifo_full;
    regs_read_arr(34)(REG_DAQ_DMB3_STATUS_EVENT_FIFO_IS_AFULL_BIT) <= input_status_arr(3).evtfifo_near_full;
    regs_read_arr(34)(REG_DAQ_DMB3_STATUS_EVENT_FIFO_IS_EMPTY_BIT) <= input_status_arr(3).evtfifo_empty;
    regs_read_arr(35)(REG_DAQ_DMB3_COUNTERS_EVN_MSB downto REG_DAQ_DMB3_COUNTERS_EVN_LSB) <= input_status_arr(3).eb_event_num;
    regs_read_arr(36)(REG_DAQ_DMB3_COUNTERS_INPUT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB3_COUNTERS_INPUT_FIFO_DATA_CNT_LSB) <= chamber_infifos(3).data_cnt;
    regs_read_arr(36)(REG_DAQ_DMB3_COUNTERS_EVT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB3_COUNTERS_EVT_FIFO_DATA_CNT_LSB) <= chamber_evtfifos(3).data_cnt;
    regs_read_arr(37)(REG_DAQ_DMB3_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB3_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(3).infifo_near_full_cnt;
    regs_read_arr(37)(REG_DAQ_DMB3_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB3_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(3).evtfifo_near_full_cnt;
    regs_read_arr(38)(REG_DAQ_DMB3_COUNTERS_DATA_WORD_RATE_MSB downto REG_DAQ_DMB3_COUNTERS_DATA_WORD_RATE_LSB) <= input_status_arr(3).infifo_wr_rate;
    regs_read_arr(38)(REG_DAQ_DMB3_COUNTERS_EVT_RATE_MSB downto REG_DAQ_DMB3_COUNTERS_EVT_RATE_LSB) <= input_status_arr(3).evtfifo_wr_rate;
    regs_read_arr(39)(REG_DAQ_DMB4_STATUS_EVT_64BIT_ALIGN_ERR_BIT) <= input_status_arr(4).err_64bit_misaligned;
    regs_read_arr(39)(REG_DAQ_DMB4_STATUS_INPUT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(4).err_infifo_full;
    regs_read_arr(39)(REG_DAQ_DMB4_STATUS_INPUT_FIFO_HAD_UFLOW_BIT) <= input_status_arr(4).err_infifo_underflow;
    regs_read_arr(39)(REG_DAQ_DMB4_STATUS_EVENT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(4).err_evtfifo_full;
    regs_read_arr(39)(REG_DAQ_DMB4_STATUS_EVT_SIZE_ERR_BIT) <= input_status_arr(4).err_event_too_big;
    regs_read_arr(39)(REG_DAQ_DMB4_STATUS_TTS_STATE_MSB downto REG_DAQ_DMB4_STATUS_TTS_STATE_LSB) <= input_status_arr(4).tts_state;
    regs_read_arr(39)(REG_DAQ_DMB4_STATUS_INPUT_FIFO_IS_UFLOW_BIT) <= input_status_arr(4).infifo_underflow;
    regs_read_arr(39)(REG_DAQ_DMB4_STATUS_INPUT_FIFO_IS_FULL_BIT) <= input_status_arr(4).infifo_full;
    regs_read_arr(39)(REG_DAQ_DMB4_STATUS_INPUT_FIFO_IS_AFULL_BIT) <= input_status_arr(4).infifo_near_full;
    regs_read_arr(39)(REG_DAQ_DMB4_STATUS_INPUT_FIFO_IS_EMPTY_BIT) <= input_status_arr(4).infifo_empty;
    regs_read_arr(39)(REG_DAQ_DMB4_STATUS_EVENT_FIFO_IS_UFLOW_BIT) <= input_status_arr(4).evtfifo_underflow;
    regs_read_arr(39)(REG_DAQ_DMB4_STATUS_EVENT_FIFO_IS_FULL_BIT) <= input_status_arr(4).evtfifo_full;
    regs_read_arr(39)(REG_DAQ_DMB4_STATUS_EVENT_FIFO_IS_AFULL_BIT) <= input_status_arr(4).evtfifo_near_full;
    regs_read_arr(39)(REG_DAQ_DMB4_STATUS_EVENT_FIFO_IS_EMPTY_BIT) <= input_status_arr(4).evtfifo_empty;
    regs_read_arr(40)(REG_DAQ_DMB4_COUNTERS_EVN_MSB downto REG_DAQ_DMB4_COUNTERS_EVN_LSB) <= input_status_arr(4).eb_event_num;
    regs_read_arr(41)(REG_DAQ_DMB4_COUNTERS_INPUT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB4_COUNTERS_INPUT_FIFO_DATA_CNT_LSB) <= chamber_infifos(4).data_cnt;
    regs_read_arr(41)(REG_DAQ_DMB4_COUNTERS_EVT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB4_COUNTERS_EVT_FIFO_DATA_CNT_LSB) <= chamber_evtfifos(4).data_cnt;
    regs_read_arr(42)(REG_DAQ_DMB4_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB4_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(4).infifo_near_full_cnt;
    regs_read_arr(42)(REG_DAQ_DMB4_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB4_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(4).evtfifo_near_full_cnt;
    regs_read_arr(43)(REG_DAQ_DMB4_COUNTERS_DATA_WORD_RATE_MSB downto REG_DAQ_DMB4_COUNTERS_DATA_WORD_RATE_LSB) <= input_status_arr(4).infifo_wr_rate;
    regs_read_arr(43)(REG_DAQ_DMB4_COUNTERS_EVT_RATE_MSB downto REG_DAQ_DMB4_COUNTERS_EVT_RATE_LSB) <= input_status_arr(4).evtfifo_wr_rate;
    regs_read_arr(44)(REG_DAQ_DMB5_STATUS_EVT_64BIT_ALIGN_ERR_BIT) <= input_status_arr(5).err_64bit_misaligned;
    regs_read_arr(44)(REG_DAQ_DMB5_STATUS_INPUT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(5).err_infifo_full;
    regs_read_arr(44)(REG_DAQ_DMB5_STATUS_INPUT_FIFO_HAD_UFLOW_BIT) <= input_status_arr(5).err_infifo_underflow;
    regs_read_arr(44)(REG_DAQ_DMB5_STATUS_EVENT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(5).err_evtfifo_full;
    regs_read_arr(44)(REG_DAQ_DMB5_STATUS_EVT_SIZE_ERR_BIT) <= input_status_arr(5).err_event_too_big;
    regs_read_arr(44)(REG_DAQ_DMB5_STATUS_TTS_STATE_MSB downto REG_DAQ_DMB5_STATUS_TTS_STATE_LSB) <= input_status_arr(5).tts_state;
    regs_read_arr(44)(REG_DAQ_DMB5_STATUS_INPUT_FIFO_IS_UFLOW_BIT) <= input_status_arr(5).infifo_underflow;
    regs_read_arr(44)(REG_DAQ_DMB5_STATUS_INPUT_FIFO_IS_FULL_BIT) <= input_status_arr(5).infifo_full;
    regs_read_arr(44)(REG_DAQ_DMB5_STATUS_INPUT_FIFO_IS_AFULL_BIT) <= input_status_arr(5).infifo_near_full;
    regs_read_arr(44)(REG_DAQ_DMB5_STATUS_INPUT_FIFO_IS_EMPTY_BIT) <= input_status_arr(5).infifo_empty;
    regs_read_arr(44)(REG_DAQ_DMB5_STATUS_EVENT_FIFO_IS_UFLOW_BIT) <= input_status_arr(5).evtfifo_underflow;
    regs_read_arr(44)(REG_DAQ_DMB5_STATUS_EVENT_FIFO_IS_FULL_BIT) <= input_status_arr(5).evtfifo_full;
    regs_read_arr(44)(REG_DAQ_DMB5_STATUS_EVENT_FIFO_IS_AFULL_BIT) <= input_status_arr(5).evtfifo_near_full;
    regs_read_arr(44)(REG_DAQ_DMB5_STATUS_EVENT_FIFO_IS_EMPTY_BIT) <= input_status_arr(5).evtfifo_empty;
    regs_read_arr(45)(REG_DAQ_DMB5_COUNTERS_EVN_MSB downto REG_DAQ_DMB5_COUNTERS_EVN_LSB) <= input_status_arr(5).eb_event_num;
    regs_read_arr(46)(REG_DAQ_DMB5_COUNTERS_INPUT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB5_COUNTERS_INPUT_FIFO_DATA_CNT_LSB) <= chamber_infifos(5).data_cnt;
    regs_read_arr(46)(REG_DAQ_DMB5_COUNTERS_EVT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB5_COUNTERS_EVT_FIFO_DATA_CNT_LSB) <= chamber_evtfifos(5).data_cnt;
    regs_read_arr(47)(REG_DAQ_DMB5_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB5_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(5).infifo_near_full_cnt;
    regs_read_arr(47)(REG_DAQ_DMB5_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB5_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(5).evtfifo_near_full_cnt;
    regs_read_arr(48)(REG_DAQ_DMB5_COUNTERS_DATA_WORD_RATE_MSB downto REG_DAQ_DMB5_COUNTERS_DATA_WORD_RATE_LSB) <= input_status_arr(5).infifo_wr_rate;
    regs_read_arr(48)(REG_DAQ_DMB5_COUNTERS_EVT_RATE_MSB downto REG_DAQ_DMB5_COUNTERS_EVT_RATE_LSB) <= input_status_arr(5).evtfifo_wr_rate;
    regs_read_arr(49)(REG_DAQ_DMB6_STATUS_EVT_64BIT_ALIGN_ERR_BIT) <= input_status_arr(6).err_64bit_misaligned;
    regs_read_arr(49)(REG_DAQ_DMB6_STATUS_INPUT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(6).err_infifo_full;
    regs_read_arr(49)(REG_DAQ_DMB6_STATUS_INPUT_FIFO_HAD_UFLOW_BIT) <= input_status_arr(6).err_infifo_underflow;
    regs_read_arr(49)(REG_DAQ_DMB6_STATUS_EVENT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(6).err_evtfifo_full;
    regs_read_arr(49)(REG_DAQ_DMB6_STATUS_EVT_SIZE_ERR_BIT) <= input_status_arr(6).err_event_too_big;
    regs_read_arr(49)(REG_DAQ_DMB6_STATUS_TTS_STATE_MSB downto REG_DAQ_DMB6_STATUS_TTS_STATE_LSB) <= input_status_arr(6).tts_state;
    regs_read_arr(49)(REG_DAQ_DMB6_STATUS_INPUT_FIFO_IS_UFLOW_BIT) <= input_status_arr(6).infifo_underflow;
    regs_read_arr(49)(REG_DAQ_DMB6_STATUS_INPUT_FIFO_IS_FULL_BIT) <= input_status_arr(6).infifo_full;
    regs_read_arr(49)(REG_DAQ_DMB6_STATUS_INPUT_FIFO_IS_AFULL_BIT) <= input_status_arr(6).infifo_near_full;
    regs_read_arr(49)(REG_DAQ_DMB6_STATUS_INPUT_FIFO_IS_EMPTY_BIT) <= input_status_arr(6).infifo_empty;
    regs_read_arr(49)(REG_DAQ_DMB6_STATUS_EVENT_FIFO_IS_UFLOW_BIT) <= input_status_arr(6).evtfifo_underflow;
    regs_read_arr(49)(REG_DAQ_DMB6_STATUS_EVENT_FIFO_IS_FULL_BIT) <= input_status_arr(6).evtfifo_full;
    regs_read_arr(49)(REG_DAQ_DMB6_STATUS_EVENT_FIFO_IS_AFULL_BIT) <= input_status_arr(6).evtfifo_near_full;
    regs_read_arr(49)(REG_DAQ_DMB6_STATUS_EVENT_FIFO_IS_EMPTY_BIT) <= input_status_arr(6).evtfifo_empty;
    regs_read_arr(50)(REG_DAQ_DMB6_COUNTERS_EVN_MSB downto REG_DAQ_DMB6_COUNTERS_EVN_LSB) <= input_status_arr(6).eb_event_num;
    regs_read_arr(51)(REG_DAQ_DMB6_COUNTERS_INPUT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB6_COUNTERS_INPUT_FIFO_DATA_CNT_LSB) <= chamber_infifos(6).data_cnt;
    regs_read_arr(51)(REG_DAQ_DMB6_COUNTERS_EVT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB6_COUNTERS_EVT_FIFO_DATA_CNT_LSB) <= chamber_evtfifos(6).data_cnt;
    regs_read_arr(52)(REG_DAQ_DMB6_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB6_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(6).infifo_near_full_cnt;
    regs_read_arr(52)(REG_DAQ_DMB6_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB6_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(6).evtfifo_near_full_cnt;
    regs_read_arr(53)(REG_DAQ_DMB6_COUNTERS_DATA_WORD_RATE_MSB downto REG_DAQ_DMB6_COUNTERS_DATA_WORD_RATE_LSB) <= input_status_arr(6).infifo_wr_rate;
    regs_read_arr(53)(REG_DAQ_DMB6_COUNTERS_EVT_RATE_MSB downto REG_DAQ_DMB6_COUNTERS_EVT_RATE_LSB) <= input_status_arr(6).evtfifo_wr_rate;
    regs_read_arr(54)(REG_DAQ_DMB7_STATUS_EVT_64BIT_ALIGN_ERR_BIT) <= input_status_arr(7).err_64bit_misaligned;
    regs_read_arr(54)(REG_DAQ_DMB7_STATUS_INPUT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(7).err_infifo_full;
    regs_read_arr(54)(REG_DAQ_DMB7_STATUS_INPUT_FIFO_HAD_UFLOW_BIT) <= input_status_arr(7).err_infifo_underflow;
    regs_read_arr(54)(REG_DAQ_DMB7_STATUS_EVENT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(7).err_evtfifo_full;
    regs_read_arr(54)(REG_DAQ_DMB7_STATUS_EVT_SIZE_ERR_BIT) <= input_status_arr(7).err_event_too_big;
    regs_read_arr(54)(REG_DAQ_DMB7_STATUS_TTS_STATE_MSB downto REG_DAQ_DMB7_STATUS_TTS_STATE_LSB) <= input_status_arr(7).tts_state;
    regs_read_arr(54)(REG_DAQ_DMB7_STATUS_INPUT_FIFO_IS_UFLOW_BIT) <= input_status_arr(7).infifo_underflow;
    regs_read_arr(54)(REG_DAQ_DMB7_STATUS_INPUT_FIFO_IS_FULL_BIT) <= input_status_arr(7).infifo_full;
    regs_read_arr(54)(REG_DAQ_DMB7_STATUS_INPUT_FIFO_IS_AFULL_BIT) <= input_status_arr(7).infifo_near_full;
    regs_read_arr(54)(REG_DAQ_DMB7_STATUS_INPUT_FIFO_IS_EMPTY_BIT) <= input_status_arr(7).infifo_empty;
    regs_read_arr(54)(REG_DAQ_DMB7_STATUS_EVENT_FIFO_IS_UFLOW_BIT) <= input_status_arr(7).evtfifo_underflow;
    regs_read_arr(54)(REG_DAQ_DMB7_STATUS_EVENT_FIFO_IS_FULL_BIT) <= input_status_arr(7).evtfifo_full;
    regs_read_arr(54)(REG_DAQ_DMB7_STATUS_EVENT_FIFO_IS_AFULL_BIT) <= input_status_arr(7).evtfifo_near_full;
    regs_read_arr(54)(REG_DAQ_DMB7_STATUS_EVENT_FIFO_IS_EMPTY_BIT) <= input_status_arr(7).evtfifo_empty;
    regs_read_arr(55)(REG_DAQ_DMB7_COUNTERS_EVN_MSB downto REG_DAQ_DMB7_COUNTERS_EVN_LSB) <= input_status_arr(7).eb_event_num;
    regs_read_arr(56)(REG_DAQ_DMB7_COUNTERS_INPUT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB7_COUNTERS_INPUT_FIFO_DATA_CNT_LSB) <= chamber_infifos(7).data_cnt;
    regs_read_arr(56)(REG_DAQ_DMB7_COUNTERS_EVT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB7_COUNTERS_EVT_FIFO_DATA_CNT_LSB) <= chamber_evtfifos(7).data_cnt;
    regs_read_arr(57)(REG_DAQ_DMB7_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB7_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(7).infifo_near_full_cnt;
    regs_read_arr(57)(REG_DAQ_DMB7_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB7_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(7).evtfifo_near_full_cnt;
    regs_read_arr(58)(REG_DAQ_DMB7_COUNTERS_DATA_WORD_RATE_MSB downto REG_DAQ_DMB7_COUNTERS_DATA_WORD_RATE_LSB) <= input_status_arr(7).infifo_wr_rate;
    regs_read_arr(58)(REG_DAQ_DMB7_COUNTERS_EVT_RATE_MSB downto REG_DAQ_DMB7_COUNTERS_EVT_RATE_LSB) <= input_status_arr(7).evtfifo_wr_rate;
    regs_read_arr(59)(REG_DAQ_DMB8_STATUS_EVT_64BIT_ALIGN_ERR_BIT) <= input_status_arr(8).err_64bit_misaligned;
    regs_read_arr(59)(REG_DAQ_DMB8_STATUS_INPUT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(8).err_infifo_full;
    regs_read_arr(59)(REG_DAQ_DMB8_STATUS_INPUT_FIFO_HAD_UFLOW_BIT) <= input_status_arr(8).err_infifo_underflow;
    regs_read_arr(59)(REG_DAQ_DMB8_STATUS_EVENT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(8).err_evtfifo_full;
    regs_read_arr(59)(REG_DAQ_DMB8_STATUS_EVT_SIZE_ERR_BIT) <= input_status_arr(8).err_event_too_big;
    regs_read_arr(59)(REG_DAQ_DMB8_STATUS_TTS_STATE_MSB downto REG_DAQ_DMB8_STATUS_TTS_STATE_LSB) <= input_status_arr(8).tts_state;
    regs_read_arr(59)(REG_DAQ_DMB8_STATUS_INPUT_FIFO_IS_UFLOW_BIT) <= input_status_arr(8).infifo_underflow;
    regs_read_arr(59)(REG_DAQ_DMB8_STATUS_INPUT_FIFO_IS_FULL_BIT) <= input_status_arr(8).infifo_full;
    regs_read_arr(59)(REG_DAQ_DMB8_STATUS_INPUT_FIFO_IS_AFULL_BIT) <= input_status_arr(8).infifo_near_full;
    regs_read_arr(59)(REG_DAQ_DMB8_STATUS_INPUT_FIFO_IS_EMPTY_BIT) <= input_status_arr(8).infifo_empty;
    regs_read_arr(59)(REG_DAQ_DMB8_STATUS_EVENT_FIFO_IS_UFLOW_BIT) <= input_status_arr(8).evtfifo_underflow;
    regs_read_arr(59)(REG_DAQ_DMB8_STATUS_EVENT_FIFO_IS_FULL_BIT) <= input_status_arr(8).evtfifo_full;
    regs_read_arr(59)(REG_DAQ_DMB8_STATUS_EVENT_FIFO_IS_AFULL_BIT) <= input_status_arr(8).evtfifo_near_full;
    regs_read_arr(59)(REG_DAQ_DMB8_STATUS_EVENT_FIFO_IS_EMPTY_BIT) <= input_status_arr(8).evtfifo_empty;
    regs_read_arr(60)(REG_DAQ_DMB8_COUNTERS_EVN_MSB downto REG_DAQ_DMB8_COUNTERS_EVN_LSB) <= input_status_arr(8).eb_event_num;
    regs_read_arr(61)(REG_DAQ_DMB8_COUNTERS_INPUT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB8_COUNTERS_INPUT_FIFO_DATA_CNT_LSB) <= chamber_infifos(8).data_cnt;
    regs_read_arr(61)(REG_DAQ_DMB8_COUNTERS_EVT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB8_COUNTERS_EVT_FIFO_DATA_CNT_LSB) <= chamber_evtfifos(8).data_cnt;
    regs_read_arr(62)(REG_DAQ_DMB8_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB8_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(8).infifo_near_full_cnt;
    regs_read_arr(62)(REG_DAQ_DMB8_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB8_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(8).evtfifo_near_full_cnt;
    regs_read_arr(63)(REG_DAQ_DMB8_COUNTERS_DATA_WORD_RATE_MSB downto REG_DAQ_DMB8_COUNTERS_DATA_WORD_RATE_LSB) <= input_status_arr(8).infifo_wr_rate;
    regs_read_arr(63)(REG_DAQ_DMB8_COUNTERS_EVT_RATE_MSB downto REG_DAQ_DMB8_COUNTERS_EVT_RATE_LSB) <= input_status_arr(8).evtfifo_wr_rate;
    regs_read_arr(64)(REG_DAQ_DMB9_STATUS_EVT_64BIT_ALIGN_ERR_BIT) <= input_status_arr(9).err_64bit_misaligned;
    regs_read_arr(64)(REG_DAQ_DMB9_STATUS_INPUT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(9).err_infifo_full;
    regs_read_arr(64)(REG_DAQ_DMB9_STATUS_INPUT_FIFO_HAD_UFLOW_BIT) <= input_status_arr(9).err_infifo_underflow;
    regs_read_arr(64)(REG_DAQ_DMB9_STATUS_EVENT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(9).err_evtfifo_full;
    regs_read_arr(64)(REG_DAQ_DMB9_STATUS_EVT_SIZE_ERR_BIT) <= input_status_arr(9).err_event_too_big;
    regs_read_arr(64)(REG_DAQ_DMB9_STATUS_TTS_STATE_MSB downto REG_DAQ_DMB9_STATUS_TTS_STATE_LSB) <= input_status_arr(9).tts_state;
    regs_read_arr(64)(REG_DAQ_DMB9_STATUS_INPUT_FIFO_IS_UFLOW_BIT) <= input_status_arr(9).infifo_underflow;
    regs_read_arr(64)(REG_DAQ_DMB9_STATUS_INPUT_FIFO_IS_FULL_BIT) <= input_status_arr(9).infifo_full;
    regs_read_arr(64)(REG_DAQ_DMB9_STATUS_INPUT_FIFO_IS_AFULL_BIT) <= input_status_arr(9).infifo_near_full;
    regs_read_arr(64)(REG_DAQ_DMB9_STATUS_INPUT_FIFO_IS_EMPTY_BIT) <= input_status_arr(9).infifo_empty;
    regs_read_arr(64)(REG_DAQ_DMB9_STATUS_EVENT_FIFO_IS_UFLOW_BIT) <= input_status_arr(9).evtfifo_underflow;
    regs_read_arr(64)(REG_DAQ_DMB9_STATUS_EVENT_FIFO_IS_FULL_BIT) <= input_status_arr(9).evtfifo_full;
    regs_read_arr(64)(REG_DAQ_DMB9_STATUS_EVENT_FIFO_IS_AFULL_BIT) <= input_status_arr(9).evtfifo_near_full;
    regs_read_arr(64)(REG_DAQ_DMB9_STATUS_EVENT_FIFO_IS_EMPTY_BIT) <= input_status_arr(9).evtfifo_empty;
    regs_read_arr(65)(REG_DAQ_DMB9_COUNTERS_EVN_MSB downto REG_DAQ_DMB9_COUNTERS_EVN_LSB) <= input_status_arr(9).eb_event_num;
    regs_read_arr(66)(REG_DAQ_DMB9_COUNTERS_INPUT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB9_COUNTERS_INPUT_FIFO_DATA_CNT_LSB) <= chamber_infifos(9).data_cnt;
    regs_read_arr(66)(REG_DAQ_DMB9_COUNTERS_EVT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB9_COUNTERS_EVT_FIFO_DATA_CNT_LSB) <= chamber_evtfifos(9).data_cnt;
    regs_read_arr(67)(REG_DAQ_DMB9_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB9_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(9).infifo_near_full_cnt;
    regs_read_arr(67)(REG_DAQ_DMB9_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB9_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(9).evtfifo_near_full_cnt;
    regs_read_arr(68)(REG_DAQ_DMB9_COUNTERS_DATA_WORD_RATE_MSB downto REG_DAQ_DMB9_COUNTERS_DATA_WORD_RATE_LSB) <= input_status_arr(9).infifo_wr_rate;
    regs_read_arr(68)(REG_DAQ_DMB9_COUNTERS_EVT_RATE_MSB downto REG_DAQ_DMB9_COUNTERS_EVT_RATE_LSB) <= input_status_arr(9).evtfifo_wr_rate;
    regs_read_arr(69)(REG_DAQ_DMB10_STATUS_EVT_64BIT_ALIGN_ERR_BIT) <= input_status_arr(10).err_64bit_misaligned;
    regs_read_arr(69)(REG_DAQ_DMB10_STATUS_INPUT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(10).err_infifo_full;
    regs_read_arr(69)(REG_DAQ_DMB10_STATUS_INPUT_FIFO_HAD_UFLOW_BIT) <= input_status_arr(10).err_infifo_underflow;
    regs_read_arr(69)(REG_DAQ_DMB10_STATUS_EVENT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(10).err_evtfifo_full;
    regs_read_arr(69)(REG_DAQ_DMB10_STATUS_EVT_SIZE_ERR_BIT) <= input_status_arr(10).err_event_too_big;
    regs_read_arr(69)(REG_DAQ_DMB10_STATUS_TTS_STATE_MSB downto REG_DAQ_DMB10_STATUS_TTS_STATE_LSB) <= input_status_arr(10).tts_state;
    regs_read_arr(69)(REG_DAQ_DMB10_STATUS_INPUT_FIFO_IS_UFLOW_BIT) <= input_status_arr(10).infifo_underflow;
    regs_read_arr(69)(REG_DAQ_DMB10_STATUS_INPUT_FIFO_IS_FULL_BIT) <= input_status_arr(10).infifo_full;
    regs_read_arr(69)(REG_DAQ_DMB10_STATUS_INPUT_FIFO_IS_AFULL_BIT) <= input_status_arr(10).infifo_near_full;
    regs_read_arr(69)(REG_DAQ_DMB10_STATUS_INPUT_FIFO_IS_EMPTY_BIT) <= input_status_arr(10).infifo_empty;
    regs_read_arr(69)(REG_DAQ_DMB10_STATUS_EVENT_FIFO_IS_UFLOW_BIT) <= input_status_arr(10).evtfifo_underflow;
    regs_read_arr(69)(REG_DAQ_DMB10_STATUS_EVENT_FIFO_IS_FULL_BIT) <= input_status_arr(10).evtfifo_full;
    regs_read_arr(69)(REG_DAQ_DMB10_STATUS_EVENT_FIFO_IS_AFULL_BIT) <= input_status_arr(10).evtfifo_near_full;
    regs_read_arr(69)(REG_DAQ_DMB10_STATUS_EVENT_FIFO_IS_EMPTY_BIT) <= input_status_arr(10).evtfifo_empty;
    regs_read_arr(70)(REG_DAQ_DMB10_COUNTERS_EVN_MSB downto REG_DAQ_DMB10_COUNTERS_EVN_LSB) <= input_status_arr(10).eb_event_num;
    regs_read_arr(71)(REG_DAQ_DMB10_COUNTERS_INPUT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB10_COUNTERS_INPUT_FIFO_DATA_CNT_LSB) <= chamber_infifos(10).data_cnt;
    regs_read_arr(71)(REG_DAQ_DMB10_COUNTERS_EVT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB10_COUNTERS_EVT_FIFO_DATA_CNT_LSB) <= chamber_evtfifos(10).data_cnt;
    regs_read_arr(72)(REG_DAQ_DMB10_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB10_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(10).infifo_near_full_cnt;
    regs_read_arr(72)(REG_DAQ_DMB10_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB10_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(10).evtfifo_near_full_cnt;
    regs_read_arr(73)(REG_DAQ_DMB10_COUNTERS_DATA_WORD_RATE_MSB downto REG_DAQ_DMB10_COUNTERS_DATA_WORD_RATE_LSB) <= input_status_arr(10).infifo_wr_rate;
    regs_read_arr(73)(REG_DAQ_DMB10_COUNTERS_EVT_RATE_MSB downto REG_DAQ_DMB10_COUNTERS_EVT_RATE_LSB) <= input_status_arr(10).evtfifo_wr_rate;
    regs_read_arr(74)(REG_DAQ_DMB11_STATUS_EVT_64BIT_ALIGN_ERR_BIT) <= input_status_arr(11).err_64bit_misaligned;
    regs_read_arr(74)(REG_DAQ_DMB11_STATUS_INPUT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(11).err_infifo_full;
    regs_read_arr(74)(REG_DAQ_DMB11_STATUS_INPUT_FIFO_HAD_UFLOW_BIT) <= input_status_arr(11).err_infifo_underflow;
    regs_read_arr(74)(REG_DAQ_DMB11_STATUS_EVENT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(11).err_evtfifo_full;
    regs_read_arr(74)(REG_DAQ_DMB11_STATUS_EVT_SIZE_ERR_BIT) <= input_status_arr(11).err_event_too_big;
    regs_read_arr(74)(REG_DAQ_DMB11_STATUS_TTS_STATE_MSB downto REG_DAQ_DMB11_STATUS_TTS_STATE_LSB) <= input_status_arr(11).tts_state;
    regs_read_arr(74)(REG_DAQ_DMB11_STATUS_INPUT_FIFO_IS_UFLOW_BIT) <= input_status_arr(11).infifo_underflow;
    regs_read_arr(74)(REG_DAQ_DMB11_STATUS_INPUT_FIFO_IS_FULL_BIT) <= input_status_arr(11).infifo_full;
    regs_read_arr(74)(REG_DAQ_DMB11_STATUS_INPUT_FIFO_IS_AFULL_BIT) <= input_status_arr(11).infifo_near_full;
    regs_read_arr(74)(REG_DAQ_DMB11_STATUS_INPUT_FIFO_IS_EMPTY_BIT) <= input_status_arr(11).infifo_empty;
    regs_read_arr(74)(REG_DAQ_DMB11_STATUS_EVENT_FIFO_IS_UFLOW_BIT) <= input_status_arr(11).evtfifo_underflow;
    regs_read_arr(74)(REG_DAQ_DMB11_STATUS_EVENT_FIFO_IS_FULL_BIT) <= input_status_arr(11).evtfifo_full;
    regs_read_arr(74)(REG_DAQ_DMB11_STATUS_EVENT_FIFO_IS_AFULL_BIT) <= input_status_arr(11).evtfifo_near_full;
    regs_read_arr(74)(REG_DAQ_DMB11_STATUS_EVENT_FIFO_IS_EMPTY_BIT) <= input_status_arr(11).evtfifo_empty;
    regs_read_arr(75)(REG_DAQ_DMB11_COUNTERS_EVN_MSB downto REG_DAQ_DMB11_COUNTERS_EVN_LSB) <= input_status_arr(11).eb_event_num;
    regs_read_arr(76)(REG_DAQ_DMB11_COUNTERS_INPUT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB11_COUNTERS_INPUT_FIFO_DATA_CNT_LSB) <= chamber_infifos(11).data_cnt;
    regs_read_arr(76)(REG_DAQ_DMB11_COUNTERS_EVT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB11_COUNTERS_EVT_FIFO_DATA_CNT_LSB) <= chamber_evtfifos(11).data_cnt;
    regs_read_arr(77)(REG_DAQ_DMB11_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB11_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(11).infifo_near_full_cnt;
    regs_read_arr(77)(REG_DAQ_DMB11_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB11_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(11).evtfifo_near_full_cnt;
    regs_read_arr(78)(REG_DAQ_DMB11_COUNTERS_DATA_WORD_RATE_MSB downto REG_DAQ_DMB11_COUNTERS_DATA_WORD_RATE_LSB) <= input_status_arr(11).infifo_wr_rate;
    regs_read_arr(78)(REG_DAQ_DMB11_COUNTERS_EVT_RATE_MSB downto REG_DAQ_DMB11_COUNTERS_EVT_RATE_LSB) <= input_status_arr(11).evtfifo_wr_rate;
    regs_read_arr(79)(REG_DAQ_DMB12_STATUS_EVT_64BIT_ALIGN_ERR_BIT) <= input_status_arr(12).err_64bit_misaligned;
    regs_read_arr(79)(REG_DAQ_DMB12_STATUS_INPUT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(12).err_infifo_full;
    regs_read_arr(79)(REG_DAQ_DMB12_STATUS_INPUT_FIFO_HAD_UFLOW_BIT) <= input_status_arr(12).err_infifo_underflow;
    regs_read_arr(79)(REG_DAQ_DMB12_STATUS_EVENT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(12).err_evtfifo_full;
    regs_read_arr(79)(REG_DAQ_DMB12_STATUS_EVT_SIZE_ERR_BIT) <= input_status_arr(12).err_event_too_big;
    regs_read_arr(79)(REG_DAQ_DMB12_STATUS_TTS_STATE_MSB downto REG_DAQ_DMB12_STATUS_TTS_STATE_LSB) <= input_status_arr(12).tts_state;
    regs_read_arr(79)(REG_DAQ_DMB12_STATUS_INPUT_FIFO_IS_UFLOW_BIT) <= input_status_arr(12).infifo_underflow;
    regs_read_arr(79)(REG_DAQ_DMB12_STATUS_INPUT_FIFO_IS_FULL_BIT) <= input_status_arr(12).infifo_full;
    regs_read_arr(79)(REG_DAQ_DMB12_STATUS_INPUT_FIFO_IS_AFULL_BIT) <= input_status_arr(12).infifo_near_full;
    regs_read_arr(79)(REG_DAQ_DMB12_STATUS_INPUT_FIFO_IS_EMPTY_BIT) <= input_status_arr(12).infifo_empty;
    regs_read_arr(79)(REG_DAQ_DMB12_STATUS_EVENT_FIFO_IS_UFLOW_BIT) <= input_status_arr(12).evtfifo_underflow;
    regs_read_arr(79)(REG_DAQ_DMB12_STATUS_EVENT_FIFO_IS_FULL_BIT) <= input_status_arr(12).evtfifo_full;
    regs_read_arr(79)(REG_DAQ_DMB12_STATUS_EVENT_FIFO_IS_AFULL_BIT) <= input_status_arr(12).evtfifo_near_full;
    regs_read_arr(79)(REG_DAQ_DMB12_STATUS_EVENT_FIFO_IS_EMPTY_BIT) <= input_status_arr(12).evtfifo_empty;
    regs_read_arr(80)(REG_DAQ_DMB12_COUNTERS_EVN_MSB downto REG_DAQ_DMB12_COUNTERS_EVN_LSB) <= input_status_arr(12).eb_event_num;
    regs_read_arr(81)(REG_DAQ_DMB12_COUNTERS_INPUT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB12_COUNTERS_INPUT_FIFO_DATA_CNT_LSB) <= chamber_infifos(12).data_cnt;
    regs_read_arr(81)(REG_DAQ_DMB12_COUNTERS_EVT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB12_COUNTERS_EVT_FIFO_DATA_CNT_LSB) <= chamber_evtfifos(12).data_cnt;
    regs_read_arr(82)(REG_DAQ_DMB12_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB12_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(12).infifo_near_full_cnt;
    regs_read_arr(82)(REG_DAQ_DMB12_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB12_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(12).evtfifo_near_full_cnt;
    regs_read_arr(83)(REG_DAQ_DMB12_COUNTERS_DATA_WORD_RATE_MSB downto REG_DAQ_DMB12_COUNTERS_DATA_WORD_RATE_LSB) <= input_status_arr(12).infifo_wr_rate;
    regs_read_arr(83)(REG_DAQ_DMB12_COUNTERS_EVT_RATE_MSB downto REG_DAQ_DMB12_COUNTERS_EVT_RATE_LSB) <= input_status_arr(12).evtfifo_wr_rate;
    regs_read_arr(84)(REG_DAQ_DMB13_STATUS_EVT_64BIT_ALIGN_ERR_BIT) <= input_status_arr(13).err_64bit_misaligned;
    regs_read_arr(84)(REG_DAQ_DMB13_STATUS_INPUT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(13).err_infifo_full;
    regs_read_arr(84)(REG_DAQ_DMB13_STATUS_INPUT_FIFO_HAD_UFLOW_BIT) <= input_status_arr(13).err_infifo_underflow;
    regs_read_arr(84)(REG_DAQ_DMB13_STATUS_EVENT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(13).err_evtfifo_full;
    regs_read_arr(84)(REG_DAQ_DMB13_STATUS_EVT_SIZE_ERR_BIT) <= input_status_arr(13).err_event_too_big;
    regs_read_arr(84)(REG_DAQ_DMB13_STATUS_TTS_STATE_MSB downto REG_DAQ_DMB13_STATUS_TTS_STATE_LSB) <= input_status_arr(13).tts_state;
    regs_read_arr(84)(REG_DAQ_DMB13_STATUS_INPUT_FIFO_IS_UFLOW_BIT) <= input_status_arr(13).infifo_underflow;
    regs_read_arr(84)(REG_DAQ_DMB13_STATUS_INPUT_FIFO_IS_FULL_BIT) <= input_status_arr(13).infifo_full;
    regs_read_arr(84)(REG_DAQ_DMB13_STATUS_INPUT_FIFO_IS_AFULL_BIT) <= input_status_arr(13).infifo_near_full;
    regs_read_arr(84)(REG_DAQ_DMB13_STATUS_INPUT_FIFO_IS_EMPTY_BIT) <= input_status_arr(13).infifo_empty;
    regs_read_arr(84)(REG_DAQ_DMB13_STATUS_EVENT_FIFO_IS_UFLOW_BIT) <= input_status_arr(13).evtfifo_underflow;
    regs_read_arr(84)(REG_DAQ_DMB13_STATUS_EVENT_FIFO_IS_FULL_BIT) <= input_status_arr(13).evtfifo_full;
    regs_read_arr(84)(REG_DAQ_DMB13_STATUS_EVENT_FIFO_IS_AFULL_BIT) <= input_status_arr(13).evtfifo_near_full;
    regs_read_arr(84)(REG_DAQ_DMB13_STATUS_EVENT_FIFO_IS_EMPTY_BIT) <= input_status_arr(13).evtfifo_empty;
    regs_read_arr(85)(REG_DAQ_DMB13_COUNTERS_EVN_MSB downto REG_DAQ_DMB13_COUNTERS_EVN_LSB) <= input_status_arr(13).eb_event_num;
    regs_read_arr(86)(REG_DAQ_DMB13_COUNTERS_INPUT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB13_COUNTERS_INPUT_FIFO_DATA_CNT_LSB) <= chamber_infifos(13).data_cnt;
    regs_read_arr(86)(REG_DAQ_DMB13_COUNTERS_EVT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB13_COUNTERS_EVT_FIFO_DATA_CNT_LSB) <= chamber_evtfifos(13).data_cnt;
    regs_read_arr(87)(REG_DAQ_DMB13_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB13_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(13).infifo_near_full_cnt;
    regs_read_arr(87)(REG_DAQ_DMB13_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB13_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(13).evtfifo_near_full_cnt;
    regs_read_arr(88)(REG_DAQ_DMB13_COUNTERS_DATA_WORD_RATE_MSB downto REG_DAQ_DMB13_COUNTERS_DATA_WORD_RATE_LSB) <= input_status_arr(13).infifo_wr_rate;
    regs_read_arr(88)(REG_DAQ_DMB13_COUNTERS_EVT_RATE_MSB downto REG_DAQ_DMB13_COUNTERS_EVT_RATE_LSB) <= input_status_arr(13).evtfifo_wr_rate;
    regs_read_arr(89)(REG_DAQ_DMB14_STATUS_EVT_64BIT_ALIGN_ERR_BIT) <= input_status_arr(14).err_64bit_misaligned;
    regs_read_arr(89)(REG_DAQ_DMB14_STATUS_INPUT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(14).err_infifo_full;
    regs_read_arr(89)(REG_DAQ_DMB14_STATUS_INPUT_FIFO_HAD_UFLOW_BIT) <= input_status_arr(14).err_infifo_underflow;
    regs_read_arr(89)(REG_DAQ_DMB14_STATUS_EVENT_FIFO_HAD_OFLOW_BIT) <= input_status_arr(14).err_evtfifo_full;
    regs_read_arr(89)(REG_DAQ_DMB14_STATUS_EVT_SIZE_ERR_BIT) <= input_status_arr(14).err_event_too_big;
    regs_read_arr(89)(REG_DAQ_DMB14_STATUS_TTS_STATE_MSB downto REG_DAQ_DMB14_STATUS_TTS_STATE_LSB) <= input_status_arr(14).tts_state;
    regs_read_arr(89)(REG_DAQ_DMB14_STATUS_INPUT_FIFO_IS_UFLOW_BIT) <= input_status_arr(14).infifo_underflow;
    regs_read_arr(89)(REG_DAQ_DMB14_STATUS_INPUT_FIFO_IS_FULL_BIT) <= input_status_arr(14).infifo_full;
    regs_read_arr(89)(REG_DAQ_DMB14_STATUS_INPUT_FIFO_IS_AFULL_BIT) <= input_status_arr(14).infifo_near_full;
    regs_read_arr(89)(REG_DAQ_DMB14_STATUS_INPUT_FIFO_IS_EMPTY_BIT) <= input_status_arr(14).infifo_empty;
    regs_read_arr(89)(REG_DAQ_DMB14_STATUS_EVENT_FIFO_IS_UFLOW_BIT) <= input_status_arr(14).evtfifo_underflow;
    regs_read_arr(89)(REG_DAQ_DMB14_STATUS_EVENT_FIFO_IS_FULL_BIT) <= input_status_arr(14).evtfifo_full;
    regs_read_arr(89)(REG_DAQ_DMB14_STATUS_EVENT_FIFO_IS_AFULL_BIT) <= input_status_arr(14).evtfifo_near_full;
    regs_read_arr(89)(REG_DAQ_DMB14_STATUS_EVENT_FIFO_IS_EMPTY_BIT) <= input_status_arr(14).evtfifo_empty;
    regs_read_arr(90)(REG_DAQ_DMB14_COUNTERS_EVN_MSB downto REG_DAQ_DMB14_COUNTERS_EVN_LSB) <= input_status_arr(14).eb_event_num;
    regs_read_arr(91)(REG_DAQ_DMB14_COUNTERS_INPUT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB14_COUNTERS_INPUT_FIFO_DATA_CNT_LSB) <= chamber_infifos(14).data_cnt;
    regs_read_arr(91)(REG_DAQ_DMB14_COUNTERS_EVT_FIFO_DATA_CNT_MSB downto REG_DAQ_DMB14_COUNTERS_EVT_FIFO_DATA_CNT_LSB) <= chamber_evtfifos(14).data_cnt;
    regs_read_arr(92)(REG_DAQ_DMB14_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB14_COUNTERS_INPUT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(14).infifo_near_full_cnt;
    regs_read_arr(92)(REG_DAQ_DMB14_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_MSB downto REG_DAQ_DMB14_COUNTERS_EVT_FIFO_NEAR_FULL_CNT_LSB) <= input_status_arr(14).evtfifo_near_full_cnt;
    regs_read_arr(93)(REG_DAQ_DMB14_COUNTERS_DATA_WORD_RATE_MSB downto REG_DAQ_DMB14_COUNTERS_DATA_WORD_RATE_LSB) <= input_status_arr(14).infifo_wr_rate;
    regs_read_arr(93)(REG_DAQ_DMB14_COUNTERS_EVT_RATE_MSB downto REG_DAQ_DMB14_COUNTERS_EVT_RATE_LSB) <= input_status_arr(14).evtfifo_wr_rate;

    -- Connect write signals
    daq_enable <= regs_write_arr(0)(REG_DAQ_CONTROL_DAQ_ENABLE_BIT);
    ignore_amc13 <= regs_write_arr(0)(REG_DAQ_CONTROL_IGNORE_AMC13_BIT);
    reset_daqlink_ipb <= regs_write_arr(0)(REG_DAQ_CONTROL_DAQ_LINK_RESET_BIT);
    reset_local <= regs_write_arr(0)(REG_DAQ_CONTROL_RESET_BIT);
    tts_override <= regs_write_arr(0)(REG_DAQ_CONTROL_TTS_OVERRIDE_MSB downto REG_DAQ_CONTROL_TTS_OVERRIDE_LSB);
    input_mask <= regs_write_arr(0)(REG_DAQ_CONTROL_INPUT_ENABLE_MASK_MSB downto REG_DAQ_CONTROL_INPUT_ENABLE_MASK_LSB);
    dav_timeout <= regs_write_arr(1)(REG_DAQ_CONTROL_DAV_TIMEOUT_MSB downto REG_DAQ_CONTROL_DAV_TIMEOUT_LSB);
    freeze_on_error <= regs_write_arr(1)(REG_DAQ_CONTROL_FREEZE_ON_ERROR_BIT);
    reset_till_resync <= regs_write_arr(1)(REG_DAQ_CONTROL_RESET_TILL_RESYNC_BIT);
    run_params <= regs_write_arr(2)(REG_DAQ_CONTROL_RUN_PARAMS_MSB downto REG_DAQ_CONTROL_RUN_PARAMS_LSB);
    run_type <= regs_write_arr(2)(REG_DAQ_CONTROL_RUN_TYPE_MSB downto REG_DAQ_CONTROL_RUN_TYPE_LSB);
    spy_gbe_skip_headers <= regs_write_arr(3)(REG_DAQ_CONTROL_SPY_SPY_SKIP_ETH_HEADER_BIT);
    spy_skip_empty_evts <= regs_write_arr(3)(REG_DAQ_CONTROL_SPY_SPY_SKIP_EMPTY_EVENTS_BIT);
    spy_prescale <= regs_write_arr(3)(REG_DAQ_CONTROL_SPY_SPY_PRESCALE_MSB downto REG_DAQ_CONTROL_SPY_SPY_PRESCALE_LSB);
    block_last_evt_fifo <= regs_write_arr(17)(REG_DAQ_LAST_EVENT_FIFO_DISABLE_BIT);

    -- Connect write pulse signals

    -- Connect write done signals

    -- Connect read pulse signals
    last_evt_fifo_rd_en <= regs_read_pulse_arr(18);

    -- Connect read ready signals
    regs_read_ready_arr(18) <= last_evt_fifo_valid;

    -- Defaults
    regs_defaults(0)(REG_DAQ_CONTROL_DAQ_ENABLE_BIT) <= REG_DAQ_CONTROL_DAQ_ENABLE_DEFAULT;
    regs_defaults(0)(REG_DAQ_CONTROL_IGNORE_AMC13_BIT) <= REG_DAQ_CONTROL_IGNORE_AMC13_DEFAULT;
    regs_defaults(0)(REG_DAQ_CONTROL_DAQ_LINK_RESET_BIT) <= REG_DAQ_CONTROL_DAQ_LINK_RESET_DEFAULT;
    regs_defaults(0)(REG_DAQ_CONTROL_RESET_BIT) <= REG_DAQ_CONTROL_RESET_DEFAULT;
    regs_defaults(0)(REG_DAQ_CONTROL_TTS_OVERRIDE_MSB downto REG_DAQ_CONTROL_TTS_OVERRIDE_LSB) <= REG_DAQ_CONTROL_TTS_OVERRIDE_DEFAULT;
    regs_defaults(0)(REG_DAQ_CONTROL_INPUT_ENABLE_MASK_MSB downto REG_DAQ_CONTROL_INPUT_ENABLE_MASK_LSB) <= REG_DAQ_CONTROL_INPUT_ENABLE_MASK_DEFAULT;
    regs_defaults(1)(REG_DAQ_CONTROL_DAV_TIMEOUT_MSB downto REG_DAQ_CONTROL_DAV_TIMEOUT_LSB) <= REG_DAQ_CONTROL_DAV_TIMEOUT_DEFAULT;
    regs_defaults(1)(REG_DAQ_CONTROL_FREEZE_ON_ERROR_BIT) <= REG_DAQ_CONTROL_FREEZE_ON_ERROR_DEFAULT;
    regs_defaults(1)(REG_DAQ_CONTROL_RESET_TILL_RESYNC_BIT) <= REG_DAQ_CONTROL_RESET_TILL_RESYNC_DEFAULT;
    regs_defaults(2)(REG_DAQ_CONTROL_RUN_PARAMS_MSB downto REG_DAQ_CONTROL_RUN_PARAMS_LSB) <= REG_DAQ_CONTROL_RUN_PARAMS_DEFAULT;
    regs_defaults(2)(REG_DAQ_CONTROL_RUN_TYPE_MSB downto REG_DAQ_CONTROL_RUN_TYPE_LSB) <= REG_DAQ_CONTROL_RUN_TYPE_DEFAULT;
    regs_defaults(3)(REG_DAQ_CONTROL_SPY_SPY_SKIP_ETH_HEADER_BIT) <= REG_DAQ_CONTROL_SPY_SPY_SKIP_ETH_HEADER_DEFAULT;
    regs_defaults(3)(REG_DAQ_CONTROL_SPY_SPY_SKIP_EMPTY_EVENTS_BIT) <= REG_DAQ_CONTROL_SPY_SPY_SKIP_EMPTY_EVENTS_DEFAULT;
    regs_defaults(3)(REG_DAQ_CONTROL_SPY_SPY_PRESCALE_MSB downto REG_DAQ_CONTROL_SPY_SPY_PRESCALE_LSB) <= REG_DAQ_CONTROL_SPY_SPY_PRESCALE_DEFAULT;
    regs_defaults(17)(REG_DAQ_LAST_EVENT_FIFO_DISABLE_BIT) <= REG_DAQ_LAST_EVENT_FIFO_DISABLE_DEFAULT;

    -- Define writable regs
    regs_writable_arr(0) <= '1';
    regs_writable_arr(1) <= '1';
    regs_writable_arr(2) <= '1';
    regs_writable_arr(3) <= '1';
    regs_writable_arr(17) <= '1';

    --==== Registers end ============================================================================

    
end Behavioral;

