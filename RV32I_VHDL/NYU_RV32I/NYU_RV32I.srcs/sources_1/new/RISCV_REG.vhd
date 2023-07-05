---------------------------------------------------------------------------------
--      ECE-GY 6463 - RISCV32I Implementation - Register Module 
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

entity RISCV_REG is
    Port (      
            i_rst, i_clk    : in STD_LOGIC; 
            
            i_write_addr    : in STD_LOGIC_VECTOR (31 downto 0);
            i_write_data    : in STD_LOGIC_VECTOR (31 DOWNTO 0);
            i_write_en      : in STD_LOGIC;
            
            i_read_rs1    : in STD_LOGIC_VECTOR (31 downto 0);
            i_read_rs2    : in STD_LOGIC_VECTOR (31 downto 0);
            
            o_data_rs1    : out STD_LOGIC_VECTOR(31 DOWNTO 0);
            o_data_rs2    : out STD_LOGIC_VECTOR(31 DOWNTO 0)
           );   
end RISCV_REG;

architecture Behavioral of RISCV_REG is
    signal register_array : ARR_32x32 := (OTHERS => X"00000000");
    signal read_index_1 : integer := 0;
    signal read_index_2 : integer := 0;
    signal write_index  : integer := 0;

begin

    write_index <= to_integer(unsigned(i_write_addr(4 downto 0)));
    read_index_1 <= to_integer(unsigned(i_read_rs1(4 downto 0)));
    read_index_2 <= to_integer(unsigned(i_read_rs2(4 downto 0)));
    
    o_data_rs1 <= register_array(read_index_1);
    o_data_rs2 <= register_array(read_index_2);

    write_proc : process(i_clk, i_rst, i_write_en) begin
        if (i_rst = '1') then 
            register_array <= (OTHERS => X"00000000");
        elsif (RISING_EDGE(i_clk) AND i_write_en = '1') then 
            register_array(write_index) <= i_write_data; 
            register_array(0)           <= X"00000000";
        end if;
    end process;

end Behavioral;
