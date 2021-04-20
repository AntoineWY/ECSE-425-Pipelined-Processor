
vlib work

;# Compile components if any
vcom Fetch.vhd
vcom Instruction_Memory.vhd
vcom Decode.vhd
vcom Execution.vhd
vcom ALU.vhd
vcom Data_Memory.vhd
vcom WriteBack.vhd

vcom Pipeline.vhd
vcom Pipeline_tb.vhd


;# Start simulation
vsim Pipeline_tb

;# Generate a clock with 1ns period
force -deposit clk 0 0 ns, 1 0.5 ns -repeat 1 ns

proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/Pipeline_tb/clk
		add wave -position end sim:/Pipeline_tb/debug_boolean_1
		add wave -position end sim:/Pipeline_tb/debug_vector_1
		add wave -position end sim:/Pipeline_tb/debug_vector_2
		add wave -position end sim:/Pipeline_tb/debug_vector_3
				add wave -position end sim:/Pipeline_tb/debug_vector_4
		add wave -position end sim:/Pipeline_tb/reg_1
		add wave -position end sim:/Pipeline_tb/reg_2
		add wave -position end sim:/Pipeline_tb/reg_3
		add wave -position end sim:/Pipeline_tb/reg_4
		add wave -position end sim:/Pipeline_tb/reg_5
		add wave -position end sim:/Pipeline_tb/reg_6
		add wave -position end sim:/Pipeline_tb/reg_7
		add wave -position end sim:/Pipeline_tb/reg_8
		add wave -position end sim:/Pipeline_tb/reg_9
		add wave -position end sim:/Pipeline_tb/reg_10
		add wave -position end sim:/Pipeline_tb/reg_11
		add wave -position end sim:/Pipeline_tb/reg_12
		add wave -position end sim:/Pipeline_tb/reg_13
		add wave -position end sim:/Pipeline_tb/reg_14
		add wave -position end sim:/Pipeline_tb/reg_15
		add wave -position end sim:/Pipeline_tb/reg_16
		add wave -position end sim:/Pipeline_tb/reg_17
		add wave -position end sim:/Pipeline_tb/reg_18
		add wave -position end sim:/Pipeline_tb/reg_19
		add wave -position end sim:/Pipeline_tb/reg_20
		add wave -position end sim:/Pipeline_tb/reg_21
		add wave -position end sim:/Pipeline_tb/reg_22
		add wave -position end sim:/Pipeline_tb/reg_23
		add wave -position end sim:/Pipeline_tb/reg_24
		add wave -position end sim:/Pipeline_tb/reg_25
		add wave -position end sim:/Pipeline_tb/reg_26
		add wave -position end sim:/Pipeline_tb/reg_27
		add wave -position end sim:/Pipeline_tb/reg_28
		add wave -position end sim:/Pipeline_tb/reg_29
		add wave -position end sim:/Pipeline_tb/reg_30
		add wave -position end sim:/Pipeline_tb/reg_31




}

;# Add the waves
AddWaves
;# Run for 500 ns
run 100ns
