onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /wold_tan_trng_tb/clk
add wave -noupdate /wold_tan_trng_tb/rst_n
add wave -noupdate /wold_tan_trng_tb/bit_out
add wave -noupdate /wold_tan_trng_tb/u0_trng/oscillator_ring
add wave -noupdate /wold_tan_trng_tb/n_low
add wave -noupdate /wold_tan_trng_tb/n_high
add wave -noupdate -clampanalog 1 -format Analog-Step -height 50 -max 0.90000000000000002 -min 0.10000000000000001 /wold_tan_trng_tb/average
add wave -noupdate -clampanalog 1 -format Analog-Step -height 100 -min -8.0 /wold_tan_trng_tb/deviation
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1015000000 fs} 0}
quietly wave cursor active 1
configure wave -namecolwidth 106
configure wave -valuecolwidth 75
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 10000
configure wave -gridperiod 20000
configure wave -griddelta 50
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 fs} {127260 ns}
