`timescale 1ns / 0.1ns

// Module Name:    ALU_8 
// Project Name: Genus Tutorial
// Tool versions: 2.0
// Description: 8 bit ALU with clock

module ALU(clk, A, B, select, Z);

	input clk;
	input [7:0] A;
	input [7:0] B;
	input [3:0] select;
	output reg [8:0] Z;

//defining parameters for case

	parameter ADD 	= 	4'b0000;		// +
	parameter SUB	= 	4'b0001;		// -
	parameter MUL	= 	4'b0010;		// *
	parameter DIV 	= 	4'b0011;		// /
	parameter SHL	=   	4'b0100;		// shift left(A)
	parameter SHR	=   	4'b0101;		// shift right(A)
	parameter ROL	=   	4'b0110;		// shift right(A)
	parameter ROR	=   	4'b0111;		// shift right(A)
	parameter AND	=   	4'b1000;		// and
	parameter OR	=   	4'b1001;		// or
	parameter XOR	=   	4'b1010;		// Xor
	parameter NOR	=   	4'b1011;		// nor
	parameter NAND	=   	4'b1100;		// nand
	parameter XNOR	=   	4'b1101;		// Xnor
	parameter EQ	=   	4'b1110;		// equal
	parameter GREAT	=   	4'b1111;		// A > B

	reg [15:0] temp;

always @(posedge clk) begin
	case (select)

		ADD: Z <= A + B;
		SUB: Z <= A - B;
		MUL:
			begin
				temp <= A * B;
				Z[7:0] <= temp[7:0];
				Z[8] <= |(temp[15:8]);
			end
		DIV: Z <= A / B;

	
		SHL: Z[8:1] <= A[7:1];
		SHR: Z[6:0] <= A[7:1];
		ROL: Z <= {A[6:0], A[7]};
		ROR: Z <= {A[0], A[7:1]};
	
	
		AND: Z <= {A & B};
		OR: Z <= {A | B};
		XOR: Z <= {A ^ B};
		NOR: Z <= {~(A | B)};
		NAND: Z <= {~(A & B)};
		XNOR: Z <= {~(A ^ B)};
		EQ: Z <= A==B ? 1 : 0;
		GREAT: Z <= A>B ? 1 : 0;

	endcase
end
endmodule
