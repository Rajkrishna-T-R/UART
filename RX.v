`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: RAJKRISHNA T R
// 
// Create Date: 10.12.2025 14:23:42
// Design Name: 
// Module Name: Rx_module
// Project Name: UART
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

/* 
     ----- ISSUES -----

1. The reset signals fighting eachother 
2. The timing management with the baud rate count and things need to be checked


*/







// REF---> nandland,All about VLSI youtube channel

// DATA FRAME 
//[ [START bit low] [-- 8 bit data --] [STOP bit HIGH] ] Total 11 bit frame
// No parity bit included

module Rx_module(
                    input wire clk,                    // CLOCK
                    input wire Rx_serial,              // RX_serial line 
                    input wire Rx_en,                  // Rx_en from the baud rate generator
                    input wire MASTER_RST_BAR,         // reset everything
                    input wire  data_rdy_clr,          // Clear the data ready indication flag - overwrites the value set by the module
                    output wire data_rdy_flag,               // data ready indication flag
                    output reg[7:0] data_out,          // Data output
                    output wire reset_rx_sample_count_flag   // Signal to baud rate generator reset the count for RX (Sample count)
                 // output reg reset_tx_sample_count   // Signal to baud rate generator reset the count for TX
    );



    reg [2:0] curr_state;            // Register to store the current state 
    reg [7:0] data_frm;              // Data byte is stored in this temporary register
    reg data_rdy;
    reg reset_rx_sample_count;       

  //  reg [4:0]sample_count;           // Used to sample the data from at the middle of the bit 
    reg [3:0] Bit_index_count;       // To coutn the index while receiving the data bits

    parameter IDLE_ST = 3'b000;          // Stay idle until the start bit falling transition received
    parameter START_BIT_ST = 3'b001;     // When start bit detetced sample the start bit
    parameter DATA_BYTE_ST = 3'b010;     // Sample the data bit when rx_en signal is enabled
    parameter STOP_BIT_ST = 3'b011;      // Stop bit is sampled and move to the end state 
    parameter END_ST = 3'b100;           // Move the data from the register to the output register and also enable the ready signal

    assign data_rdy_flag = (data_rdy) && (~(data_rdy_clr)); //  The flag that shows whether the data is ready to be read
    assign reset_rx_sample_count_flag = (reset_rx_sample_count) || (1'b0); // Default value is zero but it can b reset by the state machine

    always@(posedge clk)  // Same clock for the rx, tx and baud rate generator
        begin

            if(MASTER_RST_BAR==1'b0)
                begin

                    curr_state<=IDLE_ST;         // Stay in the IDLE state

                    data_out<=8'b00000000;       // Data out reg cleared

                    data_frm<=8'b00000000;       // Temporary reg cleared

                    data_rdy<=1'b0;              // data ready flag cleared

                    Bit_index_count<=3'd0;       // Bit index count cleared

                    reset_rx_sample_count<=1'b1; // reset the count for RX

                 //   reset_tx_sample_count<=1'b1; // reset the count for TX

            

                end
                    
            else 
                begin

                       
                 
                    

                   case(curr_state)

                    // ----  IDLE state  ---- // 

                        IDLE_ST:
                            begin
                                
                             //    reset_rx_sample_count<=1'b1; // Clear the RX enable count (Sample count)

                             //         sample_count<=4'd0;    // Clear the sample count

                                Bit_index_count<=3'd0; //  clear the bit index count

                                data_rdy<=1'b0;    // Clear the data ready flag


                                if(Rx_serial==1'b0)

                                    begin

                                        curr_state<=START_BIT_ST;  // Rx_serial line showing '0' indicates first start bit
                                        reset_rx_sample_count<=1'b1; // start sampling the start bit

                                    end

                                else

                                    begin

                                        curr_state<=IDLE_ST;       // Until start bit is detected the stay in the IDLE state

                                    end

                            
                            end
                    
                    // ----  START_BIT_STATE  ----//

                        START_BIT_ST:  // This state double checks if thhe Rx_serial is giving start bit or not, by checking it by sampling 
                                       // and decide the next state based on the sampling result


                            begin

                                // reset_rx_sample_count<=1'b0;

                                if(Rx_en==1'b1)  // Middle sample signal from the baud rate generator
                                            begin
                                                
                                                 
                                       //         sample_count<=sample_count+1'b1; // ? Increment the sample count when Rx_en signal is high

                                                if (Rx_serial==1'b0)   // Start bit is confirmed

                                                    begin

                                                        curr_state<=DATA_BYTE_ST;  // Go to data sampling state

                                                        reset_rx_sample_count<=1'b1;

                                          //              sample_count<=0;           // ? reset the sample count since start bit sampling done
                                                        // reset signal might be to send to the baud rate generator

                                                    end
                                                else
                                                    begin

                                                        curr_state<=IDLE_ST;         
                                                           // Rx_serial line is not pulled down so not start bit
                                                        // Double checking failed so return back to idle state

                                                    end
                                        

                                            end
                                else 
                                        begin
                                                curr_state<=START_BIT_ST;

                                               

                                                // Increment the sampling count here since waiting
                                        end
                                                                      
                            end
                        // ---- DATA_BYTE_STATE ---- //
                     DATA_BYTE_ST:
                                    begin

                                   //      reset_rx_sample_count<=1'b0;
                                        
                                   //      sample_count<=sample_count+1; // ??This should be in the baud rate module or should be in the top of this module?

                                        if(Rx_en==1'b1)

                                            begin

                                                data_frm[Bit_index_count]<=Rx_serial; // Read the serial line and 

                              // store data in the corresponding index position of the temporary register
                              // sample_count<=4'd0;    -- >   reset the sample count               
                              

                                                reset_rx_sample_count<=1'b1; // reset sampling count

                                                Bit_index_count<=Bit_index_count+1'b1; // reset the Bit index count after each bit sampled successfully
                                            
                                        
                                                if(Bit_index_count<7)
                                                    begin
                                                        
                                                        curr_state<=DATA_BYTE_ST;         
                                                        // Data byte receiving in progress
                                                    

                                                    end
                                                else 
                                                    begin
                                                        curr_state<=STOP_BIT_ST;           
                                                        //  Data byte receiving done
                                                                                            
                                                                                            // Go to stop state
                                                        Bit_index_count<=0;
                                                    end 
                                            end

                                    end

                        // ---- STOP_BIT_STATE ---- //
                    STOP_BIT_STATE:
                                    begin
                                   //     reset_rx_sample_count<=1'b0;
                                   //     sample_count<=sample_count+1;

                                        if(Rx_en==1'b1)

                                            begin

                                               if(Rx_serial==1'b1) // Stop bit detected

                                                    begin

                                                        curr_state<=END_ST;           
                                                        
                                //         Automatically zero since the count reaches the maximum value  sample_count<=4'd0;

                                                    end

                                                else 

                                                    begin

                                                        curr_state<=STOP_BIT_ST;

                                                    end

                                            end                  

                                    end

                        // ---- END STATE ---- //

                    END_ST:
                                begin

                                    curr_state<=IDLE_ST;

                                    data_out<=data_frm;

                                    data_rdy<=1'b1;

                                end
                    default: 
                                begin

                                    curr_state<=IDLE_ST;

                                end         
                                    
                   endcase

                end

        end

endmodule
