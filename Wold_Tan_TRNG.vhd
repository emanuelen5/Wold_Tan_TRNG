library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;

-- A True Random Number Generator based on
-- Wold and Tan, "Analysis and Enhancement of Random Number Generator in FPGA Based on Oscillator Rings," International Journal of Reconfigurable Computing, Volume 2009, doi: http://dx.doi.org/10.1155/2009/501672.
entity Wold_Tan_TRNG is
  generic (
    -- The number of inverters in each oscillator loop. A lower number gives a higher average frequency since the signal has to propagate a shorter distance for each loop, but lower variance since the inverters are more likely to be located in the same slice)
    G_INVERTER_DEPTH : positive :=  3;
    -- The number of oscillator loops in parallel (increases randomness)
    G_N_RINGS        : positive := 50
  );
  port (
    clk_sys  : in  std_logic;
    rst_n    : in  std_logic;
    bit_out  : out std_logic
  );
end entity; -- Wold_Tan_TRNG

architecture rtl of Wold_Tan_TRNG is

  constant C_PROP_DELAY : time := 10 ps;

  type oscillator_ring_t is record
    ring    : std_logic_vector(G_INVERTER_DEPTH-1 downto 0);
    reg_out : std_logic;
  end record;

  type oscillator_ring_ary_t is array (natural range <>) of oscillator_ring_t;
  signal oscillator_ring : oscillator_ring_ary_t(G_N_RINGS-1 downto 0);
  signal bit_out_i, xor_sample : std_logic;
begin
  assert (G_INVERTER_DEPTH mod 2 = 1) report "There must be an odd number of inverters in the oscillator rings to become astable." severity failure;

  -- Mapping internal representations of top signals
  bit_out <= bit_out_i;

  -- Generate oscillator rings in parallel
  gen_oscillator_rings : for i in 0 to G_N_RINGS-1 generate

    -- Connect the oscillator rings in a loop (moving downward). The output (bottom) is also connected to the reset.
    oscillator_ring(i).ring(0) <= not oscillator_ring(i).ring(G_INVERTER_DEPTH-1) when rst_n = '1' else '0' after C_PROP_DELAY;
    --oscillator_ring(i).ring(0) <= '1' when rst_n = '1' else '0' after C_PROP_DELAY;
    gen_oscillator_ring : for j in 1 to G_INVERTER_DEPTH-1 generate
      oscillator_ring(i).ring(j) <= not oscillator_ring(i).ring((j+1) mod G_INVERTER_DEPTH) after C_PROP_DELAY;
    end generate; -- gen_oscillator_ring
  end generate; -- gen_oscillator_rings

  test_proc : process(rst_n)
  begin
    if rising_edge(rst_n) then
      test_loop : for i in 1 to G_INVERTER_DEPTH-1 loop
        report "Connecting oscillator [" & integer'image(i) & " <= " & integer'image((i+1) mod G_INVERTER_DEPTH) & "]" severity note;
      end loop ; -- test_loop
    end if;
  end process ; -- test_proc

  -- Sample all of the rings and XOR the result
  proc_sample_rings : process(clk_sys, rst_n)
    variable xor_result_v : std_logic;
  begin
    if (rst_n = '0') then
      bit_out_i  <= '0';
      xor_sample <= '0';

      -- Reset all of the registered outputs from the oscillator rings
      rst_regs : for i in 0 to G_N_RINGS-1 loop
        oscillator_ring(i).reg_out <= '0';
      end loop; -- rst_regs
    elsif rising_edge(clk_sys) then

      -- Sample the oscillator rings
      sample_oscillator_rings : for i in 0 to G_N_RINGS-1 loop
        oscillator_ring(i).reg_out <= oscillator_ring(i).ring(0);
      end loop ; -- sample_oscillator_rings

      -- XOR the registered outputs of the oscillator rings
      xor_result_v := '0';
      xor_oscillator_rings : for i in 0 to G_N_RINGS-1 loop
        xor_result_v := xor_result_v xor oscillator_ring(i).reg_out;
      end loop ; -- xor_oscillator_rings
      xor_sample <= xor_result_v;
      bit_out_i <= xor_sample; -- Double register the sampled value
    end if;
  end process; -- proc_sample_rings

end architecture; -- rtl