---------------------------------------------------------------------------------
--      ECE-GY 6463 - RISCV32I Implementation - Arithmetic Logic Unit 
--      Fall 2021 
--
--      Md Raz          --  Siddharth Kandpal   --  Vivek Khithani
--      N17762874       --  N10799721           --  N16661513 
--      mr4425@nyu.edu  --  sk8944@nyu.edu      --  vk2279@nyu.edu
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.RISCV_PKG.ALL;

entity RISCV_ALU is
    Port (               
            operation       : in op_type;
            i_operand_1     : in STD_LOGIC_VECTOR (31 DOWNTO 0);
            i_operand_2     : in STD_LOGIC_VECTOR (31 DOWNTO 0);
            o_output        : out STD_LOGIC_VECTOR(31 DOWNTO 0)                                            
           );  
end RISCV_ALU;

architecture Behavioral of RISCV_ALU is
    
    -- Temp signals
    signal unsigned_greater :std_logic;
    signal signed_greater :std_logic;
    signal optrn_tmp: op_type;
    
begin
       
    -- when PROGRAM COUNTER values are used, they are used from OPERAND 1
    -- when IMMEDIATE values are used, they are used from OPERAND 2
    -- when FENCE_op, ADDI is performed ( changes done in control unit)  
   
    optrn_tmp <= ADD_op when   (operation = JAL_op  or operation = JALR_op or operation = BEQ_op or 
                                operation = BNE_op  or operation = BLT_op  or operation = BGE_op or 
                                operation = BLTU_op or operation = BGEU_op or operation =  LB_op or 
                                operation = LH_op   or operation = LW_op   or operation = LBU_op or 
                                operation = LHU_op  or operation = SB_op   or operation = SH_op  or 
                                operation = SW_op   or operation = ADDI_op or operation = AUIPC_op or
                                operation = LUI_op) else operation;
      
    signed_greater <= '1' when (std_logic_vector(signed(i_operand_2)) > std_logic_vector(signed(i_operand_1))) else '0';
    unsigned_greater <= '1' when (std_logic_vector(unsigned(i_operand_2)) > std_logic_vector(unsigned(i_operand_1))) else '0';

    with optrn_tmp select o_output <= 
        (std_logic_vector(signed(i_operand_1 ) + signed(i_operand_2))) when ADD_op,
        ("0000000000000000000000000000000" & signed_greater) when SLTI_op,
        ("0000000000000000000000000000000" & signed_greater) when SLT_op,
        ("0000000000000000000000000000000" & unsigned_greater) when SLTIU_op,
        ("0000000000000000000000000000000" & unsigned_greater) when SLTU_op,
        (i_operand_1 xor i_operand_2) when XORI_op,
        (i_operand_1 xor i_operand_2) when XOR_op,
        (i_operand_1 or i_operand_2) when ORI_op,
        (i_operand_1 or i_operand_2) when OR_op,
        (i_operand_1 and i_operand_2) when ANDI_op,
        (i_operand_1 and i_operand_2) when AND_op,
        (std_logic_vector(shift_left(unsigned(i_operand_1), to_integer(unsigned(i_operand_2))))) when SLLI_op,
        (std_logic_vector(shift_left(unsigned(i_operand_1), to_integer(unsigned(i_operand_2(4 downto 0)))))) when SLL_op,
        (std_logic_vector(shift_right(unsigned(i_operand_1), to_integer(unsigned(i_operand_2))))) when SRLI_op,
        (std_logic_vector(shift_right(signed(i_operand_1), to_integer(unsigned(i_operand_2))))) when SRAI_op,
        (std_logic_vector(signed(i_operand_1) - signed(i_operand_2))) when SUB_op,
        (std_logic_vector(shift_right(unsigned(i_operand_1), to_integer(unsigned(i_operand_2(5 downto 0)))))) when SRL_op,
        (std_logic_vector(shift_right(signed(i_operand_1), to_integer(unsigned(i_operand_2(5 downto 0)))))) when SRA_op,
        X"00000000" when others;
end Behavioral;
