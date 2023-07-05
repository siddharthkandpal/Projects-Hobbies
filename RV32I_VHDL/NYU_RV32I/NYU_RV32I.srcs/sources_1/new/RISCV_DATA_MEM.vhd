---------------------------------------------------------------------------------
--      ECE-GY 6463 - RISCV32I Implementation - Memory Block 
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

entity RISCV_DATA_MEM is
    Port (      
            i_rst, i_clk    : in STD_LOGIC; 
            i_data          : in STD_LOGIC_VECTOR (31 downto 0); -- Input data must be right justified
            
            i_wr_en         : in STD_LOGIC_VECTOR(3 downto 0); -- "1111" writes to whole word "0001" writes byte
            i_rd_en         : in STD_LOGIC_VECTOR(1 downto 0); -- "11" reads to whole word "01" reads byte, "00" is no read
            
            i_addr          : in STD_LOGIC_VECTOR (31 downto 0);
            
            i_data_extend   : in STD_LOGIC; -- 0 for unsigned / 1 for signed
            
            i_input_switches: in std_logic_vector (23 downto 0); 
            o_output_leds   : out STD_LOGIC_VECTOR (31 downto 0);
            
            o_data     : out STD_LOGIC_VECTOR (31 downto 0)
            
           );
end RISCV_DATA_MEM;

architecture Behavioral of RISCV_DATA_MEM is
        
    -- Identity registers -- Start at addr 0x00100000 
    type ARR_32x5 is ARRAY (0 to 5) of STD_LOGIC_VECTOR (31 downto 0);
    signal id_mem : ARR_32x5 := (   X"17762874",  --00
                                    X"10799721",  --04
                                    X"16661513",  --08
                                    X"00000000",  --0C
                                    X"00000000",  --10 -- READ ONLY SWITCHES
                                    X"00000000"); --14 -- READ / WRITE LEDS
                                                          
    -- Memory Size is 4 kbytes --> 1024 words                           
    type ARR_32x1023 is ARRAY (0 to 1023) of STD_LOGIC_VECTOR (31 downto 0);
    signal data_mem : ARR_32x1023 := (OTHERS => X"00000000");
    
    signal mem_sel : STD_LOGIC_VECTOR(11 downto 0); 
    
    signal read_index : integer := 0;
    signal write_index  : integer := 0;
    
    signal current_data_idx_data : STD_LOGIC_VECTOR (31 downto 0);
    signal current_iden_idx_data : STD_LOGIC_VECTOR (31 downto 0);
    
    signal temp_output_signed_byte : STD_LOGIC_VECTOR (31 downto 0);
    signal temp_output_unsigned_byte : STD_LOGIC_VECTOR (31 downto 0);
    signal temp_output_signed_hword : STD_LOGIC_VECTOR (31 downto 0);
    signal temp_output_unsigned_hword : STD_LOGIC_VECTOR (31 downto 0);
    
    signal temp_extended_byte : STD_LOGIC_VECTOR (31 downto 0);
    signal temp_extended_hword : STD_LOGIC_VECTOR (31 downto 0);
    
    signal temp_output_byte : STD_LOGIC_VECTOR (7 downto 0);
    signal temp_output_hword : STD_LOGIC_VECTOR (15 downto 0);
    signal temp_output_word : STD_LOGIC_VECTOR (31 downto 0);

begin

    -- FPGA IO ops
    id_mem(4) <= std_logic_vector(resize(unsigned(i_input_switches), 32));
    o_output_leds <= id_mem(5);
    
    -- extending data ops
    mem_sel <= i_addr(31 downto 20);
    temp_output_signed_byte     <= std_logic_vector(resize(signed(temp_output_byte), 32));
    temp_output_unsigned_byte   <= std_logic_vector(resize(unsigned(temp_output_byte), 32));
    
    temp_output_signed_hword    <= std_logic_vector(resize(signed(temp_output_hword), 32));      
    temp_output_unsigned_hword  <= std_logic_vector(resize(unsigned(temp_output_hword), 32));
    
    temp_extended_byte  <= temp_output_unsigned_byte when i_data_extend <= '0' else temp_output_signed_byte;
    temp_extended_hword <= temp_output_unsigned_hword when i_data_extend <= '0' else temp_output_signed_hword;
    
    -- output ops   
    with (i_rd_en) select o_data <= 
       temp_extended_byte      when "01",
       temp_extended_hword     when "10",
       temp_output_word        when "11",
       X"00000000"             when OTHERS;
       
    -- Read ops
    read_index <= to_integer(unsigned(i_addr(19 downto 2)));    -- This used to be 19 downto 0
    current_data_idx_data <= data_mem(read_index) when (i_rd_en /= "00" or i_wr_en /= "0000");
    current_iden_idx_data <= id_mem(read_index) when (i_rd_en /= "00" or i_wr_en /= "0000");
    
    -- Write ops
    write_index        <= to_integer(unsigned(i_addr(19 downto 2)));
       
    read_proc : process (i_clk, i_rd_en) begin
        if (RISING_EDGE(i_clk) and i_rd_en /= "00") then
                if (mem_sel = X"001") then -- Identity read
                    case i_rd_en is   
                        when "01" => temp_output_byte <= STD_LOGIC_VECTOR(UNSIGNED(current_iden_idx_data(7 downto 0))); 
                        when "10" => temp_output_hword <= STD_LOGIC_VECTOR(UNSIGNED(current_iden_idx_data(15 downto 0)));                                    
                        when "11" => temp_output_word <= current_iden_idx_data;
                        when others => 
                    end case;     
                else 
                    case i_rd_en is   
                        when "01" => temp_output_byte <= STD_LOGIC_VECTOR(UNSIGNED(current_data_idx_data(7 downto 0))); 
                        when "10" => temp_output_hword <= STD_LOGIC_VECTOR(UNSIGNED(current_data_idx_data(15 downto 0))); 
                        when "11" => temp_output_word <= current_data_idx_data;
                        when others => 
                    end case;         
                end if;
            end if;    
    end process;
      
    write_proc : process (i_clk, i_wr_en) begin
        if (RISING_EDGE(i_clk) and i_wr_en /= "0000") then
            if (mem_sel = X"001" and write_index = 5) then
                id_mem(5) <= i_data;
            else 
                case i_wr_en is
                    when "0001" => data_mem(write_index)<= current_data_idx_data(31 downto 8) & i_data(7 downto 0); 
                    when "0011" => data_mem(write_index)<= current_data_idx_data(31 downto 16) & i_data(15 downto 0);
                    when "1111" => data_mem(write_index)<= i_data;
                    when others => 
                end case;
            end if;
        end if;
    end process;

end Behavioral;