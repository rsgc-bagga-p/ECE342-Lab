	component nios_system is
		port (
			clk_clk            : in    std_logic                    := 'X';             -- clk
			leds_export        : out   std_logic_vector(9 downto 0);                    -- export
			reset_reset_n      : in    std_logic                    := 'X';             -- reset_n
			switches_export    : in    std_logic_vector(9 downto 0) := (others => 'X'); -- export
			vga_b_export       : inout std_logic_vector(7 downto 0) := (others => 'X'); -- export
			vga_blank_n_export : out   std_logic;                                       -- export
			vga_clk_export     : out   std_logic;                                       -- export
			vga_g_export       : out   std_logic_vector(7 downto 0);                    -- export
			vga_hs_export      : out   std_logic;                                       -- export
			vga_r_export       : out   std_logic_vector(7 downto 0);                    -- export
			vga_sync_n_export  : out   std_logic;                                       -- export
			vga_vs_export      : out   std_logic                                        -- export
		);
	end component nios_system;

	u0 : component nios_system
		port map (
			clk_clk            => CONNECTED_TO_clk_clk,            --         clk.clk
			leds_export        => CONNECTED_TO_leds_export,        --        leds.export
			reset_reset_n      => CONNECTED_TO_reset_reset_n,      --       reset.reset_n
			switches_export    => CONNECTED_TO_switches_export,    --    switches.export
			vga_b_export       => CONNECTED_TO_vga_b_export,       --       vga_b.export
			vga_blank_n_export => CONNECTED_TO_vga_blank_n_export, -- vga_blank_n.export
			vga_clk_export     => CONNECTED_TO_vga_clk_export,     --     vga_clk.export
			vga_g_export       => CONNECTED_TO_vga_g_export,       --       vga_g.export
			vga_hs_export      => CONNECTED_TO_vga_hs_export,      --      vga_hs.export
			vga_r_export       => CONNECTED_TO_vga_r_export,       --       vga_r.export
			vga_sync_n_export  => CONNECTED_TO_vga_sync_n_export,  --  vga_sync_n.export
			vga_vs_export      => CONNECTED_TO_vga_vs_export       --      vga_vs.export
		);

