---------------------------------------------------------------------------------
--      ECE-GY 6463 - RISCV32I Implementation -  RISCV_CORE_TB - Behavioral
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
 
entity RISCV_CORE_TB is
end RISCV_CORE_TB;
 
architecture Behavioral of RISCV_CORE_TB is
    
    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT RISCV_CORE
    PORT( 
        i_rst, i_clk    : in STD_LOGIC;
        i_input_switches: in STD_LOGIC_VECTOR (23 downto 0);
        o_output_leds   : out STD_LOGIC_VECTOR (31 downto 0)
        );       
    END COMPONENT;   
 --Inputs
    signal i_rst : std_logic := '0';
    signal i_clk : std_logic := '0';
    signal i_input_switches : STD_LOGIC_VECTOR (23 downto 0):= (others => '0');
 --Outputs
    signal o_output_leds : STD_LOGIC_VECTOR (31 downto 0):= (others => '0');  
   
   -- Clock period definitions
   constant i_clk_period : time := 10 ns;
 
BEGIN
   -- Instantiate the Unit Under Test (UUT)
   uut: RISCV_CORE PORT MAP(
         i_rst => i_rst,
         i_clk => i_clk,
         i_input_switches => i_input_switches,
         o_output_leds => o_output_leds
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
        file test_vecs: TEXT open READ_MODE is "CORE_TEST_VECS.mem";
        variable file_line  : line;
        variable output     : std_logic_vector (31 downto 0);  
   begin		                   
       
       i_rst <= '1'; 
       -- Hold reset state 10 ns
       wait for i_clk_period * 2;
       i_rst <= '0';
       
       -- Processor is connected such that any LOAD from data memory will be available on 
       -- The 32 bit output pin.
       
       -- Testing Scheme is as follows:
        -- 1 assembly code block per instruction (37 blocks of assembly)
        -- 32 random loads and stores to register file
        -- 100 random loads from, and stores to,  100 random data memory locations
        -- Halt

       while not endfile(test_vecs) loop              
            readline(test_vecs, file_line);     
            hread(file_line, output);
            
            -- We will wait for output to change, then check against test vectors
            wait on o_output_leds; wait for i_clk_period * 0.5;
            assert (o_output_leds = output) report "Test failed! Incorrect Ouptput!" severity ERROR;    
            wait for i_clk_period * 0.5;
        end loop;  
        report "All Tests Passed" severity NOTE;
        std.env.stop;
        wait;
   end process;
END;