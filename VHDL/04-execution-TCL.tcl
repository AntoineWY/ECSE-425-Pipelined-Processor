
vlib work

;# Compile components if any
vcom Execution.vhd
vcom ALU.vhd
vcom Execution_tb.vhd

;# Start simulation
vsim Execution_tb

;# Generate a clock with 1ns period
force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns

proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/Execution_tb/clk
    add wave -position end sim:/Execution_tb/ALU_op
    add wave -position end sim:/Execution_tb/readdata1
    add wave -position end sim:/Execution_tb/readdata2
    add wave -position end sim:/Execution_tb/ALU_out
    add wave -position end sim:/Execution_tb/adder_out
    add wave -position end sim:/Execution_tb/branch_taken
    add wave -position end sim:/Execution_tb/hi
    add wave -position end sim:/Execution_tb/lo
}

;# Add the waves
AddWaves
;# Run for 500 ns
run 100ns


