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


module UV3_RX_TM(
        input wire clk, // Clock signal
        input wire RST, // Master reset signal
        input  wire Rx_serial,    //  Rx_signal
        input wire clear_done,
        output wire done_Rec,
        output wire [7:0]data_out // Data received
        
    );
    //--------------------------------------------------------
    
  
    wire start_baud;
    wire [3:0]DS_count;
    wire [2:0]BI_count;
    wire sample_data_en; // Only when this bit is enabled the data bits are shifted on to the shift register
    wire start_bit_edge;
    wire baud_tick_Rx ;
    
    wire data_valid;
    wire clear_data;
    wire inc_BiCount;
    wire inc_Scount;
    
    wire rst_sample_count;
    wire rst_bit_index_count;
    
    wire tick;
    
    //--------------------------------------------------------
    
    wire RX_CP; //Synchronised RX signal from the Rx data path module to control module
    
  UV3_RX_CP   control_path(
                    .Rx_in(RX_CP), // Synchronised RX signal from the Rx data path module
                    .clk(clk),     // clock
                    .RST(RST),     // Master reset
                    .sample_data_en(sample_data_en),
                    .clear_done(clear_done), // clear received flag input
                    .start_baud(start_baud), // baud generation start signal
                    .done_Rec(done_Rec), // data receival completed
                    .DS_count(DS_count), // DS_count(data sampling count)
                    .BI_count(BI_count), // BI_count(bit index count)
                    .start_bit_edge(start_bit_edge), // from the data path
                    .baud_tick_RX(baud_tick_Rx),     // from the baud rate generator
                    .data_valid(data_valid),         // data valid signal 
                    .clear_data(clear_data),         // for clearing the received data 
                    .inc_BiCount(inc_BiCount),       // increment the bit index count
                    .inc_Scount(inc_Scount),         // increment the sample count
                    .rst_sample_count(rst_sample_count),       // reset the sample count
                    .rst_bit_index_count(rst_bit_index_count), // reset signal for th bit index count
                    .tick(tick)           // baud tick signal to data path of Rx
                                          // data path that will sample the data
                                          // connected to the tick signal of the RX data path module
    );
    
    UV3_RX_DP data_path(
                .Rx_serial(Rx_serial),     // Serial data from the Tx module
                .clk(clk),                 // Clock
                .RST(RST),                 // Master reset
                .sample_data_en(sample_data_en),
                .baud_tick(baud_tick_Rx),     // from baud rate generator
                .tick(tick),               // from the controller which signals to sample the data 
                .inc_Scount(inc_Scount),     // increment signal for sample count
                .inc_BiCount(inc_BiCount),   // increment signal for bit index while sampling the data 
                .rst_sample_count(rst_sample_count), // reset sample count
                .clear_data(clear_data),             // reset the data register
                .rst_bit_index_count(rst_bit_index_count), // reset bit index count
                .data_valid(data_valid),             // data valid signal from the controller
                .start_bit_edge(start_bit_edge),     // start bit edge
                .data_out(data_out),       // data_out 
                .Rx_CP(RX_CP),             // Rx_synchronised for the controll path
                .DS_count(DS_count),       // For control path (Data sample count)
                .BI_count(BI_count)        // For the control path
    );
    
    UV3_RX_BRG Baud_gen_RX(
                .clk(clk),                 // Clock signal
                .start_baud(start_baud),   // start baud rate generation
                .RST(RST),                 // Master reset signal
                .baud_tick_Rx(baud_tick_Rx)// Baud rate genertor signal
    );
    
    
endmodule
