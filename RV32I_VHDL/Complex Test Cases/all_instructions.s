/*
 * Standalone assembly language program for NYU-6463-RV32I processor
 * The label 'reset handler' will be called upon startup.
 * 
 * 
 * Testing scheme is as follows 
 * --> 1 assembly code block per instruction (37 blocks of assembly)
 *
 */
.global reset_handler
.type reset_handler,@function

reset_handler:

LUI   x1, 0x00100
ADDI  x1, x1, 0x14 

LUI   x2, 0x01000
ADDI  x6, x0, 0x00004
JALR  x7, 18(x2)
ADD   x6, x0, x0
SW    x6, 0(x1)

LUI  x2, 0x10000     
ADDI x2, x2, 0x7FF              
Sw   x2, 0(x1)                   
 
ADDI  x6, x0, 3
AUIPC x6, 0x00001
Sw    x6, 0(x1)

LUI  x4, 0x80000
ADDI x4, x4, 1

ADD  x2, x0, x0
LUI  x2, 0x87654
ADDI x2, x2, 0x381
SW   x2, 0(x1)
LB   x3, 0(x1)
SB   x3, 0(x4)
LW   x3, 0(x4)	
SW   x3, 0(x1)

ADD  x2, x0, x0
ADD  x3, x0, x0
LUI  x2, 0x87658
ADDI x2, x2, 0x321
SW   x2, 0(x1)
LH   x3, 0(x1)
SH   x3, 0(x4)
LW   x3, 0(x4)
SW   x3, 0(x1)

ADD  x2, x0, x0
ADD  x3, x0, x0
LUI  x2, 0x87654
ADDI x2, x2, 0x321
SW   x2, 0(x1)
LW   x3, 0(x1)
SW   x3, 0(x1)

ADD  x2, x0, x0
ADD  x3, x0, x0
LUI  x2, 0x87654
ADDI x2, x2, 0x381
SW   x2, 0(x1)
LBU  x3, 0(x1)
SW   x3, 0(x1)

ADD  x2, x0, x0
ADD  x3, x0, x0
LUI  x2, 0x87658
ADDI x2, x2, 0x321
SW   x2, 0(x1)
LHU  x3, 0(x1)
SW   x3, 0(x1)

addi x6, x0, -3
slti x7, x6, -2
Sw   x7, 0(x1)

addi  x6, x0, 1
sltiu x7, x6, -2
Sw    x7, 0(x1)

addi x6, x0, -3
addi x7, x0, -2
slt x7, x6, x7
Sw   x7, 0(x1)

addi x6, x0, 1
addi x7, x0, -2
sltu x7, x6, x7
Sw   x7, 0(x1)

addi x6, x0, 1
xori x7, x6, -2
Sw   x7, 0(x1)

addi x6, x0, 1
ori x7, x6, -2
Sw   x7, 0(x1)

addi x6, x0, 1
andi x7, x6, -2
Sw   x7, 0(x1)

addi x6, x0, 4
slli x7, x6, 1
Sw   x7, 0(x1)

addi x6, x0, 8
srli x7, x6, 1
Sw   x7, 0(x1)

addi x6, x0, -8
srai x7, x6, 1
Sw   x7, 0(x1)

addi x6, x0, -8
addi x7, x0, 1
add  x7, x7, x6
Sw   x7, 0(x1)

addi x6, x0, -8
addi x7, x0, 1
sub  x7, x7, x6
Sw   x7, 0(x1)

addi x6, x0, 4
addi x7, x0, 1
sll  x7, x6, x7
Sw   x7, 0(x1)

addi x6, x0, 8
addi x7, x0, 1
srl  x7, x6, x7
Sw   x7, 0(x1)

addi x6, x0, -8
addi x7, x0, 1
sra  x7, x6, x7
Sw   x7, 0(x1)

addi x6, x0, 1
addi x7, x0, -2
xor  x7, x6, x7
Sw   x7, 0(x1)

addi x6, x0, 1
addi x7, x0, -2
or   x7, x6, x7
Sw   x7, 0(x1)

addi x6, x0, 1
addi x7, x0, -2
and  x7, x6, x7
Sw   x7, 0(x1)

ADDI  x5, x0, -4
ADDI  x6, x0, -4
BEQ   x5, x6, SKIP
ADD   x5, x5, x6
SKIP: ADDI x5, x5, 8
SW x5, 0(x1)

ADDI  x5, x0, -4
ADDI  x6, x0, 4
BNE   x5, x6, jump
ADD   x5, x5, x6
jump: ADDI x5, x5, 4
SW x5, 0(x1)

ADDI  x5, x0, -4
ADDI  x6, x0, 5
BLT   x5, x6, jump2
ADD   x5, x5, x6
jump2: ADDI x5, x5, 8
SW x5, 0(x1)

ADDI  x5, x0, 5
ADDI  x6, x0, -4
BGE   x5, x6, jump3
ADD   x5, x5, x6
jump3: ADDI x5, x5, 4
SW x5, 0(x1)

ADDI  x5, x0, 4
ADDI  x6, x0, 5
BLTU  x5, x6, jump4
ADD   x5, x5, x6
jump4: ADDI x5, x5, 8
SW x5, 0(x1)

ADDI  x5, x0, 5
ADDI  x6, x0, 4
BGEU  x5, x6, jump5
ADD   x5, x5, x6
jump5: ADDI x5, x5, 4
Sw   x5, 0(x1)

ADDI x6, x0, 0x00004
JAL  x2, jump0
ADD  x6, x0, x0
jump0: SW x6, 0(x1)    





