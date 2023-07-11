// testbench file for mealy 0111

module mealy tb;
  reg clk
  reg in;
  reg rst;
  reg out;

  //port instantiation

  Mealy_FSM 

  initial begin
    #5 clk = ~clk;
  end
  
