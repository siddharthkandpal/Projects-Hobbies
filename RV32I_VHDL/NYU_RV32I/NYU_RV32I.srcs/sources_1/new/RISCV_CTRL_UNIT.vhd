---------------------------------------------------------------------------------
--      ECE-GY 6463 - RISCV32I Implementation - Control Unit 
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

entity RISCV_CTRL_UNIT is
    Port (      
            i_rst, i_clk    : in STD_LOGIC; 
            i_instr         : in STD_LOGIC_VECTOR (31 downto 0);
            i_do_branch     : in STD_LOGIC;
            
            pc_input_sel            : out STD_LOGIC; 
            alu_input1_sel          : out STD_LOGIC; 
            alu_input2_sel          : out STD_LOGIC; 
            reg_input_from_pc_sel   : out STD_LOGIC; 
            reg_input_from_alu_sel  : out STD_LOGIC; 
            dat_extend_en           : out STD_LOGIC;  
            pc_wren                 : out STD_LOGIC; 
            imem_rden               : out STD_LOGIC; 
            dmem_rden               : out STD_LOGIC_VECTOR(1 downto 0); 
            reg_wren                : out STD_LOGIC; 
            dmem_wren               : out STD_LOGIC_VECTOR (3 downto 0); 
           
            imm_out                 : out STD_LOGIC_VECTOR (31 downto 0);
            rd_out                  : out STD_LOGIC_VECTOR (31 downto 0);
            rs1_out                 : out STD_LOGIC_VECTOR (31 downto 0);
            rs2_out                 : out STD_LOGIC_VECTOR (31 downto 0);
            
            alu_optype      : out op_type 
           );
end RISCV_CTRL_UNIT;

architecture Behavioral of RISCV_CTRL_UNIT is

    signal operation    : op_type := NO_op; 
    signal op_code      : STD_LOGIC_VECTOR (6 downto 0);
    
    signal funct7       : STD_LOGIC_VECTOR (6 downto 0);
    signal funct3       : STD_LOGIC_VECTOR (2 downto 0);
    
    signal rd           : STD_LOGIC_VECTOR (4 downto 0);
    signal rs1          : STD_LOGIC_VECTOR (4 downto 0);
    signal rs2          : STD_LOGIC_VECTOR (4 downto 0);   
    
    signal rd_tmp           : STD_LOGIC_VECTOR (4 downto 0);
    signal rs1_tmp          : STD_LOGIC_VECTOR (4 downto 0);
    signal rs2_tmp         : STD_LOGIC_VECTOR (4 downto 0);	
    
    signal i_type_imm   : STD_LOGIC_VECTOR (11 downto 0); 
    signal s_type_imm   : STD_LOGIC_VECTOR (11 downto 0);
    signal b_type_imm   : STD_LOGIC_VECTOR (12 downto 0);
    signal u_type_imm   : STD_LOGIC_VECTOR (19 downto 0);
    signal j_type_imm   : STD_LOGIC_VECTOR (20 downto 0);
    
    type   fsm_state is (ST_FETCH, ST_DECODE, ST_EXECUTE, ST_INCREMENT, ST_HALT);
    signal state    : fsm_state := ST_FETCH;
    
begin

    alu_optype      <= operation;
    
    op_code <= i_instr(6 downto 0);
    rd      <= i_instr(11 downto 7);
    rs1     <= i_instr(19 downto 15);
    rs2     <= i_instr(24 downto 20);
    funct3  <= i_instr(14 downto 12);
    funct7  <= i_instr(31 downto 25);
	
	rs1_out <= std_logic_vector(resize(unsigned(rs1_tmp), 32));
	rs2_out <= std_logic_vector(resize(unsigned(rs2_tmp), 32));
	rd_out <= std_logic_vector(resize(unsigned(rd_tmp), 32));

    i_type_imm  <= i_instr(31 downto 20);       -- correct
    s_type_imm  <= i_instr(31 downto 25) & i_instr(11 downto 7); -- Correct
    b_type_imm  <= i_instr(31) & i_instr(7) & i_instr(30 downto 25) & i_instr(11 downto 8) & '0';  -- correct 
    u_type_imm  <= i_instr(31 downto 12); -- correct
    j_type_imm  <= i_instr(31) & i_instr(19 downto 12) & i_instr(20) & i_instr(30 downto 21) & '0'; -- correct
    
    fsm_proc : process (i_rst, i_clk) begin
        if (i_rst = '1') then 
            state <= ST_FETCH; 
        elsif (RISING_EDGE(i_clk)) then
            case state is
------------------------------------------------------- Fetch ops ------------------------------------------------------             
                WHEN ST_FETCH       => 
                    imem_rden <= '1';
                    pc_wren <= '0';
                    state <= ST_DECODE;
                    
------------------------------------------------------- Decode ops ------------------------------------------------------                     
                WHEN ST_DECODE      => 
                    imem_rden <= '0';
                    
                    -- Defaults before changes
                    pc_input_sel            <= '1';  -- 0:ALU / 1:PC+4  
                    alu_input1_sel          <= '0';  -- 0:RS1 / 1:PC     
                    alu_input2_sel          <= '0';  -- 0:IMM / 1:RS2
                    reg_input_from_pc_sel   <= '0';  -- 0:PC+4 / 1:ALU/DM
                    reg_input_from_alu_sel  <= '0';  -- 0:DM / 1:ALU
                    --imm_extend_en           <= '0';  -- 0:zero ext / 1:sign ext
                    dat_extend_en           <= '0';  -- 0:zero ext / 1:sign ext
                    imem_rden               <= '0';  -- 0:no read / 1:read
                    dmem_rden               <= "00";  -- 0:no read / 1:read
                    reg_wren                <= '0';  -- 0:no write / 1:write
                    dmem_wren               <= "0000";  -- 0:no write / 1:write  
                    
                    imm_out                 <= X"00000000";
                    rd_tmp                  <= "00000";
                    rs1_tmp                 <= "00000";
                    rs2_tmp                 <= "00000";
                    
---------------------- U TYPE INSTRUCTIONS
                    if (op_code = "0110111") then -- LUI INSTR            
                        imm_out <= u_type_imm & "000000000000";
                        rd_tmp <= rd; operation <= LUI_op; 
                        -- Loads the immediate value into the upper
                        -- 20 bits of the target register rd and sets
                        -- the lower bits to 0 
                        --imm_extend_en           <= '0';  -- 0:zero ext / 1:sign ext
                        alu_input2_sel          <= '0';  -- 0:IMM / 1:RS2 
                        reg_input_from_alu_sel  <= '1';  -- 0:DM / 1:ALU 
                        reg_input_from_pc_sel   <= '1';  -- 0:PC+4 / 1:ALU/DM                                             
                         
                    elsif (op_code = "0010111") then -- AUIPC INSTR
                        imm_out <= u_type_imm & "000000000000";
                        rd_tmp <= rd; operation <= AUIPC_op;
                        --Forms a 32-bit offset from the 20-bit value
                        --by filling the lower bits with zeros, adds
                        --this to PC, and stores the result in rd. 
                        --imm_extend_en           <= '0';  -- 0:zero ext / 1:sign ext
                        alu_input1_sel          <= '1';  -- 0:RS1 / 1:PC     
                        alu_input2_sel          <= '0';  -- 0:IMM / 1:RS2                  
                        reg_input_from_alu_sel  <= '1';  -- 0:DM / 1:ALU 
                        reg_input_from_pc_sel   <= '1';  -- 0:PC+4 / 1:ALU/DM 
                                                  
---------------------- J TYPE INSTRUCTIONS
                    elsif (op_code = "1101111") then -- JAL INSTR
                        --imm_out <= "000000000000" & j_type_imm; 
                        imm_out <= std_logic_vector(resize(signed(j_type_imm), 32));
                        rd_tmp <= rd; operation <= JAL_op;
                        --Jump to PC=PC+(sign-extended
                        --immediate value) and store the current PC                        
                        --imm_extend_en           <= '1';  -- 0:zero ext / 1:sign ext
                        alu_input1_sel          <= '1';  -- 0:RS1 / 1:PC     
                        alu_input2_sel          <= '0';  -- 0:IMM / 1:RS2                  
                        reg_input_from_pc_sel   <= '0';  -- 0:PC+4 / 1:ALU/DM                        
                        
                    elsif (op_code = "1100111") then -- JALR INSTR
                        --imm_out <= "000000000000" & j_type_imm;
                        imm_out <= std_logic_vector(resize(signed(j_type_imm), 32));
                        rd_tmp <= rd; rs1_tmp <= rs1; operation <= JALR_op;
                        --Jump to PC=rs1 register value
                        --+(sign-extended immediate value) and
                        --store the current PC address+4 in register rd                   
                        --imm_extend_en           <= '1';  -- 0:zero ext / 1:sign ext
                        alu_input1_sel          <= '0';  -- 0:RS1 / 1:PC       
                        alu_input2_sel          <= '0';  -- 0:IMM / 1:RS2      
                        reg_input_from_pc_sel   <= '0';  -- 0:PC+4 / 1:ALU/DM  
                        
---------------------- B TYPE INSTRUCTIONS    
                    elsif (op_code = "1100011") then 
                        --imm_out <= "0000000000000000000" & b_type_imm; 
                        imm_out <= std_logic_vector(resize(signed(b_type_imm), 32));
                        rs2_tmp <= rs2; 
                        rs1_tmp <= rs1;
                        
                        -- PC = PC+(sign-extended immediate value) if branch
                        --imm_extend_en           <= '1';  -- 0:zero ext / 1:sign ext
                        alu_input1_sel          <= '1';  -- 0:RS1 / 1:PC       
                        alu_input2_sel          <= '0';  -- 0:IMM / 1:RS2    
                         
                        if      (funct3 = "000") then operation <= BEQ_op;                                                 
                        elsif   (funct3 = "001") then operation <= BNE_op;
                        elsif   (funct3 = "100") then operation <= BLT_op;
                        elsif   (funct3 = "101") then operation <= BGE_op;
                        elsif   (funct3 = "110") then operation <= BLTU_op;
                        elsif   (funct3 = "111") then operation <= BGEU_op;
                        end if;                       
                        
---------------------- I TYPE INSTRUCTIONS    
                    elsif (op_code = "0000011") then 
                        -- They are all sign extended
                        imm_out <= std_logic_vector(resize(signed(i_type_imm), 32));
                    
                        if (funct3 = "000") then -- LB INSTR
                            rd_tmp <= rd; rs1_tmp <= rs1; operation <= LB_op;
                            --Load 8-bit value at memory address [rs1
                            --value]+(sign extended immediate) and
                            --store it at rd as a 32-bit sign extended value
                            --imm_extend_en           <= '1';  -- 0:zero ext / 1:sign ext
                            dat_extend_en           <= '1';  -- 0:zero ext / 1:sign ext
                            alu_input1_sel          <= '0';  -- 0:RS1 / 1:PC 
                            alu_input2_sel          <= '0';  -- 0:IMM / 1:RS2 
                            reg_input_from_pc_sel   <= '1';  -- 0:PC+4 / 1:ALU/DM
                            reg_input_from_alu_sel  <= '0';  -- 0:DM / 1:ALU  
                            dmem_rden               <= "01";  -- 0:no read / 1:read
                            
                        elsif (funct3 = "001") then -- LH INSTR
                            rd_tmp <= rd; rs1_tmp <= rs1; operation <= LH_op;
                            --Load 16-bit value at memory address [rs1
                            --value]+(sign extended immediate) and
                            --store it at rd as a 32-bit sign extended value                           
                            --imm_extend_en           <= '1';  -- 0:zero ext / 1:sign ext
                            dat_extend_en           <= '1';  -- 0:zero ext / 1:sign ext
                            alu_input1_sel          <= '0';  -- 0:RS1 / 1:PC 
                            alu_input2_sel          <= '0';  -- 0:IMM / 1:RS2 
                            reg_input_from_pc_sel   <= '1';  -- 0:PC+4 / 1:ALU/DM
                            reg_input_from_alu_sel  <= '0';  -- 0:DM / 1:ALU  
                            dmem_rden               <= "10";  -- 0:no read / 1:read
                            
                        elsif (funct3 = "010") then -- LW INSTR
                            rd_tmp <= rd; rs1_tmp <= rs1; operation <= LW_op;
                            --Load 32-bit value at memory address [rs1
                            --value]+(sign extended immediate) and
                            --store it at rd
                            --imm_extend_en           <= '1';  -- 0:zero ext / 1:sign ext
                            dat_extend_en           <= '0';  -- 0:zero ext / 1:sign ext                            
                            alu_input1_sel          <= '0';  -- 0:RS1 / 1:PC 
                            alu_input2_sel          <= '0';  -- 0:IMM / 1:RS2 
                            reg_input_from_pc_sel   <= '1';  -- 0:PC+4 / 1:ALU/DM
                            reg_input_from_alu_sel  <= '0';  -- 0:DM / 1:ALU  
                            dmem_rden               <= "11";  -- 0:no read / 1:read                                             
                            
                        elsif (funct3 = "100") then -- LBU INSTR
                            rd_tmp <= rd; rs1_tmp <= rs1; operation <= LBU_op;
                            --Load 8-bit value at memory address [rs1
                            --value]+(sign extended immediate) and
                            --store it at rd as a 32-bit zero extended value                            
                            --imm_extend_en           <= '1';  -- 0:zero ext / 1:sign ext
                            dat_extend_en           <= '0';  -- 0:zero ext / 1:sign ext // technically already zero extended
                            alu_input1_sel          <= '0';  -- 0:RS1 / 1:PC 
                            alu_input2_sel          <= '0';  -- 0:IMM / 1:RS2 
                            reg_input_from_pc_sel   <= '1';  -- 0:PC+4 / 1:ALU/DM
                            reg_input_from_alu_sel  <= '0';  -- 0:DM / 1:ALU  
                            dmem_rden               <= "01";  -- 0:no read / 1:read
                            
                        elsif (funct3 = "101") then -- LHU INSTR
                            rd_tmp <= rd;  rs1_tmp <= rs1; operation <= LHU_op;
                            --Load 16-bit value at memory address [rs1
                            --value]+(sign extended immediate) and
                            --store it at rd as a 32-bit zero extended value
                            --imm_extend_en           <= '1';  -- 0:zero ext / 1:sign ext
                            dat_extend_en           <= '0';  -- 0:zero ext / 1:sign ext // technically already zero extended
                            alu_input1_sel          <= '0';  -- 0:RS1 / 1:PC 
                            alu_input2_sel          <= '0';  -- 0:IMM / 1:RS2 
                            reg_input_from_pc_sel   <= '1';  -- 0:PC+4 / 1:ALU/DM
                            reg_input_from_alu_sel  <= '0';  -- 0:DM / 1:ALU  
                            dmem_rden               <= "10";  -- 0:no read / 1:read    
                        end if;  
                                              
---------------------- S TYPE INSTRUCTIONS    
                    elsif (op_code = "0100011") then   
                        -- All imm are sign extended, and rs2 (part or all) stored in data mem (Alu takes rs1 and imm)
                        imm_out <= std_logic_vector(resize(signed(s_type_imm), 32));
                        rs1_tmp <= rs1; rs2_tmp <= rs2; 
                        --imm_extend_en           <= '1';  -- 0:zero ext / 1:sign ext
                        alu_input1_sel          <= '0';  -- 0:RS1 / 1:PC 
                        alu_input2_sel          <= '0';  -- 0:IMM / 1:RS2      
                                                                                                                                            
                        if      (funct3 = "000") then operation <= SB_op;
                        elsif   (funct3 = "001") then operation <= SH_op;
                        elsif   (funct3 = "010") then operation <= SW_op;
                        end if;   
                        
---------------------- I TYPE INSTRUCTIONS (MORE)
                    elsif (op_code = "0010011") then   
                        -- SIgn extended imm
                        imm_out <= std_logic_vector(resize(signed(i_type_imm), 32));
                        rd_tmp <= rd;
                        rs1_tmp <= rs1;
                        -- IMM and RS1 Always used for these, always stored to Rd
                        --imm_extend_en           <= '1';  -- 0:zero ext / 1:sign ext
                        alu_input1_sel          <= '0';  -- 0:RS1 / 1:PC 
                        alu_input2_sel          <= '0';  -- 0:IMM / 1:RS2 
                        reg_input_from_alu_sel  <= '1';  -- 0:DM / 1:ALU 
                        reg_input_from_pc_sel   <= '1';  -- 0:PC+4 / 1:ALU/DM   
                        
                        -- See specification for details
                        if      (funct3 = "000") then operation <= ADDI_op;
                        elsif   (funct3 = "010") then operation <= SLTI_op;
                        elsif   (funct3 = "011") then operation <= SLTIU_op;
                        elsif   (funct3 = "100") then operation <= XORI_op;
                        elsif   (funct3 = "110") then operation <= ORI_op;
                        elsif   (funct3 = "111") then operation <= ANDI_op;
                        
                        elsif   (funct3 = "001") then -- SLLI INSTR
                        -- Zero extrended imm
                            imm_out <= std_logic_vector(resize(unsigned(i_type_imm(4 downto 0)), 32)); -- Shift amount
                            operation <= SLLI_op;
                            --imm_extend_en           <= '0';  -- 0:zero ext / 1:sign ext
                             
                        elsif (funct3 = "101") then -- SRLI/SRAI INSTR
                        -- zero extended imm
                            imm_out <= std_logic_vector(resize(unsigned(i_type_imm(4 downto 0)), 32));  -- Shift amount   
                            if (funct7 = "0000000") then 
                                operation <= SRLI_op; 
                            elsif (funct7 = "0100000") then 
                                operation <= SRAI_op; 
                            end if;
                            --imm_extend_en           <= '0';  -- 0:zero ext / 1:sign ext
                                                                                                        
                        end if;        
                        
---------------------- R TYPE INSTRUCTIONS   
                    elsif (op_code = "0110011") then   
                        rd_tmp <= rd; rs1_tmp <= rs1; rs2_tmp <= rs2;
                        -- Awlays use RS1 and RS2, Load to Rd
                        alu_input1_sel          <= '0';  -- 0:RS1 / 1:PC 
                        alu_input2_sel          <= '1';  -- 0:IMM / 1:RS2 
                        reg_input_from_alu_sel  <= '1';  -- 0:DM / 1:ALU 
                        reg_input_from_pc_sel   <= '1';  -- 0:PC+4 / 1:ALU/DM  
                                                                                                                                                                               
                        if      (funct3 = "000") then -- ADD/SUB INSTR   
                            if (funct7 = "0000000") then 
                                operation <= ADD_op; 
                            elsif (funct7 = "0100000") then 
                                operation <= SUB_op; 
                            end if;
                        elsif   (funct3 = "001") then operation <= SLL_op;
                        elsif   (funct3 = "010") then operation <= SLT_op;
                        elsif   (funct3 = "011") then operation <= SLTU_op;
                        elsif   (funct3 = "100") then operation <= XOR_op;
                        
                        elsif   (funct3 = "101") then -- SRL/SRA INSTR
                            if (funct7 = "0000000") then 
                                operation <= SRL_op; 
                            elsif (funct7 = "0100000") then 
                                operation <= SRA_op; 
                            end if;                            

                        elsif (funct3 = "110") then operation <= OR_op;
                        elsif (funct3 = "111") then operation <= AND_op;
                        end if;                    
                                        
---------------------- SPECIAL TYPE INSTRUCTIONS
                    elsif (op_code = "0001111") then -- FENCE INSTR    
                        rd_tmp <= "00000"; rs1_tmp <= "00000"; imm_out <= X"00000000"; operation <= ADDI_op;
                        alu_input1_sel          <= '0';  -- 0:RS1 / 1:PC       
                        alu_input2_sel          <= '0';  -- 0:IMM / 1:RS2      
                        reg_input_from_alu_sel  <= '1';  -- 0:DM / 1:ALU       
                        reg_input_from_pc_sel   <= '1';  -- 0:PC+4 / 1:ALU/DM  
    
                    elsif (op_code = "1110011") then -- ECALL/EBREAK INSTR
                        operation <= ECALL_op;
                        state <= ST_HALT;
                        
                    end if;
                    
                    if (op_code = "1110011") then -- ECALL/EBREAK INSTR
                        state <= ST_HALT;
                    else 
                        state <= ST_EXECUTE;
                    end if;
------------------------------------------------------- Execute ------------------------------------------------------                    
                WHEN ST_EXECUTE     => 
                    -- Default is no jump (pc_input_sel <= '1') set during decode
                    case operation is
                        WHEN LUI_op   =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN AUIPC_op =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN JAL_op   =>    reg_wren                <= '1';  -- 0:no write / 1:write
                                            pc_input_sel            <= '0';  -- 0:ALU / 1:PC+4 // jump                    
                        WHEN JALR_op  =>    reg_wren                <= '1';  -- 0:no write / 1:write  
                                            pc_input_sel            <= '0';  -- 0:ALU / 1:PC+4 // jump
                        WHEN BEQ_op   =>    if (i_do_branch = '1') then pc_input_sel <= '0'; end if; 
                        WHEN BNE_op   =>    if (i_do_branch = '1') then pc_input_sel <= '0'; end if;
                        WHEN BLT_op   =>    if (i_do_branch = '1') then pc_input_sel <= '0'; end if;
                        WHEN BGE_op   =>    if (i_do_branch = '1') then pc_input_sel <= '0'; end if;
                        WHEN BLTU_op  =>    if (i_do_branch = '1') then pc_input_sel <= '0'; end if;
                        WHEN BGEU_op  =>    if (i_do_branch = '1') then pc_input_sel <= '0'; end if;
                        WHEN LB_op    =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN LH_op    =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN LW_op    =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN LBU_op   =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN LHU_op   =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN SB_op    =>    dmem_wren               <= "0001";  -- 0:no write / 1:write 
                        WHEN SH_op    =>    dmem_wren               <= "0011";  -- 0:no write / 1:write 
                        WHEN SW_op    =>    dmem_wren               <= "1111";  -- 0:no write / 1:write 
                        WHEN ADDI_op  =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN SLTI_op  =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN SLTIU_op =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN XORI_op  =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN ORI_op   =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN ANDI_op  =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN SLLI_op  =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN SRLI_op  =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN SRAI_op  =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN ADD_op   =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN SUB_op   =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN SLL_op   =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN SLT_op   =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN SLTU_op  =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN XOR_op   =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN SRL_op   =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN SRA_op   =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN OR_op    =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN AND_op   =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN FENCE_op =>    reg_wren                <= '1';  -- 0:no write / 1:write
                        WHEN OTHERS => reg_wren                <= '0';
                    end case;
                    
                    state <= ST_INCREMENT;
                    
------------------------------------------------------- PC Ops ------------------------------------------------------                    
                WHEN ST_INCREMENT   => 
                    -- execution is finished
                    dmem_wren               <= "0000";  -- 0:no write / 1:write 
                    reg_wren                <= '0';
                    
                    -- Increment program counter
                    pc_wren <= '1';
                    state <= ST_FETCH;
                WHEN ST_HALT        =>
                    state <= ST_HALT;
                    operation <= NO_op;
            end case;
        end if;
    end process;


end Behavioral;