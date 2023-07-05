---------------------------------------------------------------------------------
--      ECE-GY 6463 - RISCV32I Implementation - PC Test Bench
--      Fall 2021 
--
--      Md Raz          --  Siddharth Kandpal   --  Vivek Khithani
--      N17762874       --  N10799721           --  N16661513 
--      mr4425@nyu.edu  --  sk8944@nyu.edu      --  vk2279@nyu.edu
----------------------------------------------------------------------------------
library IEEE;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use STD.textio.ALL;
use ieee.std_logic_textio.ALL;

entity RISCV_PC_TB is
end RISCV_PC_TB;

architecture Behavioral of RISCV_PC_TB is

  COMPONENT RISCV_PC
    PORT(
         i_rst : IN  std_logic;
         i_clk : IN  std_logic;
         i_wren: in std_logic;
         i_next_addr: in std_logic_vector(31 downto 0);
         o_instr_addr: out std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    
 signal i_rst : std_logic := '0';
 signal i_clk : std_logic := '0';
 signal i_wren : std_logic := '0';
 signal i_next_addr: std_logic_vector(31 downto 0):= (others => '0');--inputs
 signal o_instr_addr: std_logic_vector(31 downto 0):= (others => '0');--output
 
 -- Clock period definitions
   constant i_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RISCV_PC PORT MAP (
          i_rst => i_rst,
          i_clk => i_clk,
          i_wren => i_wren,
          i_next_addr => i_next_addr,
          o_instr_addr => o_instr_addr
          );
          
          -- Clock process definitions
   i_clk_process :process
   begin
		i_clk <= '0';
		wait for i_clk_period/2;
		i_clk <= '1';
		wait for i_clk_period/2;
   end process;
          
 -- Stimulus process
   stim_proc: process
        file test_pc: TEXT open READ_MODE is "PC_TEST_VECS.MEM";
        variable file_line  : line;
        variable index : std_logic_vector (4 downto 0);
        variable data : std_logic_vector (31 downto 0);
        variable file_space : character;  
   begin		

        i_rst <= '1';
        wait for i_clk_period * 1;
                    
        i_rst <= '0';

        while not endfile(test_pc) loop
        readline(test_pc, file_line);
        read(file_line, index);
        read(file_line, file_space);  
        hread(file_line, data);


        wait for i_clk_period * 1;
        
        i_wren <= '1';
        
        i_next_addr <= data;
         
        wait for i_clk_period * 1; 
            
        i_wren <= '0';
        
        wait for i_clk_period * 1;
        
        assert (o_instr_addr = data) report  "Test failed! Wrong output!" severity ERROR;
        
        wait for i_clk_period * 1;

        end loop;
        
        report "All Tests Passed" severity NOTE;
        std.env.stop;
    end process;

END;
      
