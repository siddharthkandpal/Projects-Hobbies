---------------------------------------------------------------------------------
--      ECE-GY 6463 - RISCV32I Implementation - Memory Block 
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

entity RISCV_INSTR_MEM is
    Port (      
            i_clk           : in STD_LOGIC;
            i_addr          : in STD_LOGIC_VECTOR (31 downto 0); -- Address must be >>2 before arriving
            i_rden          : in STD_LOGIC;
            
            o_data          : out STD_LOGIC_VECTOR(31 downto 0)
           );
end RISCV_INSTR_MEM;

architecture Behavioral of RISCV_INSTR_MEM is

    -- Memory Size is 4 kbytes --> 512 words
    signal index : integer range 0 to 511 := 0;  
    signal instr_mem : ARR_32x511  := instr_rom_readfile("MAIN.MEM"); -- Use When using Function to load from file
--    constant instr_mem : ARR_32x511 := (  X"001000b7",               -- Use With Assembly When Loading to FPGA via Bitstream
--                                          X"01408093",    -- This is the assembly for LED sweep ;
--                                          X"00100113",
--                                          X"00100193",
--                                          X"00020237",  
--                                          X"7ff20213",
--                                          X"00000293",
--                                          X"80000337",
--                                          X"00100193",
--                                          X"0030a023",
--                                          X"002282b3",
--                                          X"00428463",
--                                          X"fe429ce3",
--                                          X"002191b3",
--                                          X"00000293",
--                                          X"0030a023",
--                                          X"fe6194e3",
--                                          X"fc618ee3", OTHERS => X"00000000");
begin
        
    -- The first three bytes of the addr signify which mem block it is
    -- We will remove those before indexing the instruction memory.
    index <= to_integer(unsigned(i_addr(19 downto 2)));
    o_data <= instr_mem(index);

    
end Behavioral;