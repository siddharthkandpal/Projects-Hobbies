---------------------------------------------------------------------------------
--      ECE-GY 6463 - RISCV32I Implementation - Data Memory Test Bench
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


entity RISCV_DATA_MEM_TB is
end RISCV_DATA_MEM_TB;

architecture Behavioral of RISCV_DATA_MEM_TB is

COMPONENT RISCV_DATA_MEM
    PORT(
         i_rst : IN  std_logic;
         i_rden: IN  std_logic ;
         i_clk : IN  std_logic;
         i_data: IN std_logic_vector(31 downto 0) := (others => '0');
         i_wr_en: IN std_logic_vector(3 downto 0) := (others => '0');
         i_wr_addr: IN std_logic_vector(31 downto 0) := (others => '0');
         i_rd_addr: IN std_logic_vector(31 downto 0) := (others => '0');
         o_data: OUT std_logic_vector(31 downto 0) := (others => '0')
         );
         END COMPONENT;
         
--INPUTS
        signal i_rst:      std_logic := '0';
        signal i_rden:     std_logic := '0';
        signal i_clk:      std_logic := '0';
        signal i_wr_addr:  std_logic_vector(31 downto 0) := (others => '0');
        signal i_wr_en:    std_logic_vector(3 downto 0) := (others => '0'); 
        signal i_data:     std_logic_vector(31 downto 0) := (others => '0');
        signal i_rd_addr:  std_logic_vector(31 downto 0) := (others => '0');
        signal o_data:     std_logic_vector(31 downto 0) := (others => '0');
        
 -- Clock period definitions
        constant i_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
         uut: RISCV_DATA_MEM PORT MAP (
          i_rst => i_rst,
          i_rden => i_rden,
          i_clk => i_clk,
          i_wr_addr => i_wr_addr,
          i_wr_en => i_wr_en,
          i_data => i_data,
          i_rd_addr => i_rd_addr,
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
        file test_dmem: TEXT open READ_MODE is "DATA_MEM_TEST_VECS.MEM";
        variable file_line  : line;
        variable index : std_logic_vector (31 downto 0);
        variable data : std_logic_vector (31 downto 0);
        variable file_space : character;  
   begin		

         
        wait for i_clk_period * 1;
                   
        i_rden <= '0';

        while not endfile(test_dmem) loop
            readline(test_dmem, file_line);
            hread(file_line, index);
            read(file_line, file_space);  
            hread(file_line, data);
    
            i_data <= data; 
            i_rd_addr<= index;
            
            wait for i_clk_period * 1;
            i_wr_addr<=index;

            
            
            i_wr_en<= "1111";
            
            
            i_rden<= '1';
            
            wait for i_clk_period * 1;
            
            i_rden<= '0';
                   
            wait for i_clk_period * 1;

            if index = x"00100000" then
                assert (o_data = X"17762874")report  "Test failed! Wrong output!" severity ERROR;
            elsif index = x"00100004" then
                assert (o_data = X"10799721")report  "Test failed! Wrong output!" severity ERROR;
            elsif index = x"00100008" then
                assert (o_data = X"16661513")report  "Test failed! Wrong output!" severity ERROR;
            else 
                assert (o_data = data) report "Test failed! Wrong output!" severity ERROR;
            
            wait for i_clk_period * 1;
             end if;
        end loop;  

        report "All Tests Passed" severity NOTE;
        std.env.stop;
        wait;
   end process;

END;


