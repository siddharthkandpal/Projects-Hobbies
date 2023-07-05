`timescale 1ns / 0.1ns

// Module Name:    ALU_8 
// Project Name: Genus Tutorial
// Tool versions: 2.0
// Description: 8 bit ALU with clock

module ALU(clk, A, B, Z);

	input clk;
	input [7:0] A;
	input [7:0] B;
	output reg [8:0] Z;


always @(posedge clk) begin

//		ADD:
 Z <= A + B;
//		SUB: Z <= A - B;
//		MUL:
//			begin
//				temp <= A * B;
//				Z[7:0] <= temp[7:0];
//				Z[8] <= |(temp[15:8]);
//			end
//		DIV: 
//Z <= A / B;

	
//		SHL: Z[8:1] <= A[7:1];
//		SHR: 
//Z[6:0] <= A[7:1];
//		ROL: 
//Z <= {A[6:0], A[7]};
//		ROR:
//Z <= {A[0], A[7:1]};
	
	
//		AND: 
//Z <= {A & B};
//		OR: 
//Z <= {A | B};
//		XOR:
// Z <= {A ^ B};
//		NOR:
// Z <= {~(A | B)};
//		NAND: 
//Z <= {~(A & B)};
//		XNOR: 
//Z <= {~(A ^ B)};
//		EQ:
// Z <= A==B ? 1 : 0;
//		GREAT: 
//Z <= A>B ? 1 : 0;

//	endcase
end
endmodule
