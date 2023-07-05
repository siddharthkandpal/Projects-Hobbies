---------------------------------------------------------------------------------
--      ECE-GY 6463 - RISCV32I Implementation - Program Counter 
--      Fall 2021 
--
--      Md Raz          --  Siddharth Kandpal   --  Vivek Khithani
--      N17762874       --  N10799721           --  N16661513 
--      mr4425@nyu.edu  --  sk8944@nyu.edu      --  vk2279@nyu.edu
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.RISCV_PKG.ALL;

entity RISCV_PC is
    Port (      
            i_rst, i_clk    : in STD_LOGIC; 
            i_wren          : in STD_LOGIC;
            i_next_addr     : in STD_LOGIC_VECTOR (31 DOWNTO 0);
            
            o_instr_addr    : out STD_LOGIC_VECTOR(31 DOWNTO 0)
           );   
end RISCV_PC;

architecture Behavioral of RISCV_PC is
    signal current_instr_addr : STD_LOGIC_VECTOR(31 DOWNTO 0) := X"01000000";
begin

    o_instr_addr <= current_instr_addr;
    
    update_proc : process (i_clk, i_rst, i_wren) begin
        if (i_rst = '1') then 
            current_instr_addr <= X"01000000";
        elsif (RISING_EDGE(i_clk) and i_wren = '1') then
            current_instr_addr <= i_next_addr;
        end if;
    end process;

end Behavioral;
