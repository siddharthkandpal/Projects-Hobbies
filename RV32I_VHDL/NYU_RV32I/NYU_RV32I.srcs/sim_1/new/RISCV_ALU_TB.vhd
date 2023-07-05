---------------------------------------------------------------------------------
--      ECE-GY 6463 - RISCV32I Implementation - ALU Test Bench
--      Fall 2021 
--
--      Md Raz          --  Siddharth Kandpal   --  Vivek Khithani
--      N17762874       --  N10799721           --  N16661513 
--      mr4425@nyu.edu  --  sk8944@nyu.edu      --  vk2279@nyu.edu
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use STD.textio.ALL;
use ieee.std_logic_textio.ALL;
use WORK.RISCV_PKG.ALL;
 
ENTITY RISCV_ALU_TB IS
END RISCV_ALU_TB;
 
ARCHITECTURE behavior OF RISCV_ALU_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT RISCV_ALU
    PORT(  operation   : in STD_LOGIC_VECTOR (4 DOWNTO 0);--in op_type;
           i_operand_1 : in STD_LOGIC_VECTOR (31 DOWNTO 0);
           i_operand_2 : in STD_LOGIC_VECTOR (31 DOWNTO 0); 
           o_output    : out STD_LOGIC_VECTOR(31 DOWNTO 0)   
        );
    END COMPONENT;
    

   --Inputs
   signal operation   : STD_LOGIC_VECTOR(4 DOWNTO 0):= (others => '0'); --op_type;
   signal i_operand_1 : std_logic_vector(31 DOWNTO 0):= (others => '0');
   signal i_operand_2 : std_logic_vector(31 DOWNTO 0):= (others => '0');

 	--Outputs
   signal o_output    : STD_LOGIC_VECTOR(31 DOWNTO 0) ;
   
   -- Clock period definitions
   constant i_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RISCV_ALU PORT MAP (
          operation   => operation,
          i_operand_1 =>  i_operand_1,    
          i_operand_2 =>  i_operand_2,    
          o_output    => o_output 
        );     
 
   -- Stimulus process
   stim_proc: process
        file test_vecs: TEXT open READ_MODE is "ALU_TEST_VECS.mem";
        variable file_line  : line;
        variable operation1 : STD_LOGIC_VECTOR (4 DOWNTO 0); --std_logic_vector (4 downto 0);
        variable data1      : std_logic_vector (31 downto 0);
        variable data2      : std_logic_vector (31 downto 0);
        variable output     : std_logic_vector (31 downto 0);
        variable file_space : character;  
   begin		                   
       
        while not endfile(test_vecs) loop
              
            readline(test_vecs, file_line);     
            read(file_line, operation1);
            read(file_line, file_space);  
            hread(file_line, data1);
            read(file_line, file_space); 
            hread(file_line, data2);
            read(file_line, file_space);
            hread(file_line, output);
          
            operation <= operation1;
            i_operand_1 <= data1;
            i_operand_2 <= data2;    
            wait for i_clk_period * 1;
            
            assert (o_output = output) report "Test failed! Incorrect Ouptput!" severity ERROR;
            wait for i_clk_period * 1;
        
        end loop;  
        report "All Tests Passed" severity NOTE;
        std.env.stop;
        wait;
   end process;
END;
