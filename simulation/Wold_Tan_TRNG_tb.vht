library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.math_real.all;

entity wold_tan_trng_tb is
  --port (
  --clock
  --) ;
end entity; -- wold_tan_trng_tb

architecture beh of wold_tan_trng_tb is
  constant CLK_PERIOD : time := 10 ns;

  signal clk   : std_logic := '0';
  signal rst_n : std_logic := '0';

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

  function realabs(val : real) return real is
  begin
    if sign(val) = -1.0 then
      return -val;
    else
      return val;
    end if;
  end function;

  signal bit_out : std_logic;
  signal n_low, n_high : natural := 0;
  signal n_low2high, n_high2low, n_low2low, n_high2high : natural := 0;
  signal state_average   : real := 0.0;
  signal state_deviation     : real := 0.0;
  signal state_deviation_log : real := 0.0;
  signal transition_deviation     : real := 0.0;
  signal transition_deviation_log : real := 0.0;
begin

  clk <= not clk after CLK_PERIOD/2;

  -- Hold reset
  rst_process : process
  begin
    wait until rising_edge(clk);
    wait for CLK_PERIOD*10;
    rst_n <= '1';
    wait;
  end process; -- rst_process

  tb_process : process
    variable last_bit_out : std_logic := bit_out;
  begin
    wait until rising_edge(rst_n);
    count_high_low : while true loop
      wait until rising_edge(clk);

      -- Low/high statistics (should be 50/50)
      if (bit_out = '1') then
        n_high <= n_high + 1;
      elsif (bit_out = '0') then
        n_low  <= n_low  + 1;
      end if;

      -- Transition statistics (should be 25/25/25/25)
      if (bit_out = '1' and last_bit_out = '1') then
        n_high2high <= n_high2high + 1;
      elsif (bit_out = '1' and last_bit_out = '0') then
        n_high2low <= n_high2low + 1;
      elsif (bit_out = '0' and last_bit_out = '0') then
        n_low2low <= n_low2low + 1;
      elsif (bit_out = '0' and last_bit_out = '1') then
        n_low2high <= n_low2high + 1;
      end if;

      last_bit_out := bit_out;
    end loop ; -- count_high_low

  end process; -- tb_process


  state_average <= real(n_high) / REALMAX(real(n_high + n_low), 1.0);
  state_deviation     <= state_average - 0.5;
  state_deviation_log <= log(realmax(realabs(state_deviation), 0.00000001));

  transition_stat_proc : process(n_high2high, n_high2low, n_low2low, n_low2high)
    variable n_high2high_r : real;
    variable n_high2low_r  : real;
    variable n_low2low_r   : real;
    variable n_low2high_r  : real;
    variable n_transitions : real;
    variable n_high2high_r_sqdiff : real;
    variable n_high2low_r_sqdiff  : real;
    variable n_low2low_r_sqdiff   : real;
    variable n_low2high_r_sqdiff  : real;
  begin
    n_high2high_r := real(n_high2high);
    n_high2low_r  := real(n_high2low);
    n_low2low_r   := real(n_low2low);
    n_low2high_r  := real(n_low2high);
    n_transitions := real(n_high + n_low);
    n_high2high_r_sqdiff := (n_high2high_r - n_transitions/4.0)**2;
    n_high2low_r_sqdiff  := (n_high2low_r - n_transitions/4.0)**2;
    n_low2low_r_sqdiff   := (n_low2low_r - n_transitions/4.0)**2;
    n_low2high_r_sqdiff  := (n_low2high_r - n_transitions/4.0)**2;
    transition_deviation     <= sqrt(n_high2high_r_sqdiff + n_high2low_r_sqdiff + n_low2low_r_sqdiff + n_low2high_r_sqdiff)/(n_transitions/4.0 + 0.00000001);
    transition_deviation_log <= log(realmax(transition_deviation, 0.00000001));
  end process ; -- transition_stat_proc

  u0_trng : Wold_Tan_TRNG
    generic map (
      G_INVERTER_DEPTH =>  3,
      G_N_RINGS        => 50
    )
    port map (
      clk_sys  => clk,
      rst_n    => rst_n,
      bit_out  => bit_out
    );
  
end architecture; -- beh