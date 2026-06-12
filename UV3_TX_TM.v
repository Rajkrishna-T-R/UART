`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 16.03.2026 17:41:38
// Design Name: 
// Module Name: UV3_TX_TM
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


module UV3_TX_TM(
                input wire clk,
                input wire RST,
                input wire [7:0]data_in,
                input wire Start,
                input wire clear_done,
                output wire done_Tra,
                output wire TX_serial
    );
   
   wire TX;// Interconnect TX line between control and data path
   wire baud_tick_Tx;
   wire [2:0]data_bit_count;
   wire load_data;
   wire shift_data;
   wire rst_bit_count;
   
   
    UV3_TX_CP control_path(
        .clear_done(clear_done),//Clear done signal
        .done_Tra(done_Tra),    // Flag for showing the end of transmission
        .clk(clk), // Clock
        .RST(RST), // reset
        .baud_tick_Tx(baud_tick_Tx),     // baud tick signal from baud rate generator
        .data_bit_count(data_bit_count), // data bit counting purposes 
        .Tx_serial(TX),   // The Tx_serial line from Data path 
        .Start(Start),           // Start signal from the driver
        .load_data(load_data),   // Load data signal to the data path
        .shift_data(shift_data), // shift data signal to the data path
        .TX(TX_serial),                      // Tx line for sending
        .rst_bit_count(rst_bit_count) // fpr reseting the bit count that has been transmitted 
        
    );
    
    UV3_TX_DP data_path( 
               .clk(clk), // clock
               .RST(RST), //Master RESET
               .data_in(data_in),       // data to be transmitted
               .load_data(load_data),   // load data into the shift register
               .shift_data(shift_data),       // shift_data 
               .rst_bit_count(rst_bit_count), // reset Bit count
               .data_bit_count(data_bit_count), // To controller
               .Tx_serial(TX)            // Tx serial output to control path
                
    );
    
    UV3_TX_BRG Baud_gen_TX(
                .clk(clk),  // Clk
                .RST(RST),  // RST
                .baud_tick_Tx(baud_tick_Tx) // baud_tick_from the baud generator
                
    );

endmodule
