---------------------------------------------------------------------------------
--      ECE-GY 6463 - RISCV32I Implementation - RISCV Core Top Module
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

entity RISCV_CORE is
    Port (      
            i_rst, i_clk    : in STD_LOGIC;
            i_input_switches: in STD_LOGIC_VECTOR (23 downto 0);
            o_output_leds   : out STD_LOGIC_VECTOR (31 downto 0)
           );
end RISCV_CORE;

architecture Behavioral of RISCV_CORE is

-- Component Instantiations:
    -- Control Unit instantiation and Signals
    COMPONENT RISCV_CTRL_UNIT
    PORT(
        i_rst : IN  std_logic;
        i_clk : IN  std_logic;
        i_instr : IN  std_logic_vector(31 downto 0);
        i_do_branch : IN  std_logic;
        pc_input_sel : OUT  std_logic;
        alu_input1_sel : OUT  std_logic;
        alu_input2_sel : OUT  std_logic;
        reg_input_from_pc_sel : OUT  std_logic;
        reg_input_from_alu_sel : OUT  std_logic;
        dat_extend_en : OUT  std_logic;
        pc_wren : OUT  std_logic;
        imem_rden : OUT  std_logic;
        dmem_rden : OUT  STD_LOGIC_VECTOR(1 downto 0);
        reg_wren : OUT  std_logic;
        dmem_wren : OUT  std_logic_vector(3 downto 0);
        imm_out : OUT  std_logic_vector(31 downto 0);
        rd_out : OUT  std_logic_vector(31 downto 0);
        rs1_out : OUT  std_logic_vector(31 downto 0);
        rs2_out : OUT  std_logic_vector(31 downto 0);
        alu_optype : OUT  op_type
        );
    END COMPONENT;

    signal ctrl_i_instr                   : std_logic_vector(31 downto 0);
    signal ctrl_i_do_branch               : std_logic;
    signal ctrl_o_pc_input_sel            : STD_LOGIC; 
    signal ctrl_o_alu_input1_sel          : STD_LOGIC; 
    signal ctrl_o_alu_input2_sel          : STD_LOGIC; 
    signal ctrl_o_reg_input_from_pc_sel   : STD_LOGIC; 
    signal ctrl_o_reg_input_from_alu_sel  : STD_LOGIC; 
    signal ctrl_o_dat_extend_en           : STD_LOGIC;  
    signal ctrl_o_pc_wren                 : STD_LOGIC; 
    signal ctrl_o_imem_rden               : STD_LOGIC; 
    signal ctrl_o_dmem_rden               : STD_LOGIC_VECTOR(1 downto 0); 
    signal ctrl_o_reg_wren                : STD_LOGIC; 
    signal ctrl_o_dmem_wren               : STD_LOGIC_VECTOR (3 downto 0); 
    signal ctrl_o_imm_out                 : STD_LOGIC_VECTOR (31 downto 0);
    signal ctrl_o_rd_out                  : STD_LOGIC_VECTOR (31 downto 0);
    signal ctrl_o_rs1_out                 : STD_LOGIC_VECTOR (31 downto 0);
    signal ctrl_o_rs2_out                 : STD_LOGIC_VECTOR (31 downto 0);
    signal ctrl_o_alu_optype              : op_type;  

    -- Program Counter Instantiations and Signals 
    COMPONENT RISCV_PC
    PORT(
        i_rst : IN  std_logic;
        i_clk : IN  std_logic;
        i_wren: in std_logic;
        i_next_addr: in std_logic_vector(31 downto 0);
        o_instr_addr: out std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    
    signal pc_plus_four                   : STD_LOGIC_VECTOR (31 downto 0);
    signal pc_i_next_addr                 : STD_LOGIC_VECTOR (31 downto 0);
    signal pc_o_instr_addr                : STD_LOGIC_VECTOR (31 downto 0);
    
    COMPONENT RISCV_ALU 
    PORT(  
        --operation   : in STD_LOGIC_VECTOR (4 DOWNTO 0);--in op_type;
        operation   : in op_type;
        i_operand_1 : in STD_LOGIC_VECTOR (31 DOWNTO 0);
        i_operand_2 : in STD_LOGIC_VECTOR (31 DOWNTO 0); 
        o_output    : out STD_LOGIC_VECTOR(31 DOWNTO 0)   
        );
    END COMPONENT;

    signal alu_i_operand_1                : STD_LOGIC_VECTOR (31 downto 0);
    signal alu_i_operand_2                : STD_LOGIC_VECTOR (31 downto 0);
    signal alu_o_output                   : STD_LOGIC_VECTOR (31 downto 0);

    COMPONENT RISCV_BR_CMPR 
    PORT(  
        --operation : in STD_LOGIC_VECTOR (2 DOWNTO 0);--in op_type;
        operation : in op_type;
        i_rs1     : in STD_LOGIC_VECTOR (31 DOWNTO 0);
        i_rs2     : in STD_LOGIC_VECTOR (31 DOWNTO 0); 
        o_output  : out STD_LOGIC
        );
    END COMPONENT;
    
    COMPONENT RISCV_DATA_MEM
    PORT(
        i_rst : IN  std_logic;
        i_rd_en: IN  STD_LOGIC_VECTOR(1 downto 0) ;
        i_clk : IN  std_logic;
        i_data: IN std_logic_vector(31 downto 0);
        i_wr_en: IN std_logic_vector(3 downto 0);
        i_addr: IN std_logic_vector(31 downto 0);
        i_data_extend   : in STD_LOGIC; -- 0 for unsigned / 1 for signed
        i_input_switches: in std_logic_vector (23 downto 0); 
        o_output_leds   : out STD_LOGIC_VECTOR (31 downto 0);
        o_data: OUT std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    
    signal datamem_o_data : std_logic_vector(31 downto 0);
    signal data_mem_to_output_pins : std_logic_vector(31 downto 0);

    COMPONENT RISCV_INSTR_MEM
    PORT(
         i_clk : IN  std_logic;
         i_addr : IN  std_logic_vector(31 downto 0);
         i_rden : IN  std_logic;
         o_data : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
        
    COMPONENT RISCV_REG
    PORT(
         i_rst : IN  std_logic;
         i_clk : IN  std_logic;
         i_write_addr : IN  std_logic_vector(31 downto 0);
         i_write_data : IN  std_logic_vector(31 downto 0);
         i_write_en : IN  std_logic;
         i_read_rs1 : IN  std_logic_vector(31 downto 0);
         i_read_rs2 : IN  std_logic_vector(31 downto 0);
         o_data_rs1 : OUT  std_logic_vector(31 downto 0);
         o_data_rs2 : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;

    -- singals in input muxes 
    signal alu_or_dat_sig : std_logic_vector(31 downto 0);
    signal reg_i_data  : std_logic_vector(31 downto 0);
    
    -- Output signals
    signal reg_o_data_rs1 : std_logic_vector(31 downto 0);
    signal reg_o_data_rs2 : std_logic_vector(31 downto 0);
       
    -- These signals are used to divide the clock speed. 
    signal clk : std_logic := '0';

begin

    -- Maximum clock speed is 70 MHz, we will run the processor at 50 MHz from the 
    -- FPGA clock of 100 MHz. For this we will need to divide the clock by 2: 
    clk <= not clk when (RISING_EDGE(i_clk));

    CTRL: RISCV_CTRL_UNIT PORT MAP (
        i_rst                   => i_rst,
        i_clk                   => clk,
        i_instr                 => ctrl_i_instr,
        i_do_branch             => ctrl_i_do_branch, 
        pc_input_sel            => ctrl_o_pc_input_sel,           
        alu_input1_sel          => ctrl_o_alu_input1_sel,         
        alu_input2_sel          => ctrl_o_alu_input2_sel,         
        reg_input_from_pc_sel   => ctrl_o_reg_input_from_pc_sel,  
        reg_input_from_alu_sel  => ctrl_o_reg_input_from_alu_sel, 
        dat_extend_en           => ctrl_o_dat_extend_en,          
        pc_wren                 => ctrl_o_pc_wren,                
        imem_rden               => ctrl_o_imem_rden,              
        dmem_rden               => ctrl_o_dmem_rden,              
        reg_wren                => ctrl_o_reg_wren,               
        dmem_wren               => ctrl_o_dmem_wren,              
        imm_out                 => ctrl_o_imm_out,                
        rd_out                  => ctrl_o_rd_out,                 
        rs1_out                 => ctrl_o_rs1_out,                
        rs2_out                 => ctrl_o_rs2_out,                
        alu_optype              => ctrl_o_alu_optype                      
        );

   PC: RISCV_PC PORT MAP (
        i_rst => i_rst,
        i_clk => clk,
        i_wren => ctrl_o_pc_wren,
        i_next_addr => pc_i_next_addr,
        o_instr_addr => pc_o_instr_addr
        );
            
   ALU: RISCV_ALU PORT MAP (
        operation   =>  ctrl_o_alu_optype,
        i_operand_1 =>  alu_i_operand_1,    
        i_operand_2 =>  alu_i_operand_2,    
        o_output    =>  alu_o_output 
        );  

   BR_CMPR: RISCV_BR_CMPR PORT MAP (
        operation => ctrl_o_alu_optype,
        i_rs1     => reg_o_data_rs1,    
        i_rs2     => reg_o_data_rs2,    
        o_output  => ctrl_i_do_branch 
        );  
        
    DATA: RISCV_DATA_MEM PORT MAP (
        i_rst => i_rst,
        i_rd_en => ctrl_o_dmem_rden,
        i_clk => clk,
        i_addr => alu_o_output,
        i_wr_en => ctrl_o_dmem_wren,
        i_data => reg_o_data_rs2,
        i_data_extend => ctrl_o_dat_extend_en,
        i_input_switches => i_input_switches,
        o_output_leds => o_output_leds,  
        o_data => datamem_o_data
        );

   INSTR: RISCV_INSTR_MEM PORT MAP (
        i_clk => clk,
        i_addr => pc_o_instr_addr,
        i_rden => ctrl_o_imem_rden,
        o_data => ctrl_i_instr
        );
    
   REG: RISCV_REG PORT MAP (
        i_rst => i_rst,
        i_clk => clk,
        i_write_addr => ctrl_o_rd_out,
        i_write_data => reg_i_data,
        i_write_en => ctrl_o_reg_wren,
        i_read_rs1 => ctrl_o_rs1_out,
        i_read_rs2 => ctrl_o_rs2_out,
        o_data_rs1 => reg_o_data_rs1,
        o_data_rs2 => reg_o_data_rs2
        );
        
    ----------- Combination Logic ------------
          
    -- PC INPUT MUX
    pc_plus_four <= std_logic_vector(unsigned(pc_o_instr_addr) + "100");
    pc_i_next_addr <= pc_plus_four when ctrl_o_pc_input_sel = '1' else alu_o_output;
    
    -- ALU INPUT MUXES
    alu_i_operand_1 <= reg_o_data_rs1 when ctrl_o_alu_input1_sel = '0' else pc_o_instr_addr;
    alu_i_operand_2 <= reg_o_data_rs2 when ctrl_o_alu_input2_sel = '1' else ctrl_o_imm_out;

    -- REG INPUT MUX --- ALU/ DATAMEM OUTPUT MUX
    alu_or_dat_sig <= alu_o_output when ctrl_o_reg_input_from_alu_sel = '1' else datamem_o_data;
    reg_i_data <= alu_or_dat_sig when ctrl_o_reg_input_from_pc_sel = '1' else pc_plus_four;


end Behavioral;