//---------------------------------------------------------------------------------
//--      ECE-GY 6913 Computing Systems Architecture - RISC-V processor simulator
//--      Fall 2021
//--
//--      Md Raz          --  Siddharth Kandpal
//--      N17762874       --  N10799721
//--      mr4425@nyu.edu  --  sk8944@nyu.edu
//----------------------------------------------------------------------------------

#include <iostream>
#include <string>
#include <vector>
#include <bitset>
#include <fstream>

using namespace std;
#define MemSize 1000

struct IFStruct {
    bitset<32>  PC;
    bool        NOP;
};

struct IDStruct {
    bitset<32>  Instr;
    bool        NOP;
};

enum op_type {
	ADDI,
	XORI,
	ORI,
	ANDI,
	ADD,
	SUB,
	XOR,
	OR,
	AND
};

enum instr_type {
	r_type,
	i_type_imm,
	i_type_lw,
	j_type,
	b_type,
	s_type,
	halt
};

struct EXStruct {
    bitset<32>  Read_data1;
    bitset<32>  Read_data2;
    bitset<32>  Imm;
    bitset<5>   Rs;
    bitset<5>   Rt;
    bitset<5>   Wrt_reg_addr;
	op_type		alu_op;
	instr_type	instr;
    bool        is_I_type;
    bool        rd_mem;
    bool        wrt_mem;
    bool        wrt_enable;
    bool        NOP;
};

struct MEMStruct {
    bitset<32>  ALUresult;
    bitset<32>  Store_data;
    bitset<5>   Rs;
    bitset<5>   Rt;
    bitset<5>   Wrt_reg_addr;
    bool        rd_mem;
    bool        wrt_mem;
    bool        wrt_enable;
    bool        NOP;
};

struct WBStruct {
    bitset<32>  Wrt_data;
    bitset<5>   Rs;
    bitset<5>   Rt;
    bitset<5>   Wrt_reg_addr;
    bool        wrt_enable;
    bool        NOP;
};

struct stateStruct {
    IFStruct    IF;
    IDStruct    ID;
    EXStruct    EX;
    MEMStruct   MEM;
    WBStruct    WB;
};


class InsMem
{
	public:
		string id, ioDir;
        InsMem(string name, string ioDir) {
			id = name;
			IMem.resize(MemSize);
            ifstream imem;
			string line;
			int i=0;
			imem.open(ioDir + "\\imem.txt");
			if (imem.is_open())
			{
				while (getline(imem,line))
				{
					IMem[i] = bitset<8>(line);
					i++;
				}
			}
            else cout<<"Unable to open IMEM input file.";
			imem.close();
		}

		bitset<32> readInstr(bitset<32> ReadAddress) {
			// read instruction memory
			// return bitset<32> val
			// we will concatenate 4 lines of the inst mem to return 32 bits

            string instr_str;
            for (int i = 0; i < 4; i++) instr_str.append(IMem[ReadAddress.to_ulong() + i].to_string());
            return (bitset<32>(instr_str));
		}

    private:
        vector<bitset<8> > IMem;
};

class DataMem
{
    public:
		string id, opFilePath, ioDir;
        DataMem(string name, string ioDir) : id{name}, ioDir{ioDir} {
            DMem.resize(MemSize);
			opFilePath = ioDir + "\\" + name + "_DMEMResult.txt";
            ifstream dmem;
            string line;
            int i=0;
            dmem.open(ioDir + "\\dmem.txt");
            if (dmem.is_open())
            {
                while (getline(dmem,line))
                {
                    DMem[i] = bitset<8>(line);
                    i++;
                }
            }
            else cout<<"Unable to open DMEM input file.";
                dmem.close();
        }

        bitset<32> readDataMem(bitset<32> Address) {
			// read data memory
			// return bitset<32> val

            // we will concatenate 4 lines of the dat mem to return 32 bits
            string dat_str;
            for (int i = 0; i < 4; i++) dat_str.append(DMem[Address.to_ulong() + i].to_string());
            return ((bitset<32>)dat_str);
		}

        void writeDataMem(bitset<32> Address, bitset<32> WriteData) {
			//We will break down the incoming 32 bits and write 8 bits at a time
			 for (int i = 0; i < 4; i++)	{
			 	DMem[Address.to_ulong() + i] = bitset<8>(WriteData.to_string().substr((8 * i), 8));
			 }

        }

        void outputDataMem() {
            ofstream dmemout;
            dmemout.open(opFilePath, std::ios_base::trunc);
            if (dmemout.is_open()) {
                for (int j = 0; j< 1000; j++)
                {
                    dmemout << DMem[j]<<endl;
                }

            }
            else cout<<"Unable to open "<<id<<" DMEM result file." << endl;
            dmemout.close();
        }

    private:
		vector<bitset<8> > DMem;
};

class RegisterFile
{
    public:
		string outputFile;
     	RegisterFile(string ioDir): outputFile {ioDir + "RFResult.txt"} {
			Registers.resize(32);
			Registers[0] = bitset<32> (0);
        }

        bitset<32> readRF(bitset<5> Reg_addr) {
            // We will return a 32-bit bitset, reading from the Reg_addr
            return Registers[Reg_addr.to_ulong()];
        }

        void writeRF(bitset<5> Reg_addr, bitset<32> Wrt_reg_data) {
            // We will write the 32 bit reg data to the Reg_Addr
            Registers[Reg_addr.to_ulong()] = Wrt_reg_data.to_ullong();
            Registers[0] = bitset<32> (0); // Ensure reg0 stays 0 val
        }

		void outputRF(int cycle) {
			ofstream rfout;
			if (cycle == 0)
				rfout.open(outputFile, std::ios_base::trunc);
			else
				rfout.open(outputFile, std::ios_base::app);
			if (rfout.is_open())
			{
				rfout<<"State of RF after executing cycle:\t"<<cycle<<endl;
				for (int j = 0; j<32; j++)
				{
					rfout<<Registers[j]<<endl;
				}
			}
			else cout<<"Unable to open RF output file."<<endl;
			rfout.close();
		}

	private:
		vector<bitset<32> >Registers;
};

class Core {
	public:
		RegisterFile myRF;
		uint32_t cycle = 0;
		uint32_t instr_count = 0;
		bool halted = false;
		bool is_first_cycle = true;
		bool debug_mode = false;
		bool stall = false;
		bool forward = false;
		string ioDir;
		struct stateStruct state, nextState;
		InsMem ext_imem;
		DataMem ext_dmem;

		Core(string ioDir, InsMem &imem, DataMem &dmem): myRF(ioDir), ioDir{ioDir}, ext_imem {imem}, ext_dmem {dmem} {}

		virtual void step() {}

		virtual void printState() {}
};

class SingleStageCore : public Core {
	public:
		SingleStageCore(string ioDir, InsMem &imem, DataMem &dmem): Core(ioDir + "\\SS_", imem, dmem), opFilePath(ioDir + "\\StateResult_SS.txt") {}

		void step() {
			/* Your implementation*/
			// We will use the given state structs above.

            if(is_first_cycle){
                state.IF.PC = (bitset<32>)0;
				state.IF.NOP =  false;
				is_first_cycle = false;
			}

			if (state.IF.NOP) {
				halted = true;
				cout << "Processor Halted\n";
			}

			if(!halted){
				// Retrieve instr
				if(debug_mode & (!halted)) cout << "\nPC =  "<<state.IF.PC.to_ulong()<<"  \t-->\t";
				state.ID.Instr = ext_imem.readInstr(state.IF.PC);

				// Decipher the instruction
				string opcode = state.ID.Instr.to_string().substr(25,7);
				string func7 = state.ID.Instr.to_string().substr(0,7);
				string func3 = state.ID.Instr.to_string().substr(17,3);

				// RS1 set
				state.EX.Rs = bitset<5>(state.ID.Instr.to_string().substr(12,5));
				state.EX.Read_data1 = myRF.readRF(state.EX.Rs);

				// Rs2 set
				state.EX.Rt = bitset<5>(state.ID.Instr.to_string().substr(7,5));
				state.EX.Read_data2 = myRF.readRF(state.EX.Rt);

				// Rd set
				state.EX.Wrt_reg_addr = bitset<5>(state.ID.Instr.to_string().substr(20,5));

				// Temporary imm ops
				bitset<12> temp_imm_s; bitset<12> temp_imm_b; bitset<20> temp_imm_j;

				// Opcode --> Instr type
				if		(opcode == "0110011") {state.EX.instr = r_type;}
				else if (opcode == "0010011") {state.EX.instr = i_type_imm;}
				else if (opcode == "0000011") {state.EX.instr = i_type_lw;}
				else if (opcode == "1101111") {state.EX.instr = j_type;}
				else if (opcode == "1100011") {state.EX.instr = b_type;}
				else if (opcode == "0100011") {state.EX.instr = s_type;}
				else if (opcode == "1111111") {state.EX.instr = halt;}

				if(state.EX.instr != halt){
					state.IF.PC = (bitset<32>(state.IF.PC.to_ulong() + 4)); // Premptivly Pc = PC + 4
					instr_count++;
				}

				switch(state.EX.instr){

					case r_type: if(debug_mode) cout << "Executing R type instr\n";
						// Control signal set
						state.EX.is_I_type = false;

						// Mem control set
						state.EX.rd_mem = false;
						state.EX.wrt_mem = false;

						//Set alu op
						if (func7 == "0100000") {state.EX.alu_op = SUB;
						} else {
							if (func3 == "100") { state.EX.alu_op = XOR;
							} else if (func3 == "110") { state.EX.alu_op = OR;
							} else if (func3 == "111") { state.EX.alu_op = AND;
							} else { state.EX.alu_op = ADD;
							}
						}

						// Write to Rd?
						state.EX.wrt_enable = true;

						break;

					case i_type_imm: if(debug_mode) cout << "Executing I IMM type instr\n";
						// Control signal set
						state.EX.is_I_type = true;	state.EX.rd_mem = false; state.EX.wrt_mem = false;
						
						//Set alu op
						if (	   func3 == "100") { state.EX.alu_op = XORI;
						} else if (func3 == "110") { state.EX.alu_op = ORI;
						} else if (func3 == "111") { state.EX.alu_op = ANDI;
						} else { state.EX.alu_op = ADDI;
						}

						//Sign extend and load the immediate
						state.EX.Imm = 	 (((bitset<1>)(state.ID.Instr.to_string().substr(0,1))).to_ulong())
										? ((bitset<32>)(string(20,'1') + state.ID.Instr.to_string().substr(0,12))) 
										: ((bitset<32>)(state.ID.Instr.to_string().substr(0,12)));		

						// Rd set
						state.EX.wrt_enable = true;
						break;

					case i_type_lw: if(debug_mode) cout << "Executing I LW type instr\n";
						// Control signal set
						state.EX.is_I_type = true;
						state.EX.rd_mem = true; // We will write to mem
						state.EX.wrt_mem = false; // we will not read from mem
						state.EX.alu_op = ADDI;

						//Sign extend and load the immediate
						state.EX.Imm = 	 (((bitset<1>)(state.ID.Instr.to_string().substr(0,1))).to_ulong())?
											((bitset<32>)(string(20,'1') + state.ID.Instr.to_string().substr(0,12))) 
										: ((bitset<32>)(state.ID.Instr.to_string().substr(0,12)));

						// Rd set
						state.EX.wrt_enable = true;
						break;
						
					case j_type: if(debug_mode) cout << "Executing J type instr\n";
						// Control signal set
						state.EX.is_I_type = false;
						state.EX.rd_mem    = false; // We will write to mem
						state.EX.wrt_mem   = false; // we will not read from mem
						
						// Set ALU OP
						state.EX.alu_op = ADDI;

						// Descramble the 20 bit IMM<20|10:1|11|19:12>
						temp_imm_j = (bitset<20>  (	state.ID.Instr.to_string().substr(0, 1) + // Bit 20
																state.ID.Instr.to_string().substr(12, 8) + // Bit 19:12
																state.ID.Instr.to_string().substr(11, 1) + // bit 11
																state.ID.Instr.to_string().substr(1, 10)	).to_ulong()); // bits 10:1

						temp_imm_j <<= 1;

						//Sign extend and load the immediate
						state.EX.Imm = 	  (((bitset<1>)(temp_imm_j.to_string().substr(0,1))).to_ulong())
										? ((bitset<32>)(string(12,'1') + temp_imm_j.to_string().substr(0,20))) 
										: ((bitset<32>)(temp_imm_j.to_string().substr(0,20)));

						state.EX.Read_data1 = state.IF.PC;  //RS1 = Current PC + 4

						state.EX.wrt_enable = true;		

						// Discard instruction fetched this cycle, update PC
						state.IF.PC = bitset<32>(state.IF.PC.to_ulong() + state.EX.Imm.to_ulong() - 4);
						cout<<"Jump and Link Taken\n";
						break;

					case b_type: if(debug_mode) cout << "Executing B type instr\n";
						// Control signal set
						state.EX.is_I_type = false;
						state.EX.rd_mem    = false; // We will write to mem
						state.EX.wrt_mem   = false; // we will not read from mem
						state.EX.wrt_enable = false;

						// Descramble the 12 bit IMM<12|10:5>   <4:1|11>	
						// The imm exists in instruction bits 31:25, 11:7, 	--> 7 bits, 5 bits
						temp_imm_b = (bitset<12>  (	state.ID.Instr.to_string().substr(0, 1) + // Bit 12
																state.ID.Instr.to_string().substr(24, 1) + // Bit 11
																state.ID.Instr.to_string().substr(1, 6) + // Bits 10:5 
																state.ID.Instr.to_string().substr(20, 4)	).to_ulong()); // bits 4:1

						temp_imm_b <<= 1;

						//Sign extend and load the immediate
						state.EX.Imm = 	 (((bitset<1>)(temp_imm_b.to_string().substr(0,1))).to_ulong())
										? ((bitset<32>)(string(20,'1') + temp_imm_b.to_string().substr(0,12))) 
										: ((bitset<32>)(temp_imm_b.to_string().substr(0,12)));

						cout<<"RS1 = "<<(int)state.EX.Read_data1.to_ulong()<<", RS2 = "<<(int)state.EX.Read_data2.to_ulong()<<"\n"; 

						// We will resolve the branch here:
						if ((func3 == "000") & (state.EX.Read_data1 == state.EX.Read_data2)) { //BEQ
							// Discard instruction fetched this cycle, update PC
							state.IF.PC = bitset<32>(state.IF.PC.to_ulong() + state.EX.Imm.to_ulong() - 4);
							cout<<"Branch Taken: BEQ\n";

						} else if ((func3 == "001") & (state.EX.Read_data1 != state.EX.Read_data2)) { //BNE
							// Discard instruction fetched this cycle, update PC & instr from prev cycle
							state.IF.PC = bitset<32>(state.IF.PC.to_ulong() + state.EX.Imm.to_ulong() - 4);
							cout<<"Branch Taken: BNE\n";

						} else {
							cout << "No Branch Taken\n";
						}

						break;
						
					case s_type: if(debug_mode) cout << "Executing S type instr\n";
						// Control signal set
						state.EX.is_I_type = false;
						state.EX.rd_mem    = false; 
						state.EX.wrt_mem   = true; 
						state.EX.wrt_enable = false;

						// Set ALU OP
						state.EX.alu_op = ADDI;

						// Descramble the 12 bit IMM<11:5>  <4:0>
						temp_imm_s = (bitset<12> (state.ID.Instr.to_string().substr(0, 7) + // Bits 11:5
												state.ID.Instr.to_string().substr(20, 5)).to_ulong()); //bits 4:0

						//Sign extend and load the immediate
						state.EX.Imm = 	 (((bitset<1>)(temp_imm_s.to_string().substr(0,1))).to_ulong())
										? ((bitset<32>)(string(20,'1') + temp_imm_s.to_string().substr(0,12))) 
										: ((bitset<32>)(temp_imm_s.to_string().substr(0,12)));	
						break;

					default: if(debug_mode) cout << "Executing HALT instr\n";
						state.IF.NOP = true;

						state.EX.rd_mem    = false;
						state.EX.wrt_mem   = false; 
						state.EX.wrt_enable = false;
						break;		

				}


				/*---------------------------------- EXEC / MEM / WB ---------------------------------------*/
				if((state.EX.instr != j_type)&((state.EX.instr != b_type))){
					switch(state.EX.alu_op){
						case ADDI:
							state.MEM.ALUresult = bitset<32>(state.EX.Read_data1.to_ulong() + state.EX.Imm.to_ulong()); break;
						case XORI:
							state.MEM.ALUresult = bitset<32>(state.EX.Read_data1.to_ulong() ^ state.EX.Imm.to_ulong()); break;
						case ORI:
							state.MEM.ALUresult = bitset<32>(state.EX.Read_data1.to_ulong() | state.EX.Imm.to_ulong()); break;
						case ANDI: 
							state.MEM.ALUresult = bitset<32>(state.EX.Read_data1.to_ulong() & state.EX.Imm.to_ulong()); break;
						case ADD:
							state.MEM.ALUresult = bitset<32>(state.EX.Read_data1.to_ulong() + state.EX.Read_data2.to_ulong()); break;
						case SUB:
							state.MEM.ALUresult = bitset<32>(state.EX.Read_data1.to_ulong() - state.EX.Read_data2.to_ulong()); break;
						case XOR:
							state.MEM.ALUresult = bitset<32>(state.EX.Read_data1.to_ulong() ^ state.EX.Read_data2.to_ulong()); break;
						case OR:
							state.MEM.ALUresult = bitset<32>(state.EX.Read_data1.to_ulong() | state.EX.Read_data2.to_ulong()); break;
						case AND:
							state.MEM.ALUresult = bitset<32>(state.EX.Read_data1.to_ulong() & state.EX.Read_data2.to_ulong()); break;
					}
				} else if(state.EX.instr == j_type){
							state.MEM.ALUresult = state.EX.Read_data1; // We use this for WB during JAL
				}

				// Set mem config for next stage
				state.MEM.Store_data 	= state.EX.Read_data2;
				state.MEM.Rt 			= state.EX.Rt;
				state.MEM.Rs 			= state.EX.Rs;
				state.MEM.Wrt_reg_addr 	= state.EX.Wrt_reg_addr;
				state.MEM.rd_mem 		= state.EX.rd_mem;
				state.MEM.wrt_mem 		= state.EX.wrt_mem;
				state.MEM.wrt_enable 	= state.EX.wrt_enable;

				// If mem read/write == true, read/write it
				if(state.MEM.rd_mem){ // LW type				
					state.WB.Wrt_data = ext_dmem.readDataMem(state.MEM.ALUresult);
				} else if(state.MEM.wrt_mem){ // SW Type
					ext_dmem.writeDataMem(state.MEM.ALUresult,state.MEM.Store_data);
					state.WB.Wrt_data=state.MEM.Store_data;

					cout<<"Write data: "<<state.MEM.Store_data<<"\n";
					cout<<"Write addr: "<<state.MEM.ALUresult<<"\n";
					cout<<"Written dat: "<<ext_dmem.readDataMem(state.MEM.ALUresult)<<"\n";
					
				} else 	{ // R TYPE
					state.WB.Wrt_data = state.MEM.ALUresult;
				}

				// Set WB Config for next cycle
				state.WB.Rs				= state.MEM.Rs;
				state.WB.Rt				= state.MEM.Rt;
				state.WB.Wrt_reg_addr	= state.MEM.Wrt_reg_addr;
				state.WB.wrt_enable		= state.MEM.wrt_enable;

				//writeback: if writeback == true, write to reg
				if(state.WB.wrt_enable)  myRF.writeRF(state.WB.Wrt_reg_addr, state.WB.Wrt_data);
			}

			myRF.outputRF(cycle); // dump RF per cycle
			if(halted) ext_dmem.outputDataMem();

			printState(state, cycle);
			cycle++;

		}

		void printState(stateStruct state, int cycle) {
    		ofstream printstate;
			if (cycle == 0)
				printstate.open(opFilePath, std::ios_base::trunc);
			else
    			printstate.open(opFilePath, std::ios_base::app);
    		if (printstate.is_open()) {
    		    printstate<<"State after executing cycle:\t"<<cycle<<endl;

    		    printstate<<"IF.PC:\t"<<state.IF.PC.to_ulong()<<endl;
    		    printstate<<"IF.NOP:\t"<<state.IF.NOP<<endl;
    		}
    		else cout<<"Unable to open SS StateResult output file." << endl;
    		printstate.close();
		}
	private:
		string opFilePath;
};

class FiveStageCore : public Core{
	public:

		FiveStageCore(string ioDir, InsMem &imem, DataMem &dmem): Core(ioDir + "\\FS_", imem, dmem), opFilePath(ioDir + "\\StateResult_FS.txt") {}

		void step() {
			/* Your implementation */
			// We will use the given state structs above.

            if(is_first_cycle){
				// Reset PC on init, set intial states
                state.IF.PC = (bitset<32>) 0;
				state.IF.NOP =  false;
				state.ID.NOP =  true;
				state.EX.NOP =  true;
                state.MEM.NOP = true;
                state.WB.NOP =  true;

				is_first_cycle = false;
			}

			cout<<"\nCycle: "<<cycle<<"\n";

			/* --------------------- WB stage --------------------- */
			if(!state.WB.NOP){
				//writeback: if writeback == true, write to reg
				if(state.WB.wrt_enable)  {
					
					myRF.writeRF(state.WB.Wrt_reg_addr, state.WB.Wrt_data);
				}
			} state.WB.NOP = state.MEM.NOP;
			/* --------------------- MEM stage -------------------- */
			if(!state.MEM.NOP){
				// If mem read/write == true, read/write it
				if(state.MEM.rd_mem){ // LW type				
					state.WB.Wrt_data = ext_dmem.readDataMem(state.MEM.ALUresult);
				} else if(state.MEM.wrt_mem){ // SW Type
					ext_dmem.writeDataMem(state.MEM.ALUresult,state.MEM.Store_data);
					state.WB.Wrt_data=state.MEM.Store_data;

					cout<<"Write data: "<<state.MEM.Store_data<<"\n";
					cout<<"Write addr: "<<state.MEM.ALUresult<<"\n";
					cout<<"Written dat: "<<ext_dmem.readDataMem(state.MEM.ALUresult)<<"\n";
					
				} else 	{ // R TYPE
					state.WB.Wrt_data = state.MEM.ALUresult;
				}

				// Set WB Config for next cycle
				state.WB.Rs				= state.MEM.Rs;
				state.WB.Rt				= state.MEM.Rt;
				state.WB.Wrt_reg_addr	= state.MEM.Wrt_reg_addr;
				state.WB.wrt_enable		= state.MEM.wrt_enable;
				

			} state.MEM.NOP = state.EX.NOP;
			/* --------------------- EX stage --------------------- */
			if(!state.EX.NOP){
				if((state.EX.instr != j_type)&((state.EX.instr != b_type))){
					switch(state.EX.alu_op){
						case ADDI:
							state.MEM.ALUresult = bitset<32>(state.EX.Read_data1.to_ulong() + state.EX.Imm.to_ulong()); break;
						case XORI:
							state.MEM.ALUresult = bitset<32>(state.EX.Read_data1.to_ulong() ^ state.EX.Imm.to_ulong()); break;
						case ORI:
							state.MEM.ALUresult = bitset<32>(state.EX.Read_data1.to_ulong() | state.EX.Imm.to_ulong()); break;
						case ANDI: 
							state.MEM.ALUresult = bitset<32>(state.EX.Read_data1.to_ulong() & state.EX.Imm.to_ulong()); break;
						case ADD:
							state.MEM.ALUresult = bitset<32>(state.EX.Read_data1.to_ulong() + state.EX.Read_data2.to_ulong()); break;
						case SUB:
							state.MEM.ALUresult = bitset<32>(state.EX.Read_data1.to_ulong() - state.EX.Read_data2.to_ulong()); break;
						case XOR:
							state.MEM.ALUresult = bitset<32>(state.EX.Read_data1.to_ulong() ^ state.EX.Read_data2.to_ulong()); break;
						case OR:
							state.MEM.ALUresult = bitset<32>(state.EX.Read_data1.to_ulong() | state.EX.Read_data2.to_ulong()); break;
						case AND:
							state.MEM.ALUresult = bitset<32>(state.EX.Read_data1.to_ulong() & state.EX.Read_data2.to_ulong()); break;
					}
				} else if(state.EX.instr == j_type){
							state.MEM.ALUresult = state.EX.Read_data1;
				}

				// Set mem config for next stage
				state.MEM.Store_data 	= state.EX.Read_data2;
				state.MEM.Rt 			= state.EX.Rt;
				state.MEM.Rs 			= state.EX.Rs;
				state.MEM.Wrt_reg_addr 	= state.EX.Wrt_reg_addr;
				state.MEM.rd_mem 		= state.EX.rd_mem;
				state.MEM.wrt_mem 		= state.EX.wrt_mem;
				state.MEM.wrt_enable 	= state.EX.wrt_enable;

				if(state.EX.instr == halt){
						state.IF.NOP = true;
						state.ID.NOP = true;
						state.EX.NOP = true;
				}

			} state.EX.NOP = state.ID.NOP;
			/* --------------------- ID stage --------------------- */
			if(!state.ID.NOP){
				// Decipher the instruction
				string opcode = state.ID.Instr.to_string().substr(25,7);
				string func7 = state.ID.Instr.to_string().substr(0,7);
				string func3 = state.ID.Instr.to_string().substr(17,3);

				// RS1 set
				state.EX.Rs = bitset<5>(state.ID.Instr.to_string().substr(12,5));
				state.EX.Read_data1 = myRF.readRF(state.EX.Rs);

				// Rs2 set
				state.EX.Rt = bitset<5>(state.ID.Instr.to_string().substr(7,5));
				state.EX.Read_data2 = myRF.readRF(state.EX.Rt);

				// Rd set
				state.EX.Wrt_reg_addr = bitset<5>(state.ID.Instr.to_string().substr(20,5));

				// Check if there will be a load use hazard:
				// If prev inst was LW and Prev RD is current RS1//RS2
				if((state.EX.instr == i_type_lw) & ((state.MEM.Wrt_reg_addr==state.EX.Rs)|(state.MEM.Wrt_reg_addr==state.EX.Rt))){
					stall = true;
					state.ID.NOP = true;
					cout<<"--- STALL ---\n";
				} 


				forward = false; // Set forward = false before fwd check

				if((!stall)&(cycle>2)){
					// Forward ops: PREV EX --> NEXT EX 
					// Rd from MEM input == RS1 or RS2 : forward the Rd data here, overwrite prev val
					if (state.MEM.Wrt_reg_addr == state.EX.Rs){
						cout<<"FORWARD: EX-->EX, RS1\n";	state.EX.Read_data1 = state.MEM.ALUresult;
						forward = true;
					}
					if (state.MEM.Wrt_reg_addr == state.EX.Rt){
						cout<<"FORWARD: EX-->EX, RS2\n";	state.EX.Read_data2 = state.MEM.ALUresult;
						forward = true;
					}

					// Forward ops: PREV MEM --> NEXT EX 	
					// Rd from WB input == RS1 or RS2 : forward the Rd data here, overwrite prev val
					if ((state.WB.Wrt_reg_addr == state.EX.Rs) & (!forward)){
						cout<<"FORWARD: MEM-->EX, RS1\n";
						state.EX.Read_data1 = state.WB.Wrt_data;

					}
					if ((state.WB.Wrt_reg_addr == state.EX.Rt) & (!forward)){
						cout<<"FORWARD: MEM-->EX, RS2\n"; 
						state.EX.Read_data2 = state.WB.Wrt_data;

					}
					
				}

				// Temporary imm ops
				bitset<12> temp_imm_s; bitset<12> temp_imm_b; bitset<20> temp_imm_j;

				if		(opcode == "0110011") {state.EX.instr = r_type;}
				else if (opcode == "0010011") {state.EX.instr = i_type_imm;}
				else if (opcode == "0000011") {state.EX.instr = i_type_lw;}
				else if (opcode == "1101111") {state.EX.instr = j_type;}
				else if (opcode == "1100011") {state.EX.instr = b_type;}
				else if (opcode == "0100011") {state.EX.instr = s_type;}
				else if (opcode == "1111111") {state.EX.instr = halt;}
				
				switch(state.EX.instr){

					case r_type: cout << "Executing R type instr\n";
						// Control signal set
						state.EX.is_I_type = false;

						// Mem control set
						state.EX.rd_mem = false;
						state.EX.wrt_mem = false;

						//Set alu op
						if (func7 == "0100000") {state.EX.alu_op = SUB;
						} else {
							if (func3 == "100") { state.EX.alu_op = XOR;
							} else if (func3 == "110") { state.EX.alu_op = OR;
							} else if (func3 == "111") { state.EX.alu_op = AND;
							} else { state.EX.alu_op = ADD;
							}
						}

						// Write to Rd?
						state.EX.wrt_enable = true;

						break;

					case i_type_imm: cout << "Executing I IMM type instr\n";
						// Control signal set
						state.EX.is_I_type = true;	state.EX.rd_mem = false; state.EX.wrt_mem = false;
						
						//Set alu op
						if (	   func3 == "100") { state.EX.alu_op = XORI;
						} else if (func3 == "110") { state.EX.alu_op = ORI;
						} else if (func3 == "111") { state.EX.alu_op = ANDI;
						} else { state.EX.alu_op = ADDI;
						}

						//Sign extend and load the immediate
						state.EX.Imm = 	 (((bitset<1>)(state.ID.Instr.to_string().substr(0,1))).to_ulong())
										? ((bitset<32>)(string(20,'1') + state.ID.Instr.to_string().substr(0,12))) 
										: ((bitset<32>)(state.ID.Instr.to_string().substr(0,12)));		

						// Rd set
						state.EX.wrt_enable = true;
						break;

					case i_type_lw: cout << "Executing I LW type instr\n";
						// Control signal set
						state.EX.is_I_type = true;
						state.EX.rd_mem = true; // We will write to mem
						state.EX.wrt_mem = false; // we will not read from mem
						state.EX.alu_op = ADDI;

						//Sign extend and load the immediate
						state.EX.Imm = 	 (((bitset<1>)(state.ID.Instr.to_string().substr(0,1))).to_ulong())?
											((bitset<32>)(string(20,'1') + state.ID.Instr.to_string().substr(0,12))) 
										: ((bitset<32>)(state.ID.Instr.to_string().substr(0,12)));

						// Rd set
						state.EX.wrt_enable = true;
						break;
						
					case j_type: cout << "Executing J type instr\n";
						// Control signal set
						state.EX.is_I_type = false;
						state.EX.rd_mem    = false; // We will write to mem
						state.EX.wrt_mem   = false; // we will not read from mem

						// Set ALU OP
						state.EX.alu_op = ADDI;

						// Descramble the 20 bit IMM<20|10:1|11|19:12>
						temp_imm_j = (bitset<20>  (	state.ID.Instr.to_string().substr(0, 1) + // Bit 20
																state.ID.Instr.to_string().substr(12, 8) + // Bit 19:12
																state.ID.Instr.to_string().substr(11, 1) + // bit 11
																state.ID.Instr.to_string().substr(1, 10)	).to_ulong()); // bits 10:1

						temp_imm_j <<= 1;

						//Sign extend and load the immediate
						state.EX.Imm = 	  (((bitset<1>)(temp_imm_j.to_string().substr(0,1))).to_ulong())
										? ((bitset<32>)(string(12,'1') + temp_imm_j.to_string().substr(0,20))) 
										: ((bitset<32>)(temp_imm_j.to_string().substr(0,20)));

						state.EX.Read_data1 = state.IF.PC;  //RS1 = Current PC + 4

						state.EX.wrt_enable = true;		

						// Discard instruction fetched this cycle, update PC
						state.IF.PC = bitset<32>(state.IF.PC.to_ulong() + state.EX.Imm.to_ulong() - 4);
						state.ID.Instr = ext_imem.readInstr(state.IF.PC);
						cout<<"Jump and Link Taken\n";
						break;

					case b_type: cout << "Executing B type instr\n";
						// Control signal set
						state.EX.is_I_type = false;
						state.EX.rd_mem    = false; // We will write to mem
						state.EX.wrt_mem   = false; // we will not read from mem
						state.EX.wrt_enable = false;

						// Descramble the 12 bit IMM<12|10:5>   <4:1|11>	
						// The imm exists in instruction bits 31:25, 11:7, 	--> 7 bits, 5 bits
						temp_imm_b = (bitset<12>  (	state.ID.Instr.to_string().substr(0, 1) + // Bit 12
																state.ID.Instr.to_string().substr(24, 1) + // Bit 11
																state.ID.Instr.to_string().substr(1, 6) + // Bits 10:5 
																state.ID.Instr.to_string().substr(20, 4)	).to_ulong()); // bits 4:1

						temp_imm_b <<= 1;

						//Sign extend and load the immediate
						state.EX.Imm = 	 (((bitset<1>)(temp_imm_b.to_string().substr(0,1))).to_ulong())
										? ((bitset<32>)(string(20,'1') + temp_imm_b.to_string().substr(0,12))) 
										: ((bitset<32>)(temp_imm_b.to_string().substr(0,12)));

						cout<<"RS1 = "<<(int)state.EX.Read_data1.to_ulong()<<", RS2 = "<<(int)state.EX.Read_data2.to_ulong()<<"\n"; 

						// We will resolve the branch here:
						if ((func3 == "000") & (state.EX.Read_data1 == state.EX.Read_data2)) { //BEQ
							// Discard instruction fetched this cycle, update PC
							state.IF.PC = bitset<32>(state.IF.PC.to_ulong() + state.EX.Imm.to_ulong() - 4);
							//state.ID.Instr = ext_imem.readInstr(state.IF.PC);
							//stall = true;
							state.EX.NOP = true;
							cout<<"Branch Taken: BEQ\n";

						} else if ((func3 == "001") & (state.EX.Read_data1 != state.EX.Read_data2)) { //BNE
							// Discard instruction fetched this cycle, update PC & instr from prev cycle
							state.IF.PC = bitset<32>(state.IF.PC.to_ulong() + state.EX.Imm.to_ulong() - 4);
							state.EX.NOP = true;
							cout<<"Branch Taken: BNE\n";
						} else {
							cout << "No Branch Taken\n";
						}
						break;
						
					case s_type: cout << "Executing S type instr\n";
						// Control signal set
						state.EX.is_I_type = false;
						state.EX.rd_mem    = false; 
						state.EX.wrt_mem   = true; 
						state.EX.wrt_enable = false;

						// Set ALU OP
						state.EX.alu_op = ADDI;

						// Descramble the 12 bit IMM<11:5>  <4:0>
						temp_imm_s = (bitset<12> (state.ID.Instr.to_string().substr(0, 7) + // Bits 11:5
												state.ID.Instr.to_string().substr(20, 5)).to_ulong()); //bits 4:0

						//Sign extend and load the immediate
						state.EX.Imm = 	 (((bitset<1>)(temp_imm_s.to_string().substr(0,1))).to_ulong())
										? ((bitset<32>)(string(20,'1') + temp_imm_s.to_string().substr(0,12))) 
										: ((bitset<32>)(temp_imm_s.to_string().substr(0,12)));	
						break;

					default: cout << "Executing HALT instr\n";
						// Halt // Error
						
						state.EX.rd_mem    = false;
						state.EX.wrt_mem   = false; 
						state.EX.wrt_enable = false;
						break;		

				}
			} if(!stall) state.ID.NOP = state.IF.NOP;
			

			/* --------------------- IF stage --------------------- */
			if(!state.IF.NOP){
				if(stall){
					stall = false;
					// Execute the prev stalled instruction again
					state.ID.NOP = state.IF.NOP;
				} else {
					state.ID.Instr = ext_imem.readInstr(state.IF.PC);
					state.IF.PC = (bitset<32>(state.IF.PC.to_ulong() + 4));
					instr_count++;
				}
			} 
			/* --------------------- 5 Stage End ------------------- */

		

			if (state.IF.NOP && state.ID.NOP && state.EX.NOP && state.MEM.NOP && state.WB.NOP){
				halted = true;
				ext_dmem.outputDataMem();
			}
            myRF.outputRF(cycle); // dump RF
			printState(state, cycle); //print states after executing cycle 0, cycle 1, cycle 2 ...

			cycle++;
		}

		void printState(stateStruct state, int cycle) {
		    ofstream printstate;
			if (cycle == 0)
				printstate.open(opFilePath, std::ios_base::trunc);
			else
		    	printstate.open(opFilePath, std::ios_base::app);
		    if (printstate.is_open()) {
		        printstate<<"\nState after executing cycle:\t"<<cycle<<endl;

		        printstate<<"IF.PC:\t"<<state.IF.PC.to_ulong()<<endl;
		        printstate<<"IF.NOP:\t"<<state.IF.NOP<<endl;

		        printstate<<"ID.Instr:\t"<<state.ID.Instr<<endl;
		        printstate<<"ID.NOP:\t"<<state.ID.NOP<<endl;

		        printstate<<"EX.Read_data1:\t"<<state.EX.Read_data1<<endl;
		        printstate<<"EX.Read_data2:\t"<<state.EX.Read_data2<<endl;
		        printstate<<"EX.Imm:\t"<<state.EX.Imm<<endl;
		        printstate<<"EX.Rs:\t"<<state.EX.Rs<<endl;
		        printstate<<"EX.Rt:\t"<<state.EX.Rt<<endl;
		        printstate<<"EX.Wrt_reg_addr:\t"<<state.EX.Wrt_reg_addr<<endl;
		        printstate<<"EX.is_I_type:\t"<<state.EX.is_I_type<<endl;
		        printstate<<"EX.rd_mem:\t"<<state.EX.rd_mem<<endl;
		        printstate<<"EX.wrt_mem:\t"<<state.EX.wrt_mem<<endl;
		        printstate<<"EX.alu_op:\t"<<state.EX.alu_op<<endl;
		        printstate<<"EX.wrt_enable:\t"<<state.EX.wrt_enable<<endl;
		        printstate<<"EX.NOP:\t"<<state.EX.NOP<<endl;

		        printstate<<"MEM.ALUresult:\t"<<state.MEM.ALUresult<<endl;
		        printstate<<"MEM.Store_data:\t"<<state.MEM.Store_data<<endl;
		        printstate<<"MEM.Rs:\t"<<state.MEM.Rs<<endl;
		        printstate<<"MEM.Rt:\t"<<state.MEM.Rt<<endl;
		        printstate<<"MEM.Wrt_reg_addr:\t"<<state.MEM.Wrt_reg_addr<<endl;
		        printstate<<"MEM.rd_mem:\t"<<state.MEM.rd_mem<<endl;
		        printstate<<"MEM.wrt_mem:\t"<<state.MEM.wrt_mem<<endl;
		        printstate<<"MEM.wrt_enable:\t"<<state.MEM.wrt_enable<<endl;
		        printstate<<"MEM.NOP:\t"<<state.MEM.NOP<<endl;

		        printstate<<"WB.Wrt_data:\t"<<state.WB.Wrt_data<<endl;
		        printstate<<"WB.Rs:\t"<<state.WB.Rs<<endl;
		        printstate<<"WB.Rt:\t"<<state.WB.Rt<<endl;
		        printstate<<"WB.Wrt_reg_addr:\t"<<state.WB.Wrt_reg_addr<<endl;
		        printstate<<"WB.wrt_enable:\t"<<state.WB.wrt_enable<<endl;
		        printstate<<"WB.NOP:\t"<<state.WB.NOP<<endl;
		    }
		    else cout<<"Unable to open FS StateResult output file." << endl;
		    printstate.close();
		}
	private:
		string opFilePath;
};

int main(int argc, char* argv[]) {


	string ioDir = "";

    if (argc == 1) {
        cout << "Enter path containing the memory files: ";
        cin >> ioDir;
    }
    else if (argc > 2) {
        cout << "Invalid number of arguments. Machine stopped." << endl;
        return -1;
    }
    else {
        ioDir = argv[1];
        cout << "IO Directory: " << ioDir << endl;
    }

    InsMem imem = InsMem("Imem", ioDir);
    DataMem dmem_ss = DataMem("SS", ioDir);
	DataMem dmem_fs = DataMem("FS", ioDir);

	SingleStageCore SSCore(ioDir, imem, dmem_ss);
	FiveStageCore FSCore(ioDir, imem, dmem_fs);

    while (1) {
		if (!SSCore.halted)
			SSCore.step();

		if (!FSCore.halted)
			FSCore.step();

		if (SSCore.halted && FSCore.halted)
			break;
    }

	// Here, we will output the Performance Metrics after both 
	// Processors are run to completion

	float CPI_SS = ((float)(SSCore.cycle)) / ((float)(SSCore.instr_count));
	float IPC_SS = ((float)(SSCore.instr_count)) / ((float)(SSCore.cycle));


	cout<<"\n------------------ Single Stage Core -----------------------\n";
	cout<<"Total Cycles Taken SS = \t"<<SSCore.cycle<<"\n";
	cout<<"Cycles Per Instruction SS = \t"<<CPI_SS<<"\n";
	cout<<"Instructions Per Cycle SS = \t"<<IPC_SS<<"\n";

	float CPI_FS = ((float)(FSCore.cycle)) / ((float)(FSCore.instr_count));
	float IPC_FS = ((float)(FSCore.instr_count)) / ((float)(FSCore.cycle));

	cout<<"------------------ 5 Stage Stage Core -----------------------\n";
	cout<<"Total Cycles Taken FS = \t"<<FSCore.cycle<<"\n";
	cout<<"Cycles Per Instruction FS = \t"<<CPI_FS<<"\n";
	cout<<"Instructions Per Cycle FS = \t"<<IPC_FS<<"\n";

	ofstream metricsFile;
		metricsFile.open (ioDir + "\\PerfMetrics.txt");
		metricsFile<<"\n------------------ Single Stage Core -----------------------\n";
		metricsFile<<"Total Cycles Taken SS = \t"<<SSCore.cycle<<"\n";
		metricsFile<<"Cycles Per Instruction SS = \t"<<CPI_SS<<"\n";
		metricsFile<<"Instructions Per Cycle SS = \t"<<IPC_SS<<"\n";
		metricsFile<<"------------------ 5 Stage Stage Core -----------------------\n";
		metricsFile<<"Total Cycles Taken FS = \t"<<FSCore.cycle<<"\n";
		metricsFile<<"Cycles Per Instruction FS = \t"<<CPI_FS<<"\n";
		metricsFile<<"Instructions Per Cycle FS = \t"<<IPC_FS<<"\n";
		metricsFile.close();

}
