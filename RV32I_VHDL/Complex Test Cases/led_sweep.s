/*
 * Standalone assembly language program for NYU-6463-RV32I processor
 * The label 'reset handler' will be called upon startup.
 * 
 * 
 * Testing scheme is as follows 
 * --> 1 assembly code block per instruction (37 blocks of assembly)
 * --> 32 random loads and stores to register file
 *
 */
.global reset_handler
.type reset_handler,@function

reset_handler:
		LUI   x1, 0x00100
		ADDI  x2, x1, 0x10  // Switch Input register 
		ADDI  x1, x1, 0x14 	// LED Output Register
		ADDI  x3, x0, 1  	// Increment amount register, =1
		LUI	  x9, 0x00020	// Final Value register = 0x20000
		ADDI  x8, x0, 0		// Count register
RESET:	LUI	  x10, 0x80000  // init Shift register, right
		ADDI  x7, x0, 1		// init Shift register, left
		// Find switch state
		LW	  x5, 0(x2)		// if 0, SLL, if 1, SRL
		BEQ   x5, x0, LINIT // Branch based on switch
		BEQ	  x5, x3, RINIT	

LINIT:  SW    x7, 0(x1)		// Load LED w/ LShift val
		JAL   x4, INCR		// Start Counting
RINIT:  SW    x10, 0(x1)	// Load LED w/ RShift val
		JAL   x4, INCR		// Start Counting

SLFT:	SLL   x7, x7, x3	// LEFT SHIFT * 1
		ADDI  x8, x0, 0		// reset count
		BEQ   x7, x10, RESET// Reset if reached end of array
		JAL   x4, LINIT     // Otherwise start next count
SRHT:	SRL   x10, x10, x3	// RIGHT SHIFT * 1
		ADDI  x8, x0, 0		// reset count
		BEQ	  x10, x7, RESET// Reset if reached end of array	
		JAL   x4, RINIT		// Otherwise start next count

INCR:   ADD   x8, x8, x3	// Increment counter
		BNE   x8, x9, INCR	// Branch if not final value
		BEQ   x8, x9, SHIFT	// Shift if final value is reached

SHIFT	BEQ   x5, x0, SLFT  // CHeck of left or right Shift
		BEQ	  x5, x3, SRHT		







	 




                

