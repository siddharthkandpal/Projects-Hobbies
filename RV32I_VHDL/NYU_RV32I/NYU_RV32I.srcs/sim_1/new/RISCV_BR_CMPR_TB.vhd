---------------------------------------------------------------------------------
--      ECE-GY 6463 - RISCV32I Implementation - Branch Comparitor Test Bench
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
 
ENTITY RISCV_BR_CMPR_TB IS
END RISCV_BR_CMPR_TB;
 
ARCHITECTURE behavior OF RISCV_BR_CMPR_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT RISCV_BR_CMPR
    PORT(  operation : in STD_LOGIC_VECTOR (2 DOWNTO 0);--in op_type;
           i_rs1     : in STD_LOGIC_VECTOR (31 DOWNTO 0);
           i_rs2     : in STD_LOGIC_VECTOR (31 DOWNTO 0); 
           o_output  : out STD_LOGIC
        );
    END COMPONENT;

   --Inputs
   signal operation : STD_LOGIC_VECTOR (2 DOWNTO 0); --op_type;
   signal i_rs1 : std_logic_vector(31 DOWNTO 0):= (others => '0');
   signal i_rs2 : std_logic_vector(31 DOWNTO 0):= (others => '0');

 	--Outputs
   signal o_output : std_logic ;
   
   -- Clock period definitions
   constant i_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RISCV_BR_CMPR PORT MAP (
          operation => operation,
          i_rs1     => i_rs1,    
          i_rs2     => i_rs2,    
          o_output  => o_output 
        );     
 
   -- Stimulus process
   stim_proc: process
         file test_vecs: TEXT open READ_MODE is "BR_CMPR_TEST_VECS.MEM";
        variable file_line  : line;
        variable operation1 : STD_LOGIC_VECTOR (2 DOWNTO 0); --std_logic_vector (4 downto 0);
        variable data1 : std_logic_vector (31 downto 0);
        variable data2 : std_logic_vector (31 downto 0);
        variable output : std_logic;
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
            read(file_line, output);
          
            operation <= operation1;
            i_rs1 <= data1;
            i_rs2 <= data2;    
            wait for i_clk_period * 1;
            
            assert (o_output = output) report "Test failed! Incorrect Ouptput!" severity ERROR;
            wait for i_clk_period * 1;
        
        end loop;  
        report "All Tests Passed" severity NOTE;
        std.env.stop;
        wait;
   end process;
END;
