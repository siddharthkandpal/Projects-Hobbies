//UART Transmitter: Verilog, A simple 8 bit UART transmitter for transmitting parallel -> serial over a data line
//the machine has 4 states IDLE, START, DATA, STOP
`timescale 1ns / 1ps

module uart_tx #(
  parameter WORD_LENGTH = 8,
  parameter PARITY = "none",
  parameter STOP_BITS = 1,
  parameter BAUD_RATE = 9600,
  parameter CLK_FREQ = 50_000_000  // Clock frequency in Hz, taking 50MHz for our example
)
(
  input clk_glb,  //clock signal
  input rst_n,    // negative edge reset
  input tx_start, // transmission start
  input wire [WORD_LENGTH-1:0] tx_data, //input data
  output reg o_tx, //output 
  output reg tx_ready = 1'b1 //rdy signal
); 

  localparam IDLE  =  3'b000, // if tx_start and !rst , move to state start
             START =  3'b001, 
             DATA  =  3'b010,
             PARITY = 3'b011,
             STOP  =  3'b100;
  
  reg [3:0] state;
  state = IDLE;

  //Parameters for shift register

  reg [WORD_LENGTH:0] shift_register;
  reg [2:0] count_bits; // 3 bits for 3 states

  //Baud generation, i.e Creating our own clock by the formula: CLKFREQ/BAUDRATE - 1 

  localparam NEW_COUNT = CLK_FREQ / BAUD_RATE - 1; // Couter to wrap around for transmission
  reg [31:0] counter = 0; // counter to equate counter with COUNTER_MAX 
  reg new_baud = 0; //baud tick is the new counter

  // initializing counter values on every posedge clk w sync reset 
  always @(posedge clk or posedge reset) begin
    if (reset)
      counter <= 0;
    else if (counter == NEW_COUNT)
      counter <= 0;
    else
      counter <= counter + 1;
  end

  assign new_baud = (counter == NEW_COUNT);

  //Transmission of data: data tx logic using predef bits
  // In UART, the line is held high for IDLE, and low for start

  
  
  
  
  
  
  
  

