onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /wold_tan_trng_tb/clk
add wave -noupdate /wold_tan_trng_tb/rst_n
add wave -noupdate /wold_tan_trng_tb/bit_out
add wave -noupdate /wold_tan_trng_tb/u0_trng/oscillator_ring
add wave -noupdate /wold_tan_trng_tb/n_low
add wave -noupdate /wold_tan_trng_tb/n_high
add wave -noupdate -clampanalog 1 -format Analog-Step -height 50 -max 0.9 -min 0.1 /wold_tan_trng_tb/state_average
add wave -noupdate -clampanalog 1 -format Analog-Step -height 100 -min -8.0 -max 0.0 /wold_tan_trng_tb/state_deviation_log
add wave -noupdate /wold_tan_trng_tb/n_low2high
add wave -noupdate /wold_tan_trng_tb/n_high2low
add wave -noupdate /wold_tan_trng_tb/n_low2low
add wave -noupdate /wold_tan_trng_tb/n_high2high
add wave -noupdate -clampanalog 1 -format Analog-Step -height 100 -min -8.0 -max 0.0 /wold_tan_trng_tb/transition_deviation_log
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 fs} 0}
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
WaveRestoreZoom {0 us} {10 us}
