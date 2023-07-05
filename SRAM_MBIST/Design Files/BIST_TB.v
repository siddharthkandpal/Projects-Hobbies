module BIST_tester ();
  reg [7:0] ramin;
  reg [5:0] addr;
  reg cs, rwbar, start;
  reg rst, clk;
  wire [7:0] ramout;
  wire fail;

  initial begin
    cs = 0;
    rwbar = 1;
    start = 0;
    rst = 0;
    clk = 0;
  end

  BIST UUT (start,rst,clk,cs,rwbar,addr,ramin,ramout,fail);

  always #5 clk = ~clk;

  initial begin
    #5 ramin = 8'b11110001;
    #5 cs = 1'b1;
    #5 addr = 6'b101100;
    #10 ramin = 8'b00101100;
    #10 addr = 6'b101110;
    #10 start = 1'b1;
    #140 rwbar = 1'b1;
    #147 cs = 1'b0;

  end
endmodule 

 
