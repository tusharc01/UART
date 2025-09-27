`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/27/2025 08:02:43 PM
// Design Name: 
// Module Name: uart_tx
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


module uart_tx (
    input       clk,
    input       baud_tick,
    input       reset,
    input       Tx_Start,
    input [7:0] Tx_Byte,
    output reg  Tx_Serial,
    output reg  Tx_Active,
    output reg  Tx_Done
);

    localparam IDLE  = 3'b000;
    localparam START = 3'b001;
    localparam DATA  = 3'b010;
    localparam STOP  = 3'b011;

    reg [2:0] present_state;
    reg [2:0] next_state;
    reg [7:0] r_Tx_Data;
    reg [2:0] r_Bit_Index;
    reg [2:0] next_Bit_Index;

    // Sequential block: Only state and register updates
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            present_state <= IDLE;
            r_Tx_Data <= 0;
            r_Bit_Index <= 0;
        end else if (baud_tick) begin
            present_state <= next_state;
            r_Bit_Index <= next_Bit_Index;
            
            // Latch data when starting transmission
            if (present_state == IDLE && Tx_Start) begin
                r_Tx_Data <= Tx_Byte;
            end
        end
    end

    // Combinational block: Immediate output assignments and next state logic
    always @(*) begin
        // Default values
        next_state = present_state;
        next_Bit_Index = r_Bit_Index;
        Tx_Serial = 1'b1;  // Default: idle high
        Tx_Active = 1'b0;
        Tx_Done = 1'b0;

        case (present_state)
            IDLE: begin
                Tx_Serial = 1'b1;
                Tx_Active = 1'b0;
                if (Tx_Start) begin
                    next_state = START;
                    next_Bit_Index = 0;
                end
            end

            START: begin
                Tx_Serial = 1'b0;  // START bit - IMMEDIATE assignment!
                Tx_Active = 1'b1;
                next_state = DATA;  // Transition on next baud tick
            end

            DATA: begin
                Tx_Serial = r_Tx_Data[r_Bit_Index];  // Data bit - IMMEDIATE!
                Tx_Active = 1'b1;
                if (r_Bit_Index < 7) begin
                    next_state = DATA;
                    next_Bit_Index = r_Bit_Index + 1;
                end else begin
                    next_state = STOP;
                    next_Bit_Index = 0;
                end
            end

            STOP: begin
                Tx_Serial = 1'b1;  // STOP bit - IMMEDIATE!
                Tx_Active = 1'b1;
                Tx_Done = 1'b1;    // Done pulse - IMMEDIATE!
                next_state = IDLE;
            end

            default: begin
                next_state = IDLE;
                next_Bit_Index = 0;
            end
        endcase
    end

endmodule
