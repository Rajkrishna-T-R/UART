
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.01.2026 07:03:41
// Design Name: 
// Module Name: top_test_mod
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


module top_test_mod(
            input wire rst_bar,
            input wire [7:0]data_in,
            input wire tx_wr_en,
            input wire clk,
            output wire [7:0]data_out,
            output wire RX_data_rdy,
            output wire tx_busy,
            output wire stop_bit_detc,
            output wire bit_acc
    );
    wire MASTER_RST_BAR;
 //   wire clk;
    wire s_commline; // for rx and tx interconnection
 //   wire tx_wr_en;  // signal to wirte the data into TX
 //   wire [7:0]data_in; // for tx
    wire tx_en_tk; // baud tick for tx
 //   wire tx_busy;
    wire rx_en_tk;
 //   wire  [7:0]data_out; // for rx
 //   wire stop_bit_detc;
 //  wire  data_rdy;
    wire en_baud_tx;
    
    wire en_baud_rx;
    
    assign MASTER_RST_BAR=rst_bar;
    
    tx_module  tx1
          (
          .clk(clk),                 // Input clk
          .TX_wrt_en(tx_wr_en),              // Writing data into write data_in_reg
          .data_in(data_in),        // Parallel data in
          .baud_tick_Tx(tx_en_tk),        // Clk_en which starts transmission from baud rate generator
          .MASTER_RST_BAR(MASTER_RST_BAR),      // RESET 
          .Tx_serial(s_commline),           // Serial Data out
          .Tx_busy(tx_busy),              // Busy line indication
          .en_baud_tx(en_baud_tx)
          );
    
    
    
    rx_module rx1
        (           .clk(clk),                           // CLOCK
                    .Rx_serial(s_commline),              // RX_serial line 
                    .MASTER_RST_BAR(MASTER_RST_BAR),     // reset everything  
                    .RX_baud_tick(rx_en_tk),             // from the baud rate generator
                    .data_out(data_out),                 // Data output
                    .stop_bit_detc(stop_bit_detc),       // Stop bit detected
                    .RX_data_rdy(RX_data_rdy),               // data ready indication flag
                    .en_baud_rx(en_baud_rx),
                    .bit_acc(bit_acc)
                    
        );
        
     baud_generator bg1(

            .MASTER_RST_BAR(MASTER_RST_BAR),
            
            .clk(clk),
            
            .Tx_en(tx_en_tk), // baud tick for Tx module
            
            .Rx_en(rx_en_tk),  // baud tick for Rx module
            
            .en_baud_rx(en_baud_rx), // enable signal from rx module
            
            .en_baud_tx(en_baud_tx)  // enable signal from tx module
    );
    
    
    
    
    
    
    
    
    
    
endmodule
