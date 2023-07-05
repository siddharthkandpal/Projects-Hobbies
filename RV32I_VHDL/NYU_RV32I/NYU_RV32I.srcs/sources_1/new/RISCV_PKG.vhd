library IEEE;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
use std.textio.all;  
use ieee.std_logic_textio.all; 

package RISCV_PKG is           
 
    type ARR_32x32 is ARRAY (0 to 31) of STD_LOGIC_VECTOR (31 downto 0);
    
    type ARR_32x511  is ARRAY (0 to 511) of STD_LOGIC_VECTOR (31 downto 0);
    
    type op_type is (   LUI_op, AUIPC_op, JAL_op, JALR_op, BEQ_op, BNE_op, BLT_op, BGE_op, BLTU_op, BGEU_op, LB_op, LH_op, LW_op, LBU_op, LHU_op,
                        SB_op, SH_op, SW_op, ADDI_op, SLTI_op, SLTIU_op, XORI_op, ORI_op, ANDI_op, SLLI_op, SRLI_op, SRAI_op, ADD_op,
                        SUB_op, SLL_op, SLT_op, SLTU_op, XOR_op, SRL_op, SRA_op, OR_op, AND_op, FENCE_op, ECALL_op, EBREAK_op, NO_op);  
                        
    impure function instr_rom_readfile(
        FileName : STRING) 
        return ARR_32x511;
        
end RISCV_PKG;  

package body RISCV_PKG is   

    -- Read a *.hex file
    impure function instr_rom_readfile(FileName : STRING) return ARR_32x511  is
            file FileHandle : TEXT open READ_MODE is FileName;
            variable CurrentLine : LINE;
            variable CurrentWord : std_logic_vector(31 downto 0);
            variable Result : ARR_32x511  := (others => (others => 'X'));
    begin
        for i in 0 to 511 - 1 loop 
            exit when endfile(FileHandle);
            
            readline(FileHandle, CurrentLine);
            hread(CurrentLine, CurrentWord);
            Result(i) := CurrentWord;
        end loop;
        
        return Result;
    end function;
    
    
end RISCV_PKG;
