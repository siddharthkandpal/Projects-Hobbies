---------------------------------------------------------------------------------
--      ECE-GY 6463 - RISCV32I Implementation - Branch Compare Unit 
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

entity RISCV_BR_CMPR is
    Port (               
            operation       : in op_type;
            i_rs1           : in STD_LOGIC_VECTOR (31 DOWNTO 0);
            i_rs2           : in STD_LOGIC_VECTOR (31 DOWNTO 0);
            
            o_output        : out STD_LOGIC
           );  
end RISCV_BR_CMPR;

architecture Behavioral of RISCV_BR_CMPR is

    signal signal_BEQ_op  : STD_LOGIC := '0';
    signal signal_BNE_op  : STD_LOGIC := '0';
    signal signal_BLT_op  : STD_LOGIC := '0';
    signal signal_BGE_op  : STD_LOGIC := '0';
    signal signal_BLTU_op : STD_LOGIC := '0';
    signal signal_BGEU_op : STD_LOGIC := '0';
    
begin

    signal_BEQ_op  <= '1' when ((signed(i_rs1) = signed(i_rs2)))       else '0';
    signal_BNE_op  <= '1' when ((signed(i_rs1) /= signed(i_rs2)))      else '0';
    signal_BLT_op  <= '1' when ((signed(i_rs1) < signed(i_rs2)))       else '0';
    signal_BGE_op  <= '1' when ((signed(i_rs1) >= signed(i_rs2)))      else '0';
    signal_BLTU_op <= '1' when ((unsigned(i_rs1) < unsigned(i_rs2)))   else '0';
    signal_BGEU_op <= '1' when ((unsigned(i_rs1) >= unsigned(i_rs2)))  else '0';

    with operation select o_output <= 
        signal_BEQ_op  when BEQ_op ,
        signal_BNE_op  when BNE_op ,
        signal_BLT_op  when BLT_op ,
        signal_BGE_op  when BGE_op ,
        signal_BLTU_op when BLTU_op,
        signal_BGEU_op when BGEU_op,
        '0'            when others;
                       
                       
                       
end Behavioral;         