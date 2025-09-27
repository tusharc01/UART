`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2025 08:03:26 PM
// Design Name: 
// Module Name: uart_rx
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


module uart_rx #(
    parameter CLK_FREQ = 100000000,  // System clock frequency in Hz
    parameter BAUD_RATE = 9600,      // Baud rate in bps
    parameter OVERSAMPLE = 16        // Oversampling factor
) (
    input  wire Clk,                 // System clock (e.g., 100 MHz)
    input  wire reset,               // Asynchronous active-high reset
    input  wire Rx_Serial,           // Incoming serial line
    output reg  Data_Valid,          // High for one cycle when byte received
    output reg [7:0] Rx_Byte         // Received 8-bit data
);

    // Calculate divisor for sample tick generation
    localparam integer SAMPLE_DIV = CLK_FREQ / (BAUD_RATE * OVERSAMPLE);  // e.g., ~651

    localparam IDLE = 3'b000;
    localparam START = 3'b001;
    localparam DATA = 3'b010;
    localparam STOP = 3'b011;

    reg r_Rx_Data = 1'b1;            // Synchronized RX input
    reg r_Rx_Data_prev = 1'b1;       // Previous synchronized value for edge detection
    reg [9:0] divisor_counter = 0;   // Counter for sample tick (10 bits for ~651)
    reg r_Sample_Tick = 0;           // Pulse for each sample tick
    reg [4:0] r_Sample_Count = 0;    // Counts sample ticks per bit (up to OVERSAMPLE)
    reg [2:0] r_Bit_Index = 0;       // 0-7 for data bits
    reg [2:0] State = IDLE;          // FSM state

    // Generate sample tick (pulses every SAMPLE_DIV system clocks)
    always @(posedge Clk or posedge reset) begin
        if (reset) begin
            divisor_counter <= 0;
            r_Sample_Tick <= 0;
        end else begin
            if (divisor_counter >= SAMPLE_DIV - 1) begin
                divisor_counter <= 0;
                r_Sample_Tick <= 1'b1;  // Assert for one Clk cycle
            end else begin
                divisor_counter <= divisor_counter + 1;
                r_Sample_Tick <= 0;
            end
        end
    end

    // Synchronize Rx_Serial (2-stage synchronizer for metastability protection)
    always @(posedge Clk or posedge reset) begin
        if (reset) begin
            r_Rx_Data_prev <= 1'b1;
            r_Rx_Data <= 1'b1;
        end else begin
            r_Rx_Data_prev <= Rx_Serial;
            r_Rx_Data <= r_Rx_Data_prev;
        end
    end

    // Main RX FSM (advances on sample tick)
    always @(posedge Clk or posedge reset) begin
        if (reset) begin
            State <= IDLE;
            r_Sample_Count <= 0;
            r_Bit_Index <= 0;
            Rx_Byte <= 0;
            Data_Valid <= 0;
        end else begin
            Data_Valid <= 0;  // Default deassert

            if (r_Sample_Tick) begin
                case (State)
                    IDLE: begin
                        r_Sample_Count <= 0;
                        r_Bit_Index <= 0;
                        if (r_Rx_Data == 1'b0) begin  // Start bit detected (falling edge)
                            State <= START;
                            r_Sample_Count <= 1;  // First sample count
                        end
                    end

                    START: begin
                        if (r_Sample_Count == (OVERSAMPLE/2)) begin  // Midpoint of start bit
                            if (r_Rx_Data == 1'b0) begin  // Verify still low (valid start bit)
                                r_Sample_Count <= r_Sample_Count + 1;
                            end else begin
                                State <= IDLE;  // False start, return to IDLE
                            end
                        end else if (r_Sample_Count >= OVERSAMPLE - 1) begin
                            State <= DATA;
                            r_Sample_Count <= 0;
                        end else begin
                            r_Sample_Count <= r_Sample_Count + 1;
                        end
                    end

                    DATA: begin
                        if (r_Sample_Count == (OVERSAMPLE/2)) begin  // Sample at midpoint
                            Rx_Byte[r_Bit_Index] <= r_Rx_Data;
                            r_Sample_Count <= r_Sample_Count + 1;
                        end else if (r_Sample_Count >= OVERSAMPLE - 1) begin
                            r_Sample_Count <= 0;
                            if (r_Bit_Index >= 7) begin
                                State <= STOP;
                                r_Bit_Index <= 0;
                            end else begin
                                r_Bit_Index <= r_Bit_Index + 1;
                            end
                        end else begin
                            r_Sample_Count <= r_Sample_Count + 1;
                        end
                    end

                    STOP: begin
                        if (r_Sample_Count >= OVERSAMPLE - 1) begin
                            Data_Valid <= 1'b1;  // Pulse valid
                            State <= IDLE;
                        end else begin
                            r_Sample_Count <= r_Sample_Count + 1;
                        end
                    end

                    default: State <= IDLE;
                endcase
            end
        end
    end

endmodule
