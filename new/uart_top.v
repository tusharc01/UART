`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2025 08:04:16 PM
// Design Name: 
// Module Name: uart_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module uart_top #(
    parameter CLK_FREQ = 100000000,
    parameter BAUD_RATE = 9600,
    parameter OVERSAMPLE = 16
) (
    input  wire clk,
    input  wire reset,
    input  wire tx_start,
    input  wire [7:0] tx_byte,
    output wire tx_active,
    output wire tx_done,
    output wire data_valid,
    output wire [7:0] rx_byte
);

    wire baud_tick;  // From baud_generator
    wire serial_line;  // TX to RX connection

    // Instantiate baud generator (shared for TX)
    baud_generator #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE)
    ) baud_gen_inst (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick)
    );

    // Instantiate TX
    uart_tx tx_inst (
        .clk(clk),
        .reset(reset),
        .baud_tick(baud_tick),  // Pass external tick
        .Tx_Start(tx_start),
        .Tx_Byte(tx_byte),
        .Tx_Active(tx_active),
        .Tx_Serial(serial_line),
        .Tx_Done(tx_done)
    );

    // Instantiate RX (unchanged)
    uart_rx #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .OVERSAMPLE(OVERSAMPLE)
    ) rx_inst (
        .Clk(clk),
        .reset(reset),
        .Rx_Serial(serial_line),
        .Data_Valid(data_valid),
        .Rx_Byte(rx_byte)
    );

endmodule
