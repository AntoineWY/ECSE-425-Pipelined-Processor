
vlib work

;# Compile components if any
vcom Instruction_Memory.vhd
vcom Instruction_Memory_tb.vhd

;# Start simulation
vsim Instruction_Memory_tb

;# Generate a clock with 1ns period
force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns

proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/Fetch_tb/clk
    add wave -position end sim:/Fetch_tb/pc_update
 add wave -position end sim:/Fetch_tb/readdata



}

;# Add the waves
AddWaves
;# Run for 500 ns
run 500ns


