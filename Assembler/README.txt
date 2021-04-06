This project includes a MIPS assembler written in Java which produces binary instructions from an .asm input file.
The assembler handles multiple error cases and exceptions, and prints relevant error messages to command line if errors occur.


In order to create a binary output from a given .asm file, follow these steps:
1. Compile the assembler:
	javac Driver.java
2. Run the compiled Java program using the following syntax:
	java Driver filename
	Note: filename must be a valid .asm file
3. Locate the resulting binary instruction file:
	The assembled file will be named program.txt, 
	which will be located in the same directory as the input target.
