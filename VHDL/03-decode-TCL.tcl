
vlib work

;# Compile components if any
vcom Decode.vhd
vcom Decode_tb.vhd

;# Start simulation
vsim Decode_tb

;# Generate a clock with 1ns period
force -deposit clk 0 0 ns, 1 5 ns -repeat 10 ns

proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/Decode_tb/clk
    add wave -position end sim:/Decode_tb/instruction
 add wave -position end sim:/Decode_tb/r_data_1
    add wave -position end sim:/Decode_tb/r_data_2
    add wave -position end sim:/Decode_tb/ALU_op
 add wave -position end sim:/Decode_tb/IDEX_WB
    add wave -position end sim:/Decode_tb/IDEX_M
    add wave -position end sim:/Decode_tb/IDEX_EX
 add wave -position end sim:/Decode_tb/IDEX_WB_register




}

;# Add the waves
AddWaves
;# Run for 500 ns
run 500ns


