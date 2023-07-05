/*
 * Standalone assembly language program for NYU-6463-RV32I processor
 * The label 'reset handler' will be called upon startup.
 * 
 * 
 * Testing scheme is as follows 
 * --> 1 assembly code block per instruction (37 blocks of assembly)
 * --> 32 random loads and stores to register file
 * --> 100 random loads to and from 100 random data memory locations 
 *
 */
.global reset_handler
.type reset_handler,@function

reset_handler:
addi x5, x0, 2         		//lower number to be passed to x5
addi x6, x0, 6         		//higher number to be passed to x6
addi x3, x0, 5       		// power of the number 
addi x7, x0, 2       		//sum
add x29, x29, x0
add x28, x0, x5
beq x28, x0, zero  
check_odd:          
sub x28, x28, x7
bge x28, x7, check_odd                 
zero:
bne x28, x0, no_incr                   //check if lower no is odd or not
addi x5, x5, 1                               //if not increment by 1 and make it odd
jal x0, skip
no_incr:                
addi x5, x5, 2                              //if odd then increment by 2  
skip:
add x28, x0, x6
check_odd2:          
sub x28, x28, x7
bge x28, x7, check_odd2
bne x28, x0, no_incr2                 //check if higher no is odd or not
addi x6, x6, 1                               //if not increment by 1 and make it odd
no_incr2:
bge x5, x6, NOP
bne x3, x0, break1
addi x4, x0, 1
jal x0, break2
break1:
add x4, x0, x5                  
break2:
addi x11, x0, 1              
addi x12, x0, 1
beq x3, x12, pw_end                
power:
bge x11, x3, pw_end
add x9, x0, x0
add x13, x0, x0
sum:    
bge x9, x5, end
add x13, x13, x4
addi x9, x9, 1
jal x0, sum
end:      
add x4, x0, x13
addi x11, x11, 1
jal x0, power
pw_end:  
add x29, x29, x4
addi x5, x5, 2
jal  x0, no_incr2
NOP:
LUI x17, 0x00100
ADDI x17, x17, 0x14
SW x29, 0(x17)
Ecall






