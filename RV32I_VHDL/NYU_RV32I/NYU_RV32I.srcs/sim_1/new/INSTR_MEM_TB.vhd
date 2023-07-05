---------------------------------------------------------------------------------
--      ECE-GY 6463 - RISCV32I Implementation - Instruction Memory Test Bench
--      Fall 2021 
--
--      Md Raz          --  Siddharth Kandpal   --  Vivek Khithani
--      N17762874       --  N10799721           --  N16661513 
--      mr4425@nyu.edu  --  sk8944@nyu.edu      --  vk2279@nyu.edu
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.textio.ALL;
use ieee.std_logic_textio.ALL;

ENTITY RISCV_INSTR_MEM_TB IS
END RISCV_INSTR_MEM_TB;
 
ARCHITECTURE behavior OF RISCV_INSTR_MEM_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RISCV_INSTR_MEM
    PORT(
         i_clk : IN  std_logic;
         i_addr : IN  std_logic_vector(19 downto 0);
         i_rden : IN  std_logic;
         o_data : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal i_clk : std_logic := '0';
   signal i_addr : std_logic_vector(19 downto 0) := (others => '0');
   signal i_rden : std_logic := '0';

 	--Outputs
   signal o_data : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant i_clk_period : time := 10 ns;
   
   -- Counter for test vector iterationsxce
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RISCV_INSTR_MEM PORT MAP (
          i_clk => i_clk,
          i_addr => i_addr,
          i_rden => i_rden,
          o_data => o_data
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
        file test_vectors: TEXT open READ_MODE is "INSTR_MEM_TEST_VECS.MEM";
        variable file_line  : line;
        variable addr : std_logic_vector (19 downto 0);
        variable data : std_logic_vector (31 downto 0);
        variable file_space : character;  
   begin		
        
        i_rden <= '0';
        i_addr <= "00000000000000000000";

       
        while not endfile(test_vectors) loop
            readline(test_vectors, file_line);
            read(file_line, addr);
            read(file_line, file_space);  
            hread(file_line, data);

            -- Load the address into the address pins
            i_addr <= addr;
            wait for i_clk_period;
            
            -- pulse read enable 
            i_rden <= '1'; wait for i_clk_period;
            i_rden <= '0';
            
            -- Assert if correct value is outputted
            assert (o_data = data) report  "Test failed! Wrong output!" severity ERROR;
            wait for i_clk_period;
          
        end loop;     
        
        report "All Tests Passed" severity NOTE;
        std.env.stop;
    end process;

END;

