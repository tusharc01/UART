`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/23/2025 09:52:13 AM
// Design Name: 
// Module Name: top
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


module uart_top
  #(parameter CLKS_PER_BIT = 2000000)
  (
   input        Clk,
   input        Tx_Start,
   input [7:0]  Tx_Byte,
   output       Tx_Active,
   output       Tx_Done,
   output       Data_Valid,
   output [7:0] Rx_Byte
   );

   wire w_Serial;

   uart_tx
     #(.CLKS_PER_BIT(CLKS_PER_BIT))
     u_tx (
       .Clk(Clk),
       .Tx_Start(Tx_Start),
       .Tx_Byte(Tx_Byte),
       .Tx_Active(Tx_Active),
       .Tx_Serial(w_Serial),
       .Tx_Done(Tx_Done)
     );

   uart_rx
     #(.CLKS_PER_BIT(CLKS_PER_BIT))
     u_rx (
       .Clk(Clk),
       .Rx_Serial(w_Serial),
       .Data_Valid(Data_Valid),
       .Rx_Byte(Rx_Byte)
     );

endmodule
