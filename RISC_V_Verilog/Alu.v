module ALU (Rs1, Rs2, Opcode, Out, Carry);
  input [7:0] Rs1, Rs2;
  input [3:0] Opcode;
  output reg [7:0] Out;
  output reg Carry;

  always @(*) begin
    Carry = 0;
    case(Opcode)
      4'b0000 : begin // ADD
        Out = Rs1 + Rs2;
        Carry = (Rs1 + Rs2) > 8'hFF;
      end
      4'b0001 : begin // SUB
        Out = Rs1 - Rs2;
        Carry = Rs1 < Rs2;
      end
      4'b0010 : Out = Rs1 & Rs2; // AND
      4'b0011 : Out = Rs1 | Rs2; // OR
      4'b0100 : Out = Rs1 ^ Rs2; // XOR
      4'b0101 : Out = Rs1 << Rs2; // Shift Left
      4'b0110 : Out = Rs1 >> Rs2; // Shift Right
      4'b0111 : Out = ~Rs1; // NOT
      4'b1000 : Out = Rs1 * Rs2; // Multiply
      4'b1001 : Out = Rs1 / Rs2; // Divide
      default : Out = 8'h00; // Default
    endcase
  end
endmodule
