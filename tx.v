`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2025 09:50:01 AM
// Design Name: 
// Module Name: tx
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


module uart_tx 
  #(parameter CLKS_PER_BIT = 2000000)  // 50 baud with 100 MHz clock
  (
   input       Clk,
   input       Tx_Start,
   input [7:0] Tx_Byte, 
   output      Tx_Active,
   output reg  Tx_Serial,
   output      Tx_Done
   );
  
  localparam IDLE  = 3'b000;
  localparam START = 3'b001;
  localparam DATA  = 3'b010;
  localparam STOP  = 3'b011;
   
  reg [2:0]    State         = 0;
  reg [31:0] r_Clk_Count = 0;  // Changed from 13:0 to 31:0
  reg [2:0]    r_Bit_Index   = 0;
  reg [7:0]    r_Tx_Data     = 0;
  reg          r_Tx_Done     = 0;
  reg [31:0]   r_Done_Count  = 0;  // Counter for stretching Tx_Done
  reg          r_Tx_Active   = 0;
     
  always @(posedge Clk)
    begin
      case (State)
        IDLE :
          begin
            Tx_Serial   <= 1'b1;
            r_Clk_Count <= 0;
            r_Bit_Index <= 0;
            if (Tx_Start == 1'b1)
              begin
                r_Tx_Active <= 1'b1;
                r_Tx_Data   <= Tx_Byte;
                State       <= START;
              end
            else
              State <= IDLE;
          end
         
        START :
          begin
            Tx_Serial <= 1'b0;
            if (r_Clk_Count < CLKS_PER_BIT-1)
              begin
                r_Clk_Count <= r_Clk_Count + 1;
                State       <= START;
              end
            else
              begin
                r_Clk_Count <= 0;
                State       <= DATA;
              end
          end
         
        DATA :
          begin
            Tx_Serial <= r_Tx_Data[r_Bit_Index];
            if (r_Clk_Count < CLKS_PER_BIT-1)
              begin
                r_Clk_Count <= r_Clk_Count + 1;
                State       <= DATA;
              end
            else
              begin
                r_Clk_Count <= 0;
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
            Tx_Serial <= 1'b1;
            if (r_Clk_Count < CLKS_PER_BIT-1)
              begin
                r_Clk_Count <= r_Clk_Count + 1;
                State       <= STOP;
              end
            else
              begin
                r_Clk_Count <= 0;
                r_Bit_Index <= 0;
                r_Tx_Active <= 1'b0;
                State       <= IDLE;
                r_Tx_Done   <= 1'b1;  // Start Tx_Done pulse
                r_Done_Count <= 0;    // Reset counter for stretching
              end
          end
         
        default :
          State <= IDLE;
      endcase

      // Separate logic to stretch Tx_Done
      if (r_Tx_Done && r_Done_Count < CLKS_PER_BIT-1) begin
        r_Done_Count <= r_Done_Count + 1;  // Count up during pulse
      end
      else if (r_Done_Count == CLKS_PER_BIT-1) begin
        r_Tx_Done <= 1'b0;  // End pulse after CLKS_PER_BIT cycles
      end
    end
 
  assign Tx_Active = r_Tx_Active;
  assign Tx_Done   = r_Tx_Done;
   
endmodule