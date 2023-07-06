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
  localparam IDLE = 3'b000,
            
