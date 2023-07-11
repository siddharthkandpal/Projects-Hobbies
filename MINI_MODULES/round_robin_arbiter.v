// round robin arbiter in verilog, implementation and testbench. ill use 3 request signals, req [2:0] for defining each component. 

module rr_arbiter (
  input clk,
  input rst,
  input [2:0] rq, // request signal
  output [2:0] grant); // 3 bit grantsignal

  localparam IDLE = 3'b000,
  localparam REQ0 = 3'b001,
  localparam REQ1 = 3'b010,
  localparam REQ2 = 3'b011;

  reg [2:0] current_state, next_state; // defining states, 3 bits to hold 4 states, can use 2 also but we go for 3 for headroom and future mods

  always@(posedge clk or posedge rst) begin
    if (rst)
      current_state <= IDLE;
    else
      current_state <= next_state;
  end

  always@(*) begin // the sens list has to contain the current_state and the req signal but for simplification we use *
    case(current_state)
      IDLE: begin
        if (rq[0]) begin
          next_state <= REQ0;
        end
          else if (rq[1]) begin
            next_state <= REQ1;
          end
            else if (rq[2]) begin
               next_state <= REQ2;
            end
        else begin 
          next_state <= IDLE;
        end
      end

      REQ0: begin
        if (rq[1]) begin
            next_state <= REQ1;
          end
            else if (rq[2]) begin
               next_state <= REQ2;
            end  
              else if (rq[0]) begin
                next_state <= REQ0;
              end
              else begin
                next_state <= IDLE;
              end
        end

      REQ1: begin
        if (rq[2]) begin
               next_state <= REQ2;
            end  
              else if (rq[0]) begin
                next_state <= REQ0;
              end
                else if (rq[1]) begin
                  next_state <= REQ1;
                end
                  else begin
                    next_state <= IDLE;
                  end
         end

      REQ2: begin
        if (rq[0]) begin
          next_state <= REQ0;
        end
          else if (rq[1]) begin
            next_state <= REQ1;
          end
            else if (rq[2]) begin
               next_state <= REQ2;
            end
        else begin 
          next_state <= IDLE;
        end 
      end

      default : next_state <= IDLE;
      end
    endcase
  end

  always@(*) begin
    case(current_state)
      IDLE: begin
        grant = 3'b000;
      end
      REQ0: begin
        grant = 3'b001;
      end
      REQ1: begin
        grant = 3'b010;
      end
      REQ2: begin
        grant = 3'b100;
      end
    endcase
  end
endmodule
