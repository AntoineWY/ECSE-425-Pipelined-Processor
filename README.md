# 32-bit Pipelined Processor 
## Introduction

Completed as the course project for ECSE-425 (Computer Architecture) at McGill University, this project aims to implement a standard 5-stage pipelined 32-bit MIPS processor in VHDL. A
pipelined processor stores control signals and intermediate results associated with each executing instruction in pipeline registers between stages. 

## System Structure

The
processor stages include instruction fetch (IF), instruction
decode (ID), instruction execution (EX), memory access
(MEM) and writeback (WB).

![Pipelined Processor](https://github.com/AntoineWY/ECSE-425-Pipelined-Processor/blob/main/Diagrams/pipelinedCPU.PNG)

The inputs of the CPU are the machine codes compiled from
the provided assembler, which are 32-bit binary codes. In this
project it is in the form of the program.txt file, acting as the
instruction memory. Therefore, the main task of the **fetch** stage is
to fetch the instructions and send them one by one to the next
stage with each clock cycle. Another important function of the
fetch is to carry the program counter register (PC), as an
indication of the instruction location. Normally the PC is
incremented by 4 with each instruction, and is also able to
change accordingly with the jump and branch instructions.

The instruction **decode** stage is responsible for identifying
the input and output registers, immediate values, and memory
addresses according to the MIPS instruction Green Sheet.
There are three kinds of instructions, and each of them has a
different format for the 32-bit binary code (R type, J type and I
type), and the decode stage would decode the input instruction
accordingly. Also, hazard detection and part of the forwarding
function will be implemented in this stage.

The **execution** stage is where the instructions are executed
with the arithmetic logic unit (ALU). In this project, the CPU
is supposed to support 27 instructions with the types of
arithmetic, logical, transfer, shift, memory, and control-flow.
Depending on the forwarding control unit in the pipeline, the
ALU inputs could be the decoded data, memory stage output,
or the writeback stage output, as shown in Figure 3.

The **data memory** stage is responsible for memory accessing,
which is mainly required by the instruction of load and store.
The data memory of the CPU is 32768 bits as defined by the
project description. Also, the same as the instruction memory
and register bank, the data is in 32 bits word. Therefore, the
data memory is configured to be a text file named memory.txt,
and has 32768/4 = 8192 lines, one for each 32 bit word.

The **write back** stage is the last one in the 5-stage pipeline,
and its functionality is mainly sending the signals to the
decode stage to update the registers if needed. For the data
memory and write back stage, as mentioned in the execution
introduction, forwarding is supported by these two stages.

Finally, these five stages will be pipelined together using a
separate file, by connecting the corresponding input and
output signals of each stage. Also, part of the forwarding
function will be implemented in this file. Furthermore, there
will be several debug output signals and register signals added
to the pipelined CPU, so that we can inspect internal signals
between the connections of different stages. Diagrams below illustrates how different stages are connected.

Pipelined Processor Datapath illustration:

![Pipelined Processor Datapath](https://github.com/AntoineWY/ECSE-425-Pipelined-Processor/blob/main/Diagrams/pipelinedDatapath.PNG)

Hazard detection and forwarding illustration:

![Hazard detection and forwarding](https://github.com/AntoineWY/ECSE-425-Pipelined-Processor/blob/main/Diagrams/PipelinedDPwithhazardandforward.PNG)


## Usage
For this project we use [ModelSim](https://fpgasoftware.intel.com/?product=modelsim_ae#tabs-2) for testings and verification. We included a set of scripts running both the entire pipeline CPU and also individual stages such as fetching instruction and decode. Please check all **.tcl** files in directory "VHDL". Please make sure all machine codes, assembled from assembly are ready in directory "Test_Programs". 

You can use the existing code. Also, you can generate your own testbench by writing your own assembly code and assemble it into machine codes using the java program provided in folder "Assembler".

Once everything is ready, run one of the **.tcl** file by typing the command below in ModelSim CLI.



```bash
# running the entire pipeline processor
source pipeline-TCL.tcl
```

Below shows the content of the **.tcl** file, defining parameters like which VHDL components to simulate, which ports are displayed as waves and how long will the simulation run.  
```bash
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
		add wave -position end sim:/Pipeline_tb/fetch_instruction
		add wave -position end sim:/Pipeline_tb/decode_instruction_in
		add wave -position end sim:/Pipeline_tb/memory_write_data
		add wave -position end sim:/Pipeline_tb/register_write_data
		add wave -position end sim:/Pipeline_tb/execution_out
		add wave -position end sim:/Pipeline_tb/forwarding_signal_mux_1
		add wave -position end sim:/Pipeline_tb/forwarding_signal_mux_2
		add wave -position end sim:/Pipeline_tb/stall_signal
		add wave -position end sim:/Pipeline_tb/branch_taken_signal
		add wave -position end sim:/Pipeline_tb/memory_write_signal
		add wave -position end sim:/Pipeline_tb/register_wb_signal
		add wave -position end sim:/Pipeline_tb/execution_flag
		add wave -position end sim:/Pipeline_tb/reg_XX
}

;# Add the waves
AddWaves
;# Run for 10000 ns
run 10000ns
```

## Result
[Benchmark 2](https://github.com/AntoineWY/ECSE-425-Pipelined-Processor/tree/main/Test_Programs) is a fibonacci series generator which contains a
simple loop doing 4 iterations of fibonacci calculation. Figure below captured below shows that after the execution of the
program registers are updated with the correct value, with R2
being the actual fibonacci number in every iteration. 

![result1](https://github.com/AntoineWY/ECSE-425-Pipelined-Processor/blob/main/Diagrams/resultBenchmark2-registervalue.PNG)

Besides seeing the correct output, we also analyzed the
critical part of the code and were curious to find out how the
wave diagram revealed the behavior around those instructions.
One example in benchmark 2 is the region near the end of the
loop, where the arithmetics of address calculation (multiply
and add) are followed by a store and a “BNE”. After
examining the wave below, we conclude that the behavior of
our processor matches the theoretical flow, with correct number of stalls added into the pipeline for the program to determine the branch target. Please check the diagram below at the yellow line.


![result2](https://github.com/AntoineWY/ECSE-425-Pipelined-Processor/blob/main/Diagrams/resultbenchmark2-branchbehavior.PNG)

## Future
The next stage of this pipelined processor is optimization on performance. Several ideas could be applied to this existing implementation such as cache and branch prediction. A massively modified structure with the reschedule of the instructions, like the Tomasulo algorithm, could also be an option,  but definitely requiring a bigger time budget.

There has already been a working **cache** implementation. Please check [here]().

## License
Course content by [Prof.A Emad](http://www.ece.mcgill.ca/~aemad2/) at McGill University  
