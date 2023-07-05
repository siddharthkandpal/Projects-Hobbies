---------------------------------------------------------------------------------
--      ECE-GY 6463 - RISCV32I Implementation - Control Unit Test Bench
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
 
ENTITY RISCV_CTRL_UNIT_TB IS
END RISCV_CTRL_UNIT_TB;
 
ARCHITECTURE behavior OF RISCV_CTRL_UNIT_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
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
            imm_extend_en : OUT  std_logic;
            dat_extend_en : OUT  std_logic;
            pc_wren : OUT  std_logic;
            imem_rden : OUT  std_logic;
            dmem_rden : OUT  std_logic;
            reg_wren : OUT  std_logic;
            dmem_wren : OUT  std_logic_vector(3 downto 0);
            imm_out : OUT  std_logic_vector(31 downto 0);
            rd_out : OUT  std_logic_vector(4 downto 0);
            rs1_out : OUT  std_logic_vector(4 downto 0);
            rs2_out : OUT  std_logic_vector(4 downto 0);
            alu_optype : OUT  op_type
        );
    END COMPONENT;
     
    --Inputs
    signal i_rst : std_logic := '0';
    signal i_clk : std_logic := '0';
    signal i_instr : std_logic_vector(31 downto 0) := (others => '0');
    signal i_do_branch : std_logic := '0';
    
    --Outputs
    signal pc_input_sel             : std_logic;
    signal alu_input1_sel           : std_logic;
    signal alu_input2_sel           : std_logic;
    signal reg_input_from_pc_sel    : std_logic;
    signal reg_input_from_alu_sel   : std_logic;
    signal imm_extend_en            : std_logic;
    signal dat_extend_en            : std_logic;
    signal pc_wren                  : std_logic;
    signal imem_rden                : std_logic;
    signal dmem_rden                : std_logic;
    signal reg_wren                 : std_logic;
    signal dmem_wren                : std_logic_vector(3 downto 0);
    signal imm_out                  : std_logic_vector(31 downto 0);
    signal rd_out                   : std_logic_vector(4 downto 0);
    signal rs1_out                  : std_logic_vector(4 downto 0);
    signal rs2_out                  : std_logic_vector(4 downto 0);
    signal alu_optype               : op_type;
    
    -- Clock period definitions
    constant i_clk_period : time := 10 ns;
 
BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
    uut: RISCV_CTRL_UNIT PORT MAP (
        i_rst => i_rst,
        i_clk => i_clk,
        i_instr => i_instr,
        i_do_branch => i_do_branch,
        pc_input_sel => pc_input_sel,
        alu_input1_sel => alu_input1_sel,
        alu_input2_sel => alu_input2_sel,
        reg_input_from_pc_sel => reg_input_from_pc_sel,
        reg_input_from_alu_sel => reg_input_from_alu_sel,
        imm_extend_en => imm_extend_en,
        dat_extend_en => dat_extend_en,
        pc_wren => pc_wren,
        imem_rden => imem_rden,
        dmem_rden => dmem_rden,
        reg_wren => reg_wren,
        dmem_wren => dmem_wren,
        imm_out => imm_out,
        rd_out => rd_out,
        rs1_out => rs1_out,
        rs2_out => rs2_out,
        alu_optype => alu_optype
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
        -- Files
        file test_vecs_ctrl_unit_no_branch: TEXT open READ_MODE is "CTRL_UNIT_TEST_VECS_NO_BRANCH.MEM";
        file test_vecs_ctrl_unit_with_branch: TEXT open READ_MODE is "CTRL_UNIT_TEST_VECS_WITH_BRANCH.MEM";
        -- signals 
        variable file_line  : line;
        variable file_space : character;
        -- inputs
        variable instr_val : std_logic_vector (31 downto 0);
        variable do_branch_val : std_logic;
        -- outputs
        variable pc_input_sel_val             : std_logic;                    
        variable alu_input1_sel_val           : std_logic;                    
        variable alu_input2_sel_val           : std_logic;                    
        variable reg_input_from_pc_sel_val    : std_logic;                    
        variable reg_input_from_alu_sel_val   : std_logic;                    
        variable imm_extend_en_val            : std_logic;                    
        variable dat_extend_en_val            : std_logic;                    
        variable pc_wren_val                  : std_logic;                    
        variable imem_rden_val                : std_logic;                    
        variable dmem_rden_val                : std_logic; --                   
        variable reg_wren_val                 : std_logic; --                   
        variable dmem_wren_val                : std_logic_vector(3 downto 0); 
        variable rd_out_val                   : std_logic_vector(4 downto 0); 
        variable rs1_out_val                  : std_logic_vector(4 downto 0); 
        variable rs2_out_val                  : std_logic_vector(4 downto 0); 
        variable alu_optype_val               : string(1 to 10);                    
    begin		
        -- Start with reset conditions
        i_rst <= '1';
        wait for i_clk_period * 5;
        
        i_rst <= '0'; -- "turn on" the processor
        
        -- 0th instruction
        wait for i_clk_period * 1;
        
        while not endfile(test_vecs_ctrl_unit_no_branch) loop
            -- Read line of the file per loop, and space character between variables
            readline(test_vecs_ctrl_unit_no_branch, file_line);
            read(file_line, instr_val);                         read(file_line, file_space);            
            read(file_line, do_branch_val);                     read(file_line, file_space); 
            read(file_line, pc_input_sel_val);                  read(file_line, file_space); 
            read(file_line, alu_input1_sel_val);                read(file_line, file_space); 
            read(file_line, alu_input2_sel_val);                read(file_line, file_space); 
            read(file_line, reg_input_from_pc_sel_val);         read(file_line, file_space); 
            read(file_line, reg_input_from_alu_sel_val);        read(file_line, file_space); 
            read(file_line, imm_extend_en_val);                 read(file_line, file_space); 
            read(file_line, dat_extend_en_val);                 read(file_line, file_space); 
            read(file_line, pc_wren_val);                       read(file_line, file_space); 
            read(file_line, imem_rden_val);                     read(file_line, file_space); 
            read(file_line, dmem_rden_val);                     read(file_line, file_space); 
            read(file_line, reg_wren_val);                      read(file_line, file_space); 
            read(file_line, dmem_wren_val);                     read(file_line, file_space); 
            read(file_line, rd_out_val);                        read(file_line, file_space); 
            read(file_line, rs1_out_val);                       read(file_line, file_space); 
            read(file_line, rs2_out_val);                       read(file_line, file_space); 
            --read(file_line, alu_optype_val);  

            i_instr <= instr_val;
            i_do_branch <= do_branch_val;
                     
            -- Decode instruction state
            wait for i_clk_period * 1; 
            -- check output control signals
            assert (alu_input1_sel         = alu_input1_sel_val        ) report  "Test failed! Wrong alu_input1_sel!" severity ERROR;
            assert (alu_input2_sel         = alu_input2_sel_val        ) report  "Test failed! Wrong alu_input2_sel!" severity ERROR;
            assert (reg_input_from_pc_sel  = reg_input_from_pc_sel_val ) report  "Test failed! Wrong reg_input_from_pc_sel!" severity ERROR;
            assert (reg_input_from_alu_sel = reg_input_from_alu_sel_val) report  "Test failed! Wrong reg_input_from_alu_sel!" severity ERROR;
            assert (imm_extend_en          = imm_extend_en_val         ) report  "Test failed! Wrong imm_extend_en!" severity ERROR;
            assert (dat_extend_en          = dat_extend_en_val         ) report  "Test failed! Wrong dat_extend_en!" severity ERROR;
            assert (dmem_rden              = dmem_rden_val             ) report  "Test failed! Wrong dmem_rden!" severity ERROR;
            assert (rd_out                 = rd_out_val                ) report  "Test failed! Wrong rd_out!" severity ERROR;
            assert (rs1_out                = rs1_out_val               ) report  "Test failed! Wrong rs1_out!" severity ERROR;
            assert (rs2_out                = rs2_out_val               ) report  "Test failed! Wrong rs2_out!" severity ERROR;
            --assert (alu_optype             = alu_optype_val            ) report  "Test failed! Wrong Control Signal!" severity ERROR;
            
            -- Execute instruction state
            wait for i_clk_period * 1; 
            assert (pc_input_sel           = pc_input_sel_val          ) report  "Test failed! Wrong pc_input_sel!" severity ERROR;            
            assert (reg_wren               = reg_wren_val              ) report  "Test failed! Wrong reg_wren!" severity ERROR;
            assert (dmem_wren              = dmem_wren_val             ) report  "Test failed! Wrong dmem_wren!" severity ERROR;

            -- Increment PC state
            wait for i_clk_period * 1; 
            assert (pc_wren                = pc_wren_val               ) report  "Test failed! Wrong pc_wren!" severity ERROR;
            
            -- Fetch instruction state
            wait for i_clk_period * 1; 
            assert (imem_rden              = imem_rden_val ) report  "Test failed! Wrong Control Signal!" severity ERROR;

            
        end loop; 
        
        -- Processor is in a halted state, need to reset:
        i_rst <= '1';
        wait for i_clk_period * 5;
              
        i_rst <= '0'; -- "turn on" the processor
        
        -- 0th instruction
        wait for i_clk_period * 1;
        
        while not endfile(test_vecs_ctrl_unit_with_branch) loop
            -- Read line of the file per loop, and space character between variables
            readline(test_vecs_ctrl_unit_with_branch, file_line);
            read(file_line, instr_val);                         read(file_line, file_space);            
            read(file_line, do_branch_val);                     read(file_line, file_space); 
            read(file_line, pc_input_sel_val);                  read(file_line, file_space); 
            read(file_line, alu_input1_sel_val);                read(file_line, file_space); 
            read(file_line, alu_input2_sel_val);                read(file_line, file_space); 
            read(file_line, reg_input_from_pc_sel_val);         read(file_line, file_space); 
            read(file_line, reg_input_from_alu_sel_val);        read(file_line, file_space); 
            read(file_line, imm_extend_en_val);                 read(file_line, file_space); 
            read(file_line, dat_extend_en_val);                 read(file_line, file_space); 
            read(file_line, pc_wren_val);                       read(file_line, file_space); 
            read(file_line, imem_rden_val);                     read(file_line, file_space); 
            read(file_line, dmem_rden_val);                     read(file_line, file_space); 
            read(file_line, reg_wren_val);                      read(file_line, file_space); 
            read(file_line, dmem_wren_val);                     read(file_line, file_space); 
            read(file_line, rd_out_val);                        read(file_line, file_space); 
            read(file_line, rs1_out_val);                       read(file_line, file_space); 
            read(file_line, rs2_out_val);                       read(file_line, file_space); 
            --read(file_line, alu_optype_val);  

            i_instr <= instr_val;
            i_do_branch <= do_branch_val;
                        
            -- Decode instruction state
            wait for i_clk_period * 1; 
            -- check output control signals
            assert (alu_input1_sel         = alu_input1_sel_val        ) report  "Test failed! Wrong alu_input1_sel!" severity ERROR;
            assert (alu_input2_sel         = alu_input2_sel_val        ) report  "Test failed! Wrong alu_input2_sel!" severity ERROR;
            assert (reg_input_from_pc_sel  = reg_input_from_pc_sel_val ) report  "Test failed! Wrong reg_input_from_pc_sel!" severity ERROR;
            assert (reg_input_from_alu_sel = reg_input_from_alu_sel_val) report  "Test failed! Wrong reg_input_from_alu_sel!" severity ERROR;
            assert (imm_extend_en          = imm_extend_en_val         ) report  "Test failed! Wrong imm_extend_en!" severity ERROR;
            assert (dat_extend_en          = dat_extend_en_val         ) report  "Test failed! Wrong dat_extend_en!" severity ERROR;
            assert (dmem_rden              = dmem_rden_val             ) report  "Test failed! Wrong dmem_rden!" severity ERROR;
            assert (rd_out                 = rd_out_val                ) report  "Test failed! Wrong rd_out!" severity ERROR;
            assert (rs1_out                = rs1_out_val               ) report  "Test failed! Wrong rs1_out!" severity ERROR;
            assert (rs2_out                = rs2_out_val               ) report  "Test failed! Wrong rs2_out!" severity ERROR;
            --assert (alu_optype             = alu_optype_val            ) report  "Test failed! Wrong Control Signal!" severity ERROR;
            
            -- Execute instruction state
            wait for i_clk_period * 1; 
            assert (pc_input_sel           = pc_input_sel_val          ) report  "Test failed! Wrong pc_input_sel!" severity ERROR;            
            assert (reg_wren               = reg_wren_val              ) report  "Test failed! Wrong reg_wren!" severity ERROR;
            assert (dmem_wren              = dmem_wren_val             ) report  "Test failed! Wrong dmem_wren!" severity ERROR;

            -- Increment PC state
            wait for i_clk_period * 1; 
            assert (pc_wren                = pc_wren_val               ) report  "Test failed! Wrong pc_wren!" severity ERROR;

            -- Fetch instruction state
            wait for i_clk_period * 1; 
            assert (imem_rden              = imem_rden_val  ) report  "Test failed! Wrong Control Signal!" severity ERROR;
            
        end loop; 
        report "All Tests Passed" severity NOTE;
        std.env.stop;
    end process;

END;
