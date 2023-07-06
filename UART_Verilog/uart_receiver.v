// UART reciever , 8 bits of data, 1 bit parity, 1 start/stop : 11 bit segment of data:
//the machine has 5 states IDLE, START, DATA, PARITY, STOP

`timesacale 1ns/1ps

module uart_reciever#(
  parameter WORD_LENGTH = 8,
  parameter PARITY = "none",
  parameter STOP_BITS = 1,
  parameter BAUD_RATE = 9600,
  parameter CLK_FREQ = 50_000_000  // Clock frequency in Hz
)
  (
    input wire clk,
    input wire reset,
    input rx_in, // incoming bit stream
    output reg [WORD_LENGTH -1: 0] rx_data, // 8 bits of data
    output reg rx_ready = 1'b0 // setting it to not ready, default
  );

  // state machines
  localparam IDLE  =  3'b000, // if tx_start and !rst , move to state start and so on..
             START =  3'b001, 
             DATA  =  3'b010,
             PARITY = 3'b011,
             STOP  =  3'b100;            
  reg[2:0] state; // 3 bit register to hold 5 states
  state = IDLE;

  reg[WORD_LENGTH_ + 2:0] shift_register;
  reg[3:0] rx_bit_cnt;
  reg[3:0] stop_bit_cnt;

  // as both the devices are operating at the same baud rate, we get using the same formula: CLKFREQ/BAUDRATE - 1

  localparam MAX_COUNT = CLK_FREQ / BAUD_RATE / 2 - 1;
  reg [31:0] counter = 0;
  reg baud_tick = 0;
  
  
  
