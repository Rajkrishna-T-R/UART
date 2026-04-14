`timescale 1ns/1ps

module UV3_RX_CP(
                    input wire Rx_in, // Synchronised RX signal from the Rx data path module
                    input wire clk,   // clock
                    input wire RST,   // Master reset
                    input wire clear_done, // clear done flag
                    input wire [3:0]DS_count, // DS_count(data sampling count)
                    input wire [2:0]BI_count, // BI_count(bit index count)
                    input wire start_bit_edge, // from the data path
                    input wire baud_tick_RX,   // from the baud rate generator
                    output reg data_valid,     // data valid signal 
                    output reg clear_data,     // for clearing the received data 
                    output reg inc_BiCount,    // increment the bit index count
                    output reg inc_Scount,     // increment the sample count
                    output reg done_Rec,       // done receival
                    output reg rst_sample_count,    // reset the sample count
                    output reg sample_data_en,
                    output reg rst_bit_index_count, // reset signal for th bit index count
                    output reg start_baud,    // Signals the brg to start baud rate genration for RX
                    output reg tick       // baud tick signal to data path of Rx
                                          // data path that will sample the data
                                          // connected to the tick signal of the RX data path module
    );


 reg [1:0]Curr_state; // Current state register
 reg [1:0]Next_state; // Next state register


       // STATE DEFINITIONS //
    //------------------------------------//
    parameter IDLE_ST=2'b00; // Idle state   ---> Stay in the IDLE state when there is no data coming
    parameter START_ST=2'b01;// Start state  ---> Start bit detection 
    parameter DATA_ST=2'b10; // Data state   ---> Data sampling state
    parameter STOP_ST=2'b11; // Stop state   ---> Stop bit state for stoping the transmission 
    //------------------------------------//

// FSM
// State update using sequential design
    always @(posedge clk or posedge RST)
        begin
            if(RST==1'b1)
                begin
                    
                    Curr_state<=IDLE_ST; 
                    
// if the start bit is not detected stay in the IDLE state


                end

            else 
                begin

                    Curr_state<=Next_state;

// State updation whenever the state changes

                end


        end

// control signal generation using combinational design

    always @(*)
        begin   
                // initialize to zero
                inc_BiCount=0;
                inc_Scount=0; 
                rst_sample_count=0; 
                rst_bit_index_count=0;
                tick=0;             
                clear_data=0;       
                
                
            case (Curr_state)
                    IDLE_ST:begin 
                             start_baud=0; // initially Zero
                             sample_data_en=0;
                                if(start_bit_edge==1)
                                    begin
                                        Next_state=START_ST; // next state will be start bit state 
                                        rst_sample_count=1;   // reset the sample count
                                        rst_bit_index_count=1; // reset the bit index count
                                        clear_data=1; //clear the shift register
                                    end
                                else
                                    begin
                                        Next_state=IDLE_ST;  // If no start bit then remain in the IDLE state
                                    end
                            end

                    START_ST:begin
                                inc_Scount=1;
                                sample_data_en=0;
                                rst_sample_count=0; 
                                rst_bit_index_count=0;
                                start_baud=1;  // start baud rate generation
                                inc_BiCount=0; //  donot increment the bit index count
//________________________________________________________________________________________________
// In the start bit since the count reset at the start bit detection next data step onwards
// Move sample the data at count = 15 which will be middle of each bits.  ----  ? This is not correct i think
// Becox tx module send data in  regular intervals
// _______________________________________________________________________________________________
                                if((DS_count==4'd7)&&(baud_tick_RX==1'b1)) // baud tick and middle count signals to sample the data
                                    begin

                                      if(Rx_in==1'b0) // detecting the start bit

                                        begin

                                            Next_state=DATA_ST; // go to the next state if start bit detected
                                            rst_sample_count=1; // Reset the sample count
                                        end

                                      else
                                            begin
                                                
                                                Next_state=IDLE_ST;     // if not zero go back to the idle state
                                                // Go back to idle state if no start bit detected

                                            
                                            end
                                    end
                                else 
                                    begin

                                        Next_state=START_ST; // Stay in the start bit state and wait for start bit detection
        
                                    end
                             end

                    DATA_ST:begin
                                inc_Scount=1; // Sample count starts incrementing 
                                clear_data=0; // disable clear signal to receive data 
                                rst_sample_count=0;
                                sample_data_en=1;
                                start_baud=1; // keep generating the baud rate
                                if((DS_count==4'd15)&&(baud_tick_RX==1'b1))
                                    begin
                                        tick=1;
                                        inc_BiCount=1; 
                                        
                                        if(BI_count==3'd7)
                                        // When 8 bits received go to stop bit state
                                        // else stay in the data state
                                        // increment the bit index count since the there is new data received
                                            begin
                                                Next_state=STOP_ST;
                                            end
                                        else    
                                            begin
                                                Next_state=DATA_ST;
                                                
                                            end
                                    end
                                else 
                                // tick=0
                                // do not increment bit index as there is no new data received
                                    begin
                                        tick=0;
                                        inc_BiCount=0; 
                                        Next_state=DATA_ST;
                                    end
                                
                            end

                    STOP_ST:begin
                                inc_Scount=1; // Sample count starts incrementing
                                sample_data_en=0;
                                start_baud=1; // keep generating the baud rate
                                if((DS_count==4'd15) && (baud_tick_RX==1'b1) )
                                    begin
                                // When stop bit received successfully the go to IDLE state     
                                        Next_state=IDLE_ST;  
                                        tick=1;   
                                    end
                                else 
                                // Else stay in the STOP bit state
                                    begin
                                        Next_state=STOP_ST;
                                        tick=0;
                                    end
                            end

                    default: begin
                        // stay in the IDLE state by default
                                Next_state=IDLE_ST;
                             end          
            endcase 
            
            
        end

// Valdity check using the stop bit 
always @(posedge clk or posedge RST)

    begin
    
        if(RST==1)
            begin   
                data_valid=0;
            end
        else 
            begin
               if((Curr_state==STOP_ST)&&(DS_count==4'd7)&&(baud_tick_RX==1)&&(Rx_in==1))
                    begin
        
        // data valid if the stop bit received in the stop bit stage at baud count = 8 
        // and the baud tick signal comes and the Rx_in currently carries bit = 1
                        data_valid<=1;
                    end
                    
              else if ((Curr_state==STOP_ST)&&(DS_count==4'd7)&&(baud_tick_RX==1)&&(Rx_in==0))
                    begin
        
        // data invalid if the stop not bit received in the stop bit stage at baud count = 8 
        // and the baud tick signal comes and the Rx_in currently carries bit = 0
                        data_valid<=0;
                    end
                else 
                    data_valid<=data_valid;
             end
    end

always@(posedge clk or posedge RST)
    if(RST==1 || clear_done==1)
        begin
            done_Rec=0; // reset the data valid flag
        end    
    else 
        begin
            done_Rec=((data_valid==1)&&(Curr_state==STOP_ST) && (baud_tick_RX==1) && (DS_count==4'd15)); // When the data is received fully
            // receival is done when the above conditions are satisfied 
            // At DS count = 15 the receival process is complete the validity is separatly 
            // calculated 
        end
endmodule
