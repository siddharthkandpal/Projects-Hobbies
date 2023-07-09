//alu testbench , Siddharth Kandpal, SK8944@nyu.edu

module ALU_TB;
  
  reg [7:0] Rs1;
  reg [7:0] Rs2;
  reg [3:0] Opcode;
  wire [7:0] Out;
  wire Carry;

  // Instantiate the ALU
  ALU u1 (
    .Rs1(Rs1), 
    .Rs2(Rs2), 
    .Opcode(Opcode), 
    .Out(Out),
    .Carry(Carry)
  );

  initial begin
    // Initial test values
    Rs1 = 8'b00001111;
    Rs2 = 8'b00000001;

    // Test ADD
    Opcode = 4'b0000;
    #10;

    // Test SUB
    Opcode = 4'b0001;
    #10;

    // Test AND
    Opcode = 4'b0010;
    #10;

    // Test OR
    Opcode = 4'b0011;
    #10;

    // Test XOR
    Opcode = 4'b0100;
    #10;

    // Test Shift Left
    Opcode = 4'b0101;
    #10;

    // Test Shift Right
    Opcode = 4'b0110;
    #10;

    // Test NOT
    Opcode = 4'b0111;
    #10;

    // Test Multiply
    Opcode = 4'b1000;
    #10;

    // Test Divide
    Opcode = 4'b1001;
    #10;
  end

  initial begin
    $monitor("Time %d has value:, Rs1 = %b, Rs2 = %b, Opcode = %b, Out = %b, Carry = %b",
             $time, Rs1, Rs2, Opcode, Out, Carry);
  end

endmodule
