// testbench file for mealy 0111

module mealy tb;
  reg clk;
  reg in;
  reg rst;
  reg out;

  //port instantiation

  mealy_fsm UUT (
    .clk(clk),
    .rst(rst),
    .in(in),
    .out(out));


  //clock settings
  
  initial begin
    clk = 0;
  forever clk = ~clk;
  end

  initial begin
    in = 0;
    rst = 1;

    #20;
    rst = 1;
    #40;
    in = 1;
    #50;
    in = 1;
    #60;
    in = 1;
    #70;
    in = 0;
    #80;
    in = 1;

  end
endmodule
