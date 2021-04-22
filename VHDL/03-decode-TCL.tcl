
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
		add wave -position end sim:/Decode_tb/write_data
		add wave -position end sim:/Decode_tb/write_register
		add wave -position end sim:/Decode_tb/HI_data
		add wave -position end sim:/Decode_tb/LO_data

		add wave -position end sim:/Decode_tb/pc_update

 		add wave -position end sim:/Decode_tb/r_data_1
    add wave -position end sim:/Decode_tb/r_data_2

    add wave -position end sim:/Decode_tb/ALU_op

 		add wave -position end sim:/Decode_tb/IDEX_WB
    add wave -position end sim:/Decode_tb/IDEX_M
    add wave -position end sim:/Decode_tb/IDEX_EX
		add wave -position end sim:/Decode_tb/SIGN_EXTEND

		add wave -position end sim:/Decode_tb/IDEXRs_forwarding
		add wave -position end sim:/Decode_tb/IDEXRt_forwarding
 		add wave -position end sim:/Decode_tb/IDEX_WB_register

		add wave -position end sim:/Decode_tb/stall
		add wave -position end sim:/Decode_tb/hazard
		add wave -position end sim:/Decode_tb/pc_update_to_ex
		add wave -position end sim:/Decode_tb/reg_1
		add wave -position end sim:/Decode_tb/reg_2
		add wave -position end sim:/Decode_tb/reg_3
		add wave -position end sim:/Decode_tb/reg_4
		add wave -position end sim:/Decode_tb/reg_5
		add wave -position end sim:/Decode_tb/reg_6
		add wave -position end sim:/Decode_tb/reg_7
		add wave -position end sim:/Decode_tb/reg_8
		add wave -position end sim:/Decode_tb/reg_9
		add wave -position end sim:/Decode_tb/reg_10
		add wave -position end sim:/Decode_tb/reg_11
		add wave -position end sim:/Decode_tb/reg_12
		add wave -position end sim:/Decode_tb/reg_13
		add wave -position end sim:/Decode_tb/reg_14
		add wave -position end sim:/Decode_tb/reg_15
		add wave -position end sim:/Decode_tb/reg_16
		add wave -position end sim:/Decode_tb/reg_17
		add wave -position end sim:/Decode_tb/reg_18
		add wave -position end sim:/Decode_tb/reg_19
		add wave -position end sim:/Decode_tb/reg_20
		add wave -position end sim:/Decode_tb/reg_21
		add wave -position end sim:/Decode_tb/reg_22
		add wave -position end sim:/Decode_tb/reg_23
		add wave -position end sim:/Decode_tb/reg_24
		add wave -position end sim:/Decode_tb/reg_25
		add wave -position end sim:/Decode_tb/reg_26
		add wave -position end sim:/Decode_tb/reg_27
		add wave -position end sim:/Decode_tb/reg_28
		add wave -position end sim:/Decode_tb/reg_29
		add wave -position end sim:/Decode_tb/reg_30
		add wave -position end sim:/Decode_tb/reg_31






}

;# Add the waves
AddWaves
;# Run for 500 ns
run 500ns
