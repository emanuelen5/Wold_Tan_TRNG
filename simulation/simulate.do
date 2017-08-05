-- 
quit -sim
vlib work
vdel -all
vlib work

vcom -work work -check_synthesis ../Wold_Tan_TRNG.vhd
vcom -work work Wold_Tan_TRNG_tb.vht

-- Start simulation
vsim -novopt -t fs Wold_Tan_TRNG_tb
log -r /*

-- Remove ugly starter warnings
set StdArithNoWarnings 1
run 0 ns
set StdArithNoWarnings 0

-- Can skip the test bench and force the signals if no statistics are required
--force -deposit /rst_n 0 0, 1 {45 ns}
--force -deposit /clk 1 0, 0 {10 ns} -repeat 20

view wave
do wave.do
run 10000 ns
