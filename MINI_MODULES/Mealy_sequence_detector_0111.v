//Mealey sequence detector with overlap, sequence is 0111

module mealey_fsm (
  input in,
  input clk,
  input rst,
  output reg detector_out);

  localparam IDLE = 3'b000, 
             FIRST_BIT = 3'b001, // received 0
             SECOND_BIT = 3'b010, // received 01
             THIRD_BIT = 3'b011,  // received 011
             FOURTH_BIT = 3'b100; // received 0111

  reg [2:0] current_state, next_state;

  always@(posedge clk or posedge rst) begin
    if (rst == 1)
      current_state <= IDLE;
      detector_out <= 1'b0;
    else
      current_state <= next_state;  
  end

  // begin the transfer of data in combinatorial blocks, with sensitivity list having in and state 
  always@(in, current_state) begin
    case(current_state)
      IDLE: begin
        if (in == 0) //0 or 1
          next_state = FIRST_BIT;
          detector_out <= 1'b0;
        else
          next_state = IDLE;
          detector_out <= 1'b0;
      end 
      FIRST_BIT: begin
        if (in == 1) // 01 or 00
          next_state = SECOND_BIT;
          detector_out <= 1'b0;
        else
          next_state = FIRST_BIT;
          detector_out <= 1'b0;
      end
      SECOND_BIT: begin
        if (in == 1) // 011 or 010
          next_state = THIRD_BIT;
          detector_out <= 1'b0;
        else
          next_state = FIRST_BIT;
          detector_out <= 1'b0;
      end
      THIRD_BIT: begin
        if (in == 1) // 0111 ir 0110 
          detector_out <= 1'b1;
          next_state = IDLE;
        else
          next_state = FIRST_BIT;
          detector_out <= 1'b0;
      end
      default: next_state: IDLE;
    endcase
  end  
