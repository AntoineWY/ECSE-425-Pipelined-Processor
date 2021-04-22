vlib work

;# Compile components if any
vcom Data_Memory.vhd
vcom data_memory_tb.vhd


;# Start simulation
vsim data_memory_tb

;# Generate a clock with 1ns period
force -deposit clock 0 0 ns, 1 0.5 ns -repeat 1 ns

proc AddWaves {} {
	;#Add waves we're interested in to the Wave window
    add wave -position end sim:/data_memory_tb/clock
    add wave -position end sim:/data_memory_tb/Data_Mem_out




}

;# Add the waves
AddWaves
;# Run for 500 ns
run 500ns
