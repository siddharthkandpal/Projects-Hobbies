---------------------------------------------------------------------------------
--      ECE-GY 6463 - RISCV32I Implementation - REGFILE Test Bench
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
 
ENTITY RISCV_REG_TB IS
END RISCV_REG_TB;
 
ARCHITECTURE behavior OF RISCV_REG_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RISCV_REG
    PORT(
         i_rst : IN  std_logic;
         i_clk : IN  std_logic;
         i_write_addr : IN  std_logic_vector(4 downto 0);
         i_write_data : IN  std_logic_vector(31 downto 0);
         i_write_en : IN  std_logic;
         i_read_rs1 : IN  std_logic_vector(4 downto 0);
         i_read_rs2 : IN  std_logic_vector(4 downto 0);
         o_data_rs1 : OUT  std_logic_vector(31 downto 0);
         o_data_rs2 : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal i_rst : std_logic := '0';
   signal i_clk : std_logic := '0';
   signal i_write_addr : std_logic_vector(4 downto 0) := (others => '0');
   signal i_write_data : std_logic_vector(31 downto 0) := (others => '0');
   signal i_write_en : std_logic := '0';
   signal i_read_rs1 : std_logic_vector(4 downto 0) := (others => '0');
   signal i_read_rs2 : std_logic_vector(4 downto 0) := (others => '0');

 	--Outputs
   signal o_data_rs1 : std_logic_vector(31 downto 0);
   signal o_data_rs2 : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant i_clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RISCV_REG PORT MAP (
          i_rst => i_rst,
          i_clk => i_clk,
          i_write_addr => i_write_addr,
          i_write_data => i_write_data,
          i_write_en => i_write_en,
          i_read_rs1 => i_read_rs1,
          i_read_rs2 => i_read_rs2,
          o_data_rs1 => o_data_rs1,
          o_data_rs2 => o_data_rs2
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
        file test_vecs: TEXT open READ_MODE is "REG_TEST_VECS.MEM";
        variable file_line  : line;
        variable index : std_logic_vector (4 downto 0);
        variable data : std_logic_vector (31 downto 0);
        variable file_space : character;  
   begin		

        i_rst <= '1';
        wait for i_clk_period * 1;
                    
        i_rst <= '0';
        

        while not endfile(test_vecs) loop
            readline(test_vecs, file_line);
            read(file_line, index);
            read(file_line, file_space);  
            hread(file_line, data);
            
            wait for i_clk_period * 1;

            i_write_addr <= index;
            i_write_data <= data;
            i_write_en <= '1';
            
            wait for i_clk_period * 1; 
            
            i_write_en <= '0';
            
            i_read_rs1 <= index;
            i_read_rs2 <= index;
            
            wait for i_clk_period * 1;
            
            if index = "00000" then 
                assert (o_data_rs1 = X"00000000") report  "Test failed! Wrong output!" severity ERROR;
                assert (o_data_rs2 = X"00000000") report  "Test failed! Wrong output!" severity ERROR;
            else 
                assert (o_data_rs1 = data) report  "Test failed! Wrong output!" severity ERROR;
                assert (o_data_rs2 = data) report  "Test failed! Wrong output!" severity ERROR;
            end if;
            
            wait for i_clk_period * 1;
             
        end loop;  

        report "All Tests Passed" severity NOTE;
        std.env.stop;
        wait;
   end process;

END;
