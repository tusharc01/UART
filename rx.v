`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2025 09:50:51 AM
// Design Name: 
// Module Name: rx
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


module uart_rx 
  #(parameter CLKS_PER_BIT = 2000000)  // 50 baud with 100 MHz clock
  (
   input        Clk,
   input        Rx_Serial,
   output       Data_Valid,
   output [7:0] Rx_Byte
   );
    
  localparam IDLE  = 3'b000;
  localparam START = 3'b001;
  localparam DATA  = 3'b010;
  localparam STOP  = 3'b011;
   
  reg           r_Rx_Data    = 1'b1;
  reg [31:0] r_Clk_Count = 0;  // Changed from 13:0 to 31:0
  reg [2:0]     r_Bit_Index  = 0;
  reg [7:0]     r_Rx_Byte    = 0;
  reg           r_Data_Valid = 0;
  reg [31:0]    r_DV_Count   = 0;  // Counter for stretching Data_Valid
  reg [2:0]     State        = 0;
   
  // Sample Rx_Serial
  always @(posedge Clk)
    begin
      r_Rx_Data <= Rx_Serial;
    end
   
  // Main state machine and Data_Valid stretching
  always @(posedge Clk)
    begin
      case (State)
        IDLE :
          begin
            r_Clk_Count <= 0;
            r_Bit_Index <= 0;
            if (r_Rx_Data == 1'b0)          // Start bit detected
              State <= START;
            else
              State <= IDLE;
          end
         
        START :
          begin
            if (r_Clk_Count == (CLKS_PER_BIT-1)/2)  // Middle of start bit
              begin
                if (r_Rx_Data == 1'b0)
                  begin
                    State <= DATA;  // Transition to data state
                    r_Clk_Count <= r_Clk_Count + 1;  // Keep counting
                  end
                else
                  State <= IDLE;
              end
            else if (r_Clk_Count < CLKS_PER_BIT-1)  // Continue until end
              begin
                r_Clk_Count <= r_Clk_Count + 1;
                State     <= START;
              end
            else  // At end of full bit period
              begin
                r_Clk_Count <= 0;
                State     <= DATA;  // Ensure transition if already set
              end
          end
         
        DATA :
          begin
            if (r_Clk_Count < CLKS_PER_BIT-1)
              begin
                r_Clk_Count <= r_Clk_Count + 1;
                State     <= DATA;
              end
            else
              begin
                r_Clk_Count          <= 0;
                r_Rx_Byte[r_Bit_Index] <= r_Rx_Data;
                if (r_Bit_Index < 7)
                  begin
                    r_Bit_Index <= r_Bit_Index + 1;
                    State     <= DATA;
                  end
                else
                  begin
                    r_Bit_Index <= 0;
                    State     <= STOP;
                  end
              end
          end
     
        STOP :
          begin
            if (r_Clk_Count < CLKS_PER_BIT-1)
              begin
                r_Clk_Count <= r_Clk_Count + 1;
                State     <= STOP;
              end
            else
              begin
                r_Clk_Count   <= 0;
                r_Bit_Index   <= 0;
                r_Data_Valid  <= 1'b1;  // Start Data_Valid pulse
                r_DV_Count    <= 0;     // Reset counter for stretching
                State         <= IDLE;
              end
          end
         
        default :
          State <= IDLE;
      endcase

      // Separate logic to stretch Data_Valid
      if (r_Data_Valid && r_DV_Count < CLKS_PER_BIT-1) begin
        r_DV_Count <= r_DV_Count + 1;  // Count up during pulse
      end
      else if (r_DV_Count == CLKS_PER_BIT-1) begin
        r_Data_Valid <= 1'b0;  // End pulse after CLKS_PER_BIT cycles
      end
    end   
   
  assign Data_Valid = r_Data_Valid;
  assign Rx_Byte    = r_Rx_Byte;
   
endmodule