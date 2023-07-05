---------------------------------------------------------------------------------
      ECE-GY 6463 - RISCV32I Implementation 
      Fall 2021 
---------------------------------------------------------------------------------

Group #12 Team Members: 
Md Raz 				- N17762874 - mr4425@nyu.edu
Siddharth Kandpal 	- N10799721 - sk8944@nyu.edu   
Vivek Khithani 		- N16661513 - vk2279@nyu.edu

---------------------------------------------------------------------------------

Loading to the FPGA / Simulating the Processor: 

The instruction memory module contains two lines which show the following signals:

	signal instr_mem : ARR_32x511  := instr_rom_readfile("MAIN.MEM"); 
	constant instr_mem : ARR_32x511 := (  X"001000b7", ....             

	When running a simulation, comment out the second "constant" instr_mem signal so that the instruction memeory is loaded from the main.mem file within the sources folder. Then, run the simulation as normal. 
	
	When loading to FPGA, comment out the first signal and paste the compiled assembly hex data into the array so that it can be loaded onto the FPGA via the bitstream.
	
	To load onto the FPGA, generate the bitstream file. It will be produced within the ..\NYU_RV32I\NYU_RV32I\NYU_RV32I.runs\impl_1 folder, and it will be called RISCV_CORE.bit. Load this bitstream file onto your FPGA using the supplied program from the FPGA manufacturer. In our case, the program we used to load the bitstream was called Alchitry Loader. 
	
	The FPGA we used to test is the following: 
	Alchitry Au FPGA Development Board ( Xilinx Artix 7 XC7A35T-1C )
	https://www.sparkfun.com/products/16527 

---------------------------------------------------------------------------------
Complex Test Cases: 
Located in ...\NYU_RV32I\Complex Test Cases

1.	all_instructions.mem
	all_instructions.s	

All instructions test case provides assembly and compiles hex for testing each and every instruction provided in the instruction set. The CORE_TEST_VECS.MEM provides the test vectore for which this file was tested with. 

2.	led_sweep.mem
	led_sweep.s

led_sweep test case uses switch inputs and led outputs on the FPGA to sweep the LEDs across the FPGA. The Switch input is used to switch the direction of the sweep. The assembly uses multiple jumps, branches, counters and shifts to shift the location of the led, and count the number of cycles before shifting. The assembly also uses branches to check which direction to shift in. 

3.	sum_of_powers.mem
	sum_of_powers.s
	
The program determines the odd numbers between an inputted range by performing division (repeated subtraction). Based on another power input, it will multiply (repeated add) all determined odd numbers the number of times specified. The final values is then summed and stored into the destination register.

---------------------------------------------------------------------------------
Project Contents:
	
	Source Files:
	Located in ...\NYU_RV32I\NYU_RV32I.srcs\sources_1\new
		RISCV_CORE.vhd		-- Core top module
		RISCV_CTRL_UNIT.vhd -- Control Unit module
		RISCV_PC.vhd		-- Program Counter module
		RISCV_INSTR_MEM.vhd -- Instruction memory module
		RISCV_REG.vhd		-- Register file module
		RISCV_DATA_MEM.vhd	-- Data memory module
		RISCV_ALU.vhd		-- ALU module
		RISCV_BR_CMPR.vhd   -- Branch Comparitor Module
		RISCV_PKG.vhd		-- Package file for array definitions
		MAIN.MEM			-- Mem file for loading compiled assembly
		
	Test Files:
	Located in ...\NYU_RV32I\NYU_RV32I.srcs\sim_1\new
		Test Bench Files:
			RISCV_CORE_TB.vhd  		-- Top module Test bench
			RISCV_ALU_TB.vhd		-- Alu Test Bench
			RISCV_BR_CMPR_TB.vhd	-- Branch Comparitor Test Bench
			RISCV_CTRL_UNIT_TB.vhd  -- Control Unit Test bench 
			RISCV_DATA_MEM_TB.vhd	-- Data memory Test Bench
			RISCV_PC_TB.vhd			-- Program Counter Test bench
			RISCV_REG_TB.vhd		-- Register File Test bench
			
		Test Vector Files:
			ALU_TEST_VECS.mem		
			BR_CMPR_TEST_VECS.mem
			CORE_TEST_VECS.mem
			CTRL_UNIT_TEST_VECS_NO_BRANCH.mem
			CTRL_UNIT_TEST_VECS_WITH_BRANCH.mem
			DATA_MEM_TEST_VECS.mem
			INSTR_MEM_TB.vhd
			INSTR_MEM_TEST_VECS.mem
			PC_TEST_VECS.mem
			REG_TEST_VECS.mem
	
	Constraints File: 
	Located in ...\NYU_RV32I\NYU_RV32I.srcs\constrs_1\new
		RISCV_CORE_ALCHITRY_AU.xdc  -- Constraints file for setting input clock speed, led connections, and switch connections.

---------------------------------------------------------------------------------