
vlib work

;# Compile components if any
vcom Fetch.vhd
vcom Instruction_Memory.vhd
vcom Decode.vhd
vcom Execution.vhd
vcom ALU.vhd
vcom Pipeline.vhd
vcom Pipeline_tb.vhd


;# Start simulation
vsim Pipeline_tb

;# Generate a clock with 1ns period
force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns

proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/Pipeline_tb/clk
    add wave -position end sim:/Pipeline_tb/stage1_fetch_out
    add wave -position end sim:/Pipeline_tb/stage2_out_data
    add wave -position end sim:/Pipeline_tb/pip_ALU_out

}

;# Add the waves
AddWaves
;# Run for 500 ns
run 100ns


