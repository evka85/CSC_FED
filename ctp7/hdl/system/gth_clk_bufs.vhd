-------------------------------------------------------------------------------
--                                                                            
--       Unit Name: gth_clk_bufs                                           
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
use IEEE.NUMERIC_STD.all;

library UNISIM;
use UNISIM.VCOMPONENTS.all;

library work;
use work.gth_pkg.all;
use work.system_package.all;

--============================================================================
--                                                          Entity declaration
--============================================================================
entity gth_clk_bufs is
  generic
    (
      g_NUM_OF_GTH_GTs : integer := 36
      );
  port (

    refclk_F_0_p_i : in std_logic_vector (3 downto 0);
    refclk_F_0_n_i : in std_logic_vector (3 downto 0);
    refclk_F_1_p_i : in std_logic_vector (3 downto 0);
    refclk_F_1_n_i : in std_logic_vector (3 downto 0);
    refclk_B_0_p_i : in std_logic_vector (3 downto 1);
    refclk_B_0_n_i : in std_logic_vector (3 downto 1);
    refclk_B_1_p_i : in std_logic_vector (3 downto 1);
    refclk_B_1_n_i : in std_logic_vector (3 downto 1);

    refclk_F_0_o : out std_logic_vector (3 downto 0);
    refclk_F_1_o : out std_logic_vector (3 downto 0);
    refclk_B_0_o : out std_logic_vector (3 downto 1);
    refclk_B_1_o : out std_logic_vector (3 downto 1);

    gth_gt_clk_out_arr_i : in t_gth_gt_clk_out_arr(g_NUM_OF_GTH_GTs-1 downto 0);

    clk_gth_tx_usrclk_arr_o : out std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0);
    clk_gth_rx_usrclk_arr_o : out std_logic_vector(g_NUM_OF_GTH_GTs-1 downto 0)

    );
end gth_clk_bufs;

--============================================================================
architecture gth_clk_bufs_arch of gth_clk_bufs is

--============================================================================
--                                                         Signal declarations
--============================================================================

  signal s_gth_1p6g_txusrclk        : std_logic;
  signal s_gth_1p6g_txoutclk        : std_logic;

  signal s_gth_3p2g_txusrclk        : std_logic;
  signal s_gth_3p2g_txoutclk        : std_logic;
  
--============================================================================
--                                                          Architecture begin
--============================================================================

begin

--============================================================================

  gen_ibufds_F_clk_gte2 : for i in 0 to 3 generate

    i_ibufds_F_0 : IBUFDS_GTE2
      port map
      (
        O     => refclk_F_0_o(i),
        ODIV2 => open,
        CEB   => '0',
        I     => refclk_F_0_p_i(i),
        IB    => refclk_F_0_n_i(i)
        );

    i_ibufds_F_1 : IBUFDS_GTE2
      port map
      (
        O     => refclk_F_1_o(i),
        ODIV2 => open,
        CEB   => '0',
        I     => refclk_F_1_p_i(i),
        IB    => refclk_F_1_n_i(i)
        );
  end generate;

  gen_ibufds_B_clk_gte2 : for i in 1 to 3 generate

    i_ibufds_B_0 : IBUFDS_GTE2
      port map
      (
        O     => refclk_B_0_o(i),
        ODIV2 => open,
        CEB   => '0',
        I     => refclk_B_0_p_i(i),
        IB    => refclk_B_0_n_i(i)
        );

    i_ibufds_B_1 : IBUFDS_GTE2
      port map
      (
        O     => refclk_B_1_o(i),
        ODIV2 => open,
        CEB   => '0',
        I     => refclk_B_1_p_i(i),
        IB    => refclk_B_1_n_i(i)
        );

  end generate;

--============================================================================

  gen_bufh_outclks : for n in 0 to g_NUM_OF_GTH_GTs-1 generate

    -- 1.6Gbs link with elastic buffers and clock correction (RXUSRCLK = master TXUSRCLK)
    gen_gth_1p6g_txuserclk : if c_gth_config_arr(n).gth_link_type = gth_1p6g_8b10b_buf generate

      gen_gth_1p6g_txuserclk_master : if c_gth_config_arr(n).gth_txclk_out_master = true generate

        s_gth_1p6g_txoutclk <= gth_gt_clk_out_arr_i(n).txoutclk;

        i_bufg_1p6g_tx_outclk : BUFG
        port map
        (
          I => s_gth_1p6g_txoutclk,
          O => s_gth_1p6g_txusrclk
        );

      end generate;

      clk_gth_tx_usrclk_arr_o(n) <= s_gth_1p6g_txusrclk;
      clk_gth_rx_usrclk_arr_o(n) <= s_gth_1p6g_txusrclk;

    end generate;
  
    -- 3.2Gbs link with no elastic buffers (use RX recovered clocks on BUFHs)
    gen_gth_3p2g_txuserclk : if c_gth_config_arr(n).gth_link_type = gth_3p2g_8b10b_nobuf generate

      gen_gth_3p2g_txuserclk_master : if c_gth_config_arr(n).gth_txclk_out_master = true generate

        s_gth_3p2g_txoutclk <= gth_gt_clk_out_arr_i(n).txoutclk;

        i_bufg_3p2g_tx_outclk : BUFG
          port map
          (
            I => s_gth_3p2g_txoutclk,
            O => s_gth_3p2g_txusrclk
            );

      end generate;

      clk_gth_tx_usrclk_arr_o(n) <= s_gth_3p2g_txusrclk;

      i_bufh_rx_outclk : BUFH
      port map
      (
        I => gth_gt_clk_out_arr_i(n).rxoutclk,
        O => clk_gth_rx_usrclk_arr_o(n)
      );
      
    end generate;


  end generate;

end gth_clk_bufs_arch;
--============================================================================
--                                                            Architecture end
--============================================================================

