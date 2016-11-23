------------------------------------------------------------------------------------------------------------------------------------------------------
-- Company: TAMU
-- Engineer: Evaldas Juska (evaldas.juska@cern.ch, evka85@gmail.com)
-- 
-- Create Date:    00:45 2016-11-07
-- Module Name:    gth_phase_aligner
-- Description:    This module is measuring the phase relationship between TXUSRCLK and TXOUTCLKPCS and driving the Phase Interpolator to shift them in-phase
--                 This is used when TXUSRCLK is not driven by TXOUTCLK but from another source (though exact same frequency as refclk!) e.g. from TTC, which is good for keeping GBTx in-phase with TTC
------------------------------------------------------------------------------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

use work.gth_pkg.all;

entity gth_phase_aligner is
--    generic(
--        g_LOCK_WAIT_TIME        : integer := 10000
--    );
    port(
        -- reset
        reset_i                 : in  std_logic;

        -- clocks
        stable_clk50_i          : in  std_logic; -- 50MHz
        txusrclk_i              : in  std_logic; -- should be connected to TXUSRCLK that's fed to the GTH to be aligned
        txoutclkpcs_i           : in  std_logic; -- should be connected to TXOUTCLKPCS of the GTH to be aligned
        
        -- control / status 
        sync_en_i               : in  std_logic; -- should be set to '1' to enable the sync procedure, should be set back to '0' when sync_done_o is '1'
        sync_done_o             : out std_logic; -- set to '1' when the sync procedure has finished (can set sync_en_i to '0' or even assert reset_i at this point) 
        
        -- to Phase Interpolator
        pippm_en_o              : out std_logic; -- should be connected to TXPIPPMEN of the GTH in question
        pippm_stepsize_o        : out std_logic_vector(4 downto 0); -- should be connected to TXPIPPMSTEPSIZE of the GTH in question
        
        -- settings
        lock_wait_time_i        : in  std_logic_vector(23 downto 0);
        pippm_en_hold_time_i    : in  std_logic_vector(3 downto 0)     -- number of TXUSRCLK cycles to hold TXPIPPMEN signal (should be set to TXPI_SYNFREQ_PPM + 1, normally 2 is ok)
--        num_cycles_to_check_i   : in std_logic_vector(23 downto 0); -- number of clk50 cycles to check the phase relationship between each phase shift
--        num_allowed_errors_i    : in std_logic_vector(23 downto 0)  -- number of allowed txusrclk_i and txoutclkpcs_i differences in num_cycles_to_check_i clk50 cycles to consider sync done
    );
end gth_phase_aligner;

architecture gth_phase_aligner_arch of gth_phase_aligner is

    type state_t is (IDLE, CHECK_PHASE, SHIFT_PHASE, SYNC_DONE);

    signal state                : state_t := IDLE;
    signal lock_wait_timer      : unsigned(23 downto 0) := (others => '0');
    signal pippm_en_timer       : unsigned(3 downto 0) := (others => '0');

    signal txusrclk_sync50      : std_logic;
    signal txoutclkpcs_sync50   : std_logic;

    signal txoutclkpcs_bufg     : std_logic;
    signal pll_reset            : std_logic := '1';
    signal pll_pwrdwn           : std_logic := '0';
    signal pll_locked           : std_logic;

begin

    sync_done_o <= '1' when state = SYNC_DONE else '0';
    pll_pwrdwn <= '0'; 
    
    pippm_stepsize_o <= "00001";

    process(txusrclk_i)
    begin
        if (rising_edge(txusrclk_i)) then
            if (reset_i = '1') then
                state <= IDLE;
                pll_reset <= '1';
                pippm_en_o <= '0';
                lock_wait_timer <= (others => '0'); 
                pippm_en_timer <= (others => '0');
            else
                case state is
                    when IDLE =>
                        if (sync_en_i = '1') then
                            state <= CHECK_PHASE;
                        end if;
                        
                        pll_reset <= '1';
                        pippm_en_o <= '0';
                        lock_wait_timer <= (others => '0');
                        pippm_en_timer <= (others => '0');
                        
                    when CHECK_PHASE =>
                        if (pll_locked = '1') then
                            state <= SYNC_DONE;
                        else
                            if (lock_wait_timer = 0) then
                                pll_reset <= '1';
                                lock_wait_timer <= lock_wait_timer + 1;
                            elsif (lock_wait_timer = unsigned(lock_wait_time_i)) then
                                state <= SHIFT_PHASE;
                                pll_reset <= '1';
                                lock_wait_timer <= (others => '0');
                            else
                                lock_wait_timer <= lock_wait_timer + 1;
                                pll_reset <= '0';
                            end if;
                        end if;
                        
                        pippm_en_o <= '0';
                        
                        
                    when SHIFT_PHASE =>
                        if (pippm_en_timer /= unsigned(pippm_en_hold_time_i)) then
                            pippm_en_o <= '1';
                            pippm_en_timer <= pippm_en_timer + 1;
                        else
                            pippm_en_o <= '0';
                            pippm_en_timer <= (others => '0');
                            state <= CHECK_PHASE;
                        end if;
                        
                        pll_reset <= '1';
                        
                    when SYNC_DONE =>
                        state <= SYNC_DONE;
                        pippm_en_o <= '0';
                        
                    when others =>
                        state <= IDLE;
                        pippm_en_o <= '0';
                        
                end case;
            end if;
        end if;
    end process;

--    i_txusrclk_sync50 : entity work.synchronizer
--        generic map(
--            N_STAGES => 3
--        )
--        port map(
--            async_i => txusrclk_i,
--            clk_i   => stable_clk50_i,
--            sync_o  => txusrclk_sync50
--        );
--  
--    i_txoutclkpcs_sync50 : entity work.synchronizer
--        generic map(
--            N_STAGES => 3
--        )
--        port map(
--            async_i => txoutclkpcs_i,
--            clk_i   => stable_clk50_i,
--            sync_o  => txoutclkpcs_sync50
--        );
--        
--    -- count clock differences
--    process(stable_clk50_i)
--    begin
--    end process;
    
    i_txoutclkpcs_bufg : BUFG
        port map(
            O => txoutclkpcs_bufg,
            I => txoutclkpcs_i
        );
    
    i_phase_monitor_pll : PLLE2_BASE
        generic map(
            BANDWIDTH          => "OPTIMIZED",
            CLKFBOUT_MULT      => 7,
            CLKFBOUT_PHASE     => 0.000,
            CLKIN1_PERIOD      => 8.333,
            CLKOUT0_DIVIDE     => 7,
            CLKOUT0_DUTY_CYCLE => 0.500,
            CLKOUT0_PHASE      => 0.000,
            CLKOUT1_DIVIDE     => 7,
            CLKOUT1_DUTY_CYCLE => 0.500,
            CLKOUT1_PHASE      => 0.000,
            CLKOUT2_DIVIDE     => 7,
            CLKOUT2_DUTY_CYCLE => 0.500,
            CLKOUT2_PHASE      => 0.000,
            CLKOUT3_DIVIDE     => 7,
            CLKOUT3_DUTY_CYCLE => 0.500,
            CLKOUT3_PHASE      => 0.000,
            DIVCLK_DIVIDE      => 1,
            REF_JITTER1        => 0.010
        )
        port map(
            CLKFBOUT => open,
            CLKOUT0  => open,
            CLKOUT1  => open,
            CLKOUT2  => open,
            CLKOUT3  => open,
            CLKOUT4  => open,
            CLKOUT5  => open,
            LOCKED   => pll_locked,
            CLKFBIN  => txoutclkpcs_bufg,
            CLKIN1   => txusrclk_i,
            PWRDWN   => pll_pwrdwn,
            RST      => pll_reset
        );

end gth_phase_aligner_arch;
