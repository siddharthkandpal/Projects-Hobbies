module BIST #(parameter size = 6, length =8)
             (start,rst,clk,csin,rwbarin,address,datain,dataout,fail);
  input start, rst, clk, csin, rwbarin;
  input [size-1: 0] address;
  input [length-1: 0] datain;
  output [length-1: 0] dataout;
  output fail;
  reg fail;
  reg [9:0] zero;

  wire cout, ld, NbarT, cs, rwbar, gt, eq, lt;
  wire [9:0] q;
  wire [7:0] data_t;
  wire [length-1:0] ramin, ramout, bit_array;
  wire [size-1:0] ramaddr;
  reg [length-1:0] ram_testvalue;
  reg conv_enable;
  integer i, index, power, mult;
  integer faulty_adr, faulty_bit ;
  initial zero = 10'b 0000000000;

  BIST_controller CNTRL (start, rst, clk, cout, NbarT, ld);
  counter CNT (zero, clk, ld, 1'b1, 1'b1, q, cout);
  decoder DEC (q[9:7], data_t);
  muxd MUX_D (datain, data_t, NbarT, ramin);
  muxa MUX_A (address, q[5:0], NbarT, ramaddr);

  assign rwbar = (~NbarT) ? rwbarin : q[6];
  assign cs = (~NbarT) ? csin : 1'b 1;

  RAM MEM (ramin, ramaddr, rwbar, clk, ramout);
  comparator CMP (data_t, ramout, gt, eq, lt);

  always @ (posedge clk) begin
    if (NbarT && rwbar)
      if (~eq) begin
        fail <= 1'b1;
      end else begin
        fail <= 1'b0;
    end
  end

  assign dataout = ramout;

endmodule 

module BIST_controller (input start, rst, clk, cout, output NbarT, ld);

  reg current = rst;

  parameter reset = 1'b0, test = 1'b1;

  always @ (posedge clk) begin
    if (rst)
      current <= rst;
    else
      case(current)
        reset: if (start)
                   current <= test;
               else
                   current <= rst;
         test: if (cout)
                   current <= rst;
               else
                   current <= test;
          default:
               current <= rst;
       endcase
    end


  assign NbarT = (current == test) ? 1'b 1 : 1'b 0;
  assign ld = (current == reset) ? 1'b 1 : 1'b 0;

endmodule

module counter
 #(parameter length = 10) (d_in, clk, ld, u_d, cen, q, cout);

 input [length-1:0] d_in;
 input clk, ld, u_d, cen;
 output [length-1:0] q;
 output cout;

 reg [length:0] cnt_reg;

 always @(posedge clk) begin
  if ( cen ) begin
    if ( ld )
      cnt_reg <= {1'b0, d_in};
    else if ( u_d )
      cnt_reg <= cnt_reg + 1;
    else
      cnt_reg <= cnt_reg - 1;
    end
 end

 assign q = cnt_reg[length-1:0];
 assign cout = cnt_reg[length];

endmodule

module decoder (input [2:0] in, output [7:0] out);
  wire [7:0] out_temp;

  assign out_temp = (in[1:0] == 2'b 11) ? 8'b 01010101 :
                    (in[1:0] == 2'b 10) ? 8'b 00110011 :
                    (in[1:0] == 2'b 01) ? 8'b 00001111 :
                    (in[1:0] == 2'b 00) ? 8'b 00000000 :
                    8'b zzzzzzzz;

  assign out = (in[2] == 1'b 0) ? out_temp : ~ out_temp;

endmodule

module muxa (input [5:0] i0, i1, input s, output [5:0] y );

  assign y = s ? i1 : i0;

endmodule

module muxd (input [7:0] i0, i1, input s, output [7:0]y );

  assign y = s ? i1 : i0;

endmodule


module comparator (input [7:0] a, b, output a_gt_b, a_eq_b, a_lt_b);

reg a_gt_b;
reg a_eq_b;
reg a_lt_b;

always @ ( a, b ) begin

if ( a < b ) begin
 a_gt_b = 0;
 a_eq_b = 0;
 a_lt_b = 1;
end

if ( a > b ) begin
 a_gt_b = 1;
 a_eq_b = 0;
 a_lt_b = 0;
end

else begin
 a_eq_b = 1;
 a_lt_b = 0;
 a_gt_b = 0;
 end

 end
endmodule 

module RAM (input [7:0] data, input [5:0] addr, input re, clk, output [7:0] q );


        reg [7:0] ram[63:0];


        reg [5:0] addr_reg;

        always @ (posedge clk)
        begin

                if (~re)
                        ram[addr] <= data;

                addr_reg <= addr;

        end


        assign q = ram[addr_reg];

endmodule
