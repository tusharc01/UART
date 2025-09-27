`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2025 08:08:06 PM
// Design Name: 
// Module Name: uart_tb
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


module uart_tb;

    parameter CLK_FREQ = 100000000;  // 100 MHz
    parameter BAUD_RATE = 9600;      // 9600 baud
    parameter OVERSAMPLE = 16;       // 16x oversampling
    parameter CLKS_PER_BIT = CLK_FREQ / BAUD_RATE;  // 10417
    parameter CLOCK_PERIOD = 10;     // 100 MHz = 10ns period
    
    reg         tb_clk;
    reg         tb_reset;
    reg         tb_tx_start;
    reg  [7:0]  tb_tx_byte;
    wire        tb_tx_active;
    wire        tb_tx_done;
    wire        tb_data_valid;
    wire [7:0]  tb_rx_byte;
    
    // Instantiate UART top module with correct parameters and ports
    uart_top #(
        .CLK_FREQ(CLK_FREQ),
        .BAUD_RATE(BAUD_RATE),
        .OVERSAMPLE(OVERSAMPLE)
    ) uut (
        .clk(tb_clk),
        .reset(tb_reset),
        .tx_start(tb_tx_start),
        .tx_byte(tb_tx_byte),
        .tx_active(tb_tx_active),
        .tx_done(tb_tx_done),
        .data_valid(tb_data_valid),
        .rx_byte(tb_rx_byte)
    );
    
    // Clock generation
    initial begin
        tb_clk = 0;
        forever #(CLOCK_PERIOD/2) tb_clk = ~tb_clk;
    end
    
    // Updated task in testbench
    task send_byte;
        input [7:0] data;
        begin
            tb_tx_byte = data;
            tb_tx_start = 1;
            
            // Hold tx_start until TX becomes active (acknowledges it)
            wait(tb_tx_active == 1);
            tb_tx_start = 0;  // Deassert after TX starts
            
            $display("Time: %t - Started sending byte: 0x%h", $time, data);
            
            // Wait for TX completion
            wait(tb_tx_done == 1);
            $display("Time: %t - Sent byte: 0x%h", $time, data);
            
            // Wait for RX valid and check match
            wait(tb_data_valid == 1);
            if (tb_rx_byte == data) begin
                $display("Time: %t - Received byte: 0x%h - PASS", $time, tb_rx_byte);
            end else begin
                $display("Time: %t - Received byte: 0x%h - FAIL (expected 0x%h)", $time, tb_rx_byte, data);
            end
            
            // Small delay before next test
            #(CLOCK_PERIOD * 100);
        end
    endtask
    
    // Test sequence
    initial begin
        
        // Initialize signals
        tb_reset = 1;
        tb_tx_start = 0;
        tb_tx_byte = 8'h00;
        
        // Apply reset
        #100;
        tb_reset = 0;
        #100;
        
        // Test case 1: Send byte 0x67
        send_byte(8'h67);
        
        // Wait for transmission to complete (10 bits: start + 8 data + stop)
        #(CLOCK_PERIOD * CLKS_PER_BIT * 10);
        
        #1000;
        $finish;
    end
    
endmodule
