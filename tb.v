`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2025 09:51:44 AM
// Design Name: 
// Module Name: tb
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

module uart_top_tb;

    parameter CLKS_PER_BIT = 10417;  // 100 MHz / 9600 baud
    parameter CLOCK_PERIOD = 10;     // 100 MHz = 10ns period
    
    reg         tb_clk;
    reg         tb_tx_start;
    reg  [7:0]  tb_tx_byte;
    wire        tb_tx_active;
    wire        tb_tx_done;
    wire        tb_rx_data_valid;
    wire [7:0]  tb_rx_byte;
    
    uart_top 
      #(.CLKS_PER_BIT(CLKS_PER_BIT))
      uut (
        .Clk(tb_clk),
        .Tx_Start(tb_tx_start),
        .Tx_Byte(tb_tx_byte),
        .Tx_Active(tb_tx_active),
        .Tx_Done(tb_tx_done),
        .Data_Valid(tb_rx_data_valid),
        .Rx_Byte(tb_rx_byte)
      );
    
    initial begin
        tb_clk = 0;
        forever #(CLOCK_PERIOD/2) tb_clk = ~tb_clk;
    end
    
    initial begin
        tb_tx_start   = 0;
        tb_tx_byte = 8'h00;
        #1000;
        
        tb_tx_byte = 8'h67;
        tb_tx_start   = 1;
        #100;
        tb_tx_start   = 0;
        
        #(CLOCK_PERIOD * CLKS_PER_BIT * 11);  // 10 bits + buffer
        
        #1000;
        $finish;
    end
    
endmodule
