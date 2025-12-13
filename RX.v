
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
// Description: 1. Unless reset the data_out register holds the last value it received
//              2. Protection feature needed to be implemented at stop bit state and other states if required
//              3. Implement clock gating ?? 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//-------------------------------------------------------------------------------------------------------------
// Frequency 25MHz
// Baud rate 115200
//-------------------------------------------------------------------------------------------------------------



//-------------------------------------------------------------------------------------------------------------

// REF---> nandland,All about VLSI youtube channel

// DATA FRAME 
//[ [START bit low] [-- 8 bit data --] [STOP bit HIGH] ] Total 11 bit frame
// No parity bit included

//-------------------------------------------------------------------------------------------------------------

module Rx_module(
                        
                    input wire clk,                    // CLOCK
                    input wire Rx_serial,              // RX_serial line 
                    input wire MASTER_RST_BAR,         // reset everything
                    input wire rdy_clr,              // Clear the data ready flag
                    output wire data_rdy_flag,         // data ready indication flag
                    output reg[7:0] data_out,          // Data output
                    output reg stop_bit_detc           // Stop bit detected

                );


//-----------------------------------------------------------------------------------------------------------------------------------
// Baud rate generator controll part (Inbuilt in Rx module) // 

parameter factor = 1; //usually taken factor 16,current value will be changed later
    
parameter inputclk_freq=25000000; // unit Hz (25MHz clock as input)
    
parameter Baud_rate=115200;// unit bps

localparam Rx_en_count = inputclk_freq/(Baud_rate*factor); // calculating the suitable size for the Rx_en_count
 
localparam  num_ff_Rx_en= $clog2(Rx_en_count+1); // number of flip flops needed




//-----------------------------------------------------------------------------------------------------------------------------------

    reg [2:0] curr_state;            // Register to store the current state 
    reg [7:0] data_frm;              // Data byte is stored in this temporary register
    reg data_rdy;                    // Indicating the received data is ready to be read
         
    parameter BIT_INDEX_SIZE=3; // No of bits needed to represet the data byte
    reg [num_ff_Rx_en-1:0]sample_count;           // Used to sample the data from at the middle of the bit 
    reg [BIT_INDEX_SIZE-1:0] Bit_index_count;     // To count the index while receiving the data bits

   

//-----------------------------------------------------------------------------------------------------------------------------------
                // STATE definitions //


    parameter IDLE_ST = 3'b000;          // Stay idle until the start bit falling transition received
    parameter START_BIT_ST = 3'b001;     // When start bit detetced sample the start bit
    parameter DATA_BYTE_ST = 3'b010;     // Sample the data bit when rx_en signal is enabled
    parameter STOP_BIT_ST = 3'b011;      // Stop bit is sampled and move to the end state 
    parameter END_ST = 3'b100;           // Move the data from the register to the output register and also enable the ready signal

//----------------------------------------------------------------------------------------------------------------------------------
                 // Continous assignments // 

//assign data_rdy_flag = (data_rdy) && (~(rdy_clr)); //  The flag that shows whether the data is ready to be read
// Ready flag cleared by the data_rdy inbuilt method and externally cleared by the reader module using rdy_clr input

// assign reset_rx_sample_count_flag = (reset_rx_sample_count) || (1'b0); // Default value is zero but it can b reset by the state machine

//-----------------------------------------------------------------------------------------------------------------------------------

    always@(posedge clk)  // Same clock for the rx, tx and baud rate generator
        begin

            if(MASTER_RST_BAR==1'b0)
                begin

                    curr_state<=IDLE_ST;         // Stay in the IDLE state

                    data_out<=8'b00000000;       // Data out reg cleared

                    data_frm<=8'b00000000;       // Temporary reg cleared

                    data_rdy<=1'b0;              // data ready flag cleared

                    Bit_index_count<=3'd0;       // Bit index count cleared

                    sample_count<=0;             // Sampling count reset

                    stop_bit_detc<=1'b0;            // stop bit detected
            
                end
                    
            else 
                begin

                  if(rdy_clr)
                        begin
                            data_rdy<=1'b0;
                        end          
                   
                   case(curr_state)

                    // ----  IDLE state  ---- // 

                        IDLE_ST:

                            begin
                                
                          
                                sample_count<=0;    // Clear the sample count

                                Bit_index_count<=3'd0; //  clear the bit index count

                             //   data_rdy<=1'b0;    // Clear the data ready flag

                                stop_bit_detc<=1'b0;  //  Stop bit detected flag


                                if(Rx_serial==1'b0)

                                    begin

                                        curr_state<=START_BIT_ST;  // Rx_serial line showing '0' indicates first start bit


                                    end

                                else

                                    begin

                                        curr_state<=IDLE_ST;  // Until start bit is detected the stay in the IDLE state

                                    end

                            
                            end
                    
                    // ----  START_BIT_STATE  ---- //

                        START_BIT_ST:  // This state double checks if thhe Rx_serial is giving start bit or not,
                                       // by checking it by sampling 
                                       // and decide the next state based on the sampling result


                            begin

                                
                                // reset_rx_sample_count<=1'b0;

                                if(sample_count>=((Rx_en_count-1)/2)-1)  // Middle sample signal to be sent from the baud rate generator
                                            begin

                                                if (Rx_serial==1'b0)   // Start bit is confirmed

                                                    begin

                                                        curr_state<=DATA_BYTE_ST;  // Go to data sampling state

                                                        sample_count<=0;           // Reset the sample count

                                                        // reset the sample count since start bit sampling done
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

                                                sample_count<=sample_count+1;

                                                //increment the sampling count here since waiting
                                       
                                        end
                                                                      
                            end

                        // ---- DATA_BYTE_STATE ---- //

                     DATA_BYTE_ST:
                                    begin

                                        
                                       
                                        
                                        if(sample_count>=((Rx_en_count-1)/2))

                                            begin

                                                data_frm[Bit_index_count]<=Rx_serial; // Read the serial line and 

                                                // store data in the corresponding index position of the temporary register
                                                sample_count<=0;  //  -- >   reset the sample count               
                            
                                                Bit_index_count<=Bit_index_count+1'b1; // reset the Bit index count after each bit sampled successfully
                                            
                                        
                                                if(Bit_index_count<7)
                                                    begin
                                                        
                                                        curr_state<=DATA_BYTE_ST;         
                                                        // Data byte receiving in progress
                                                    

                                                    end
                                                else 
                                                    begin
                                                               
                                                        //Data byte receiving done
                                                        Bit_index_count<=0;
                                                                                            
                                                        // Go to stop state
                                                        curr_state<=STOP_BIT_ST;  


                                                    end 
                                            end

                                        else 
                                            
                                            begin
                                                    sample_count<=sample_count+1;

                                                    curr_state<=DATA_BYTE_ST;

                                            end

                                    end

                        // ---- STOP_BIT_STATE ---- //

                    STOP_BIT_ST:
                                    begin
                                   
                                       
                                        if(sample_count>=((Rx_en_count-1)/2)-1) 

                                            begin

                                                        curr_state<=END_ST;     // go to end state

                                                        sample_count<=0;        // sample count

                                                        stop_bit_detc<=1'b1;    // stop bit detected

                                                        

                                             end

                                            else 

                                                begin

                                                        stop_bit_detc<=1'b0;           //  Stop bit not detected
                                                        
                                                        curr_state<=STOP_BIT_ST;       // Stay until the stop bit is sampled 

                                                        // FEATURE IF STOP BIT NOT DETECTED EVEN IF TIMER OVERFLOWS
                                                        // Implement the protection 
                                                        // Abort the process or something will do

                                                        sample_count<=sample_count+1;  // Increment the sample counter

                                                end           

                                     end                  

                                

                        // ---- END STATE ---- //

                    END_ST:
                                begin

                                    curr_state<=IDLE_ST;  // Go to IDLE state 

                                    data_out<=data_frm;   // Pass the data byte sampled to the data_out reg

                                    data_rdy<=1'b1;       // Enable the data ready flag

                                    data_frm<=8'b0;       // Data frame reset

                                end
                    default: 
                                begin

                                    curr_state<=IDLE_ST;  //  set Current state IDLE state by default

                                end         
                                    
                   endcase

                end

        end

endmodule
