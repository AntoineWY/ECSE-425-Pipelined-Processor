Notes:

1. Please make sure the following VHD files exist, they are the core component of the processor. If there is file missing please contact us!

Required files for the processor architecture:
ALU.vhd
Data_Memory.vhd
Decode.vhd
Execution.vhd
Fetch.vhd
Instruction_Memory.vhd
Pipeline.vhd
Writeback.vhd

Required files for the overall testing:
pipeline_tb.vhd
pipeline_TCL.tcl

2. Below are unnecessary files. They are unit tests or partial integration test we implemented for each components.
Unit test files and scripts:
Data_Memory_tb.vhd
Decode_tb.vhd
Execution_tb.vhd
Fetch_tb.vhd
Instruction_Memory_tb.vhd
01-instrmem-TCL.tcl     
02-fetchinstr-TCL.tcl   
03-decode-TCL.tcl       
04-execution-TCL.tcl  
05-data_men.tcl  

3. Before running any programs, please copy the generated binary code for instructions into file "program.txt".


4. If you want to run a entire program and see all registers and major intermediate outputs, please use the "pipeline-TCL" script. Use command "source pipeline-TCL" in modelSim command transcript will run the code.

5. For result of the test of each components, use TCLs 01-05 and use command "source" to run in modelSim.