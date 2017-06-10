library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

-- Primitives
use work.altera_primitives_components.global;

entity wold_tan_trng_top is
  port (
     clk_sys       : in  std_logic;
	  rst_n         : in  std_logic;
	  bit_out       : out std_logic;
     count_high    : out std_logic_vector(9 downto 0);
     count_low     : out std_logic_vector(9 downto 0);
     count_diff_o  : out std_logic_vector(25 downto 0)
  );
end entity; -- wold_tan_trng_top

architecture rtl of wold_tan_trng_top is
  constant C_COUNTER_WIDTH : integer := 26; --  >1 sec @ 50 MHz

  component Wold_Tan_TRNG is
    generic (
      G_INVERTER_DEPTH : positive :=  3;
      G_N_RINGS        : positive := 50
    );
    port (
      clk_sys  : in  std_logic;
      rst_n    : in  std_logic;
      bit_out  : out std_logic
    );
  end component; -- Wold_Tan_TRNG
 
  component pll0 is
    port (
      pll_clk_in_clk  : in  std_logic := '0';
      pll_rst_reset   : in  std_logic := '0';
      pll_clk_out_clk : out std_logic
    );
  end component pll0;

  signal clk_sys_g     : std_logic;
  signal bit_out_i     : std_logic;
  signal count_diff    : signed(C_COUNTER_WIDTH-1 downto 0);
  signal n_low, n_high : unsigned(C_COUNTER_WIDTH-1 downto 0);
  constant count_max   : unsigned(C_COUNTER_WIDTH-1 downto 0) := (others => '1');
  
  signal rst_n_i : std_logic;
  signal rst_n_d : std_logic_vector(1 downto 0);
begin

  bit_out <= bit_out_i;
  count_high <= std_logic_vector(n_high(9 downto 0));
  count_low  <= std_logic_vector(n_low(9 downto 0));
  rst_n_i <= rst_n_d(1);
  count_diff_o <= std_logic_vector(count_diff);
  
  -- Create a global clock for better timing closure
  u0_global : global
    port map (
	   a_in  => clk_sys,
		a_out => clk_sys_g
	 );
	 
  input_reg_proc : process (clk_sys_g)
  begin
    if rising_edge(clk_sys_g) then
	   rst_n_d <= rst_n_d(0) & rst_n;
	 end if;
  end process; -- input_reg_proc

  count_proc : process (clk_sys_g, rst_n_i)
    variable diff_tmp : signed(C_COUNTER_WIDTH-1 downto 0);
  begin
    if rst_n_i = '0' then
      n_high     <= (others => '0');
      n_low      <= (others => '0');
		count_diff <= (others => '0');
	 elsif rising_edge(clk_sys_g) then
		
      count_diff <= count_diff;
	   -- Count the number of high/low. Reset when either overflows
      if (bit_out_i = '1') then
		  n_high <= n_high + 1;
		  if (n_high = count_max) then
		    n_low <= count_max + 1;
	       diff_tmp := signed(n_high) - signed(n_low);
			 count_diff <= count_diff + diff_tmp;
		  end if;
      elsif (bit_out_i = '0') then
		  n_low <= n_low + 1;
		  if (n_low = count_max) then
		    n_high <= count_max + 1;
	       diff_tmp := signed(n_high) - signed(n_low);
			 count_diff <= count_diff + diff_tmp;
		  end if;
      end if;
	 end if;
  end process; -- count_proc

  -- The true number generator
  u0_trng : Wold_Tan_TRNG
    generic map (
      G_INVERTER_DEPTH =>   3,
      G_N_RINGS        =>  50
    )
    port map (
      clk_sys  => clk_sys_g,
      rst_n    => rst_n_i,
      bit_out  => bit_out_i
    );

  -- PLL for upping the frequency
  u0_pll300 : pll0
    port map (
      pll_clk_in_clk  => clk_sys_g,
      pll_rst_reset   => not rst_n_i,
      pll_clk_out_clk => open
    );
  
end architecture; -- rtl