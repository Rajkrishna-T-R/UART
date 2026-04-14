`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.04.2026 00:43:20
// Design Name: 
// Module Name: UV3_TOP_IP
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


module UV3_TOP_IP(
            input wire clk,
            input wire RST,
            input wire Start, // begin transmission
           
            input wire clear_done_Tra, // clear done transmission signal
            output wire done_Tra,
            // Need a signal to clear the data  ???
            
            input wire clear_done_Rec, // clear done receival flag signal
            output wire done_Rec,
            
            input wire [7:0] DATA_in,
            input wire RX_serial,
            output wire TX_serial,
            output wire[7:0] DATA_out
    );
    
    UV3_TX_TM TX(
                .clk(clk),
                .RST(RST),
                .Start(Start),
                .clear_done(clear_done_Tra),
                .done_Tra(done_Tra),
                .data_in(DATA_in),
                .TX_serial(TX_serial)
    );
    
    UV3_RX_TM  RX(
        .clk(clk), // Clock signal
        .RST(RST), // Master reset signal
        .clear_done(clear_done_Rec),
        .done_Rec(done_Rec),
        .Rx_serial(RX_serial),    // Sync Rx_signal
        .data_out(DATA_out) // Data received
        
    );
endmodule
