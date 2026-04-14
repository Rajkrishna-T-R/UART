
module UV3_TX_CP(
        input wire clk, // Clock
        input wire RST, // reset
        input wire clear_done, // clear the done flag
        input wire baud_tick_Tx, // baud tick signal from baud rate generator
        input wire[2:0]data_bit_count, // data bit counting purposes 
        input wire Tx_serial, // The Tx_serial line from Data path 
        input wire Start,     // Start signal from the driver
        output reg load_data, // Load data signal to the data path
        output reg shift_data,// shift data signal to the data path
        output reg TX,        // Tx line for sending
        output reg rst_bit_count,
        output reg done_Tra  // Transmission done signal
    );



// state definitions
parameter IDLE_ST  = 2'b00;
parameter START_ST = 2'b01;
parameter DATA_ST  = 2'b10;
parameter STOP_ST  = 2'b11;


reg [1:0]Curr_state;
reg [1:0]Next_state;


// State assignment
always@(posedge clk or posedge RST)
    begin
        if(RST==1)
            begin
                Curr_state<=IDLE_ST;
            end
        else 
            begin
                Curr_state<=Next_state;
            end
    end

reg done; // done transmission signal(internal) [ not used ]
// Next state and output  

reg latch_start; // for storing the start signal

// This block ensures that the start bit duration wont get affected due to the baud tick allginment 
//  mismatch due to the delay between the transmission of data bytes

always@(posedge clk or posedge RST)
    begin
        if(RST==1)
            begin
                latch_start<=0; // reset the signal
            end
        else if(Start==1)
            begin
                latch_start<=1; //Store the start signal
            end
        else if((Curr_state==IDLE_ST) && (Next_state==START_ST))
            begin
                latch_start<=0; 
                // clear the signal when the state transition is decided
            end
     end

always@(*)

        begin   // initializations

        rst_bit_count=1'b0;
        load_data=1'b0;
        TX=1'b1; // By default the line is kept at high 
        shift_data=1'b0;
       
        
       
        
        case(Curr_state)
            IDLE_ST:
                begin
                        if(latch_start==1 && baud_tick_Tx==1) // start transmission when baud tick comes and the
                        // start signal is high
                // This ensures the baud tick is aligned and the duration of each bit will be uniform
                // start , data , stop bits will be aligned in a uniform manner
                            begin
                                load_data=1; // load the data 
                                Next_state=START_ST;
                                // go to the start state
                            end
                        else 
                            begin
                                Next_state=IDLE_ST;
                                // go back to idle state
                            end
                 end
            START_ST:
                    begin
                        TX=1'b0; // Keep the TX line Low for entire start bit state
                        if(baud_tick_Tx==1)
                            begin
                                Next_state=DATA_ST;
                            end
                        else 
                            begin
                              
                                Next_state=START_ST;
                            end
                    end
            DATA_ST:
                    begin  
                        TX=Tx_serial; // Data transmitting 
                        if(baud_tick_Tx==1'b1)
                            begin
                                shift_data=1;
                                
                                if(data_bit_count==7) 
                                    begin
                                        Next_state=STOP_ST;
                                        
                                    end
                                else
                                    begin
                                        Next_state=DATA_ST;
                                    end
                                

                            end
                        else 
                            begin
                                Next_state=DATA_ST;
                            end                        
                    end
            STOP_ST:
                    begin
                        TX=1'b1; // Hold TX to 1 
                        rst_bit_count=1'b1;
                        if(baud_tick_Tx==1'b1)
                            begin
                                
                                Next_state=IDLE_ST;
                               
                               
                                
                                
                            end
                        else
                             begin
                                    Next_state=STOP_ST;
                             end
                    end

            default:
                    begin
                        Next_state=IDLE_ST;
                    end


        endcase

        end
        
always@(*)
    begin
        if(clear_done==1 || RST==1)
            begin   
                done_Tra=0;  
            end
        else if ((Curr_state==STOP_ST) && (baud_tick_Tx==1))
            begin
            // Curr state is stop bit state and the when the baud tick comes after reaching 
            // stop bit state the done transmission signal is activated
                done_Tra=1;
                // All data bits transmitted
            end
        else 
            begin
                done_Tra=0;
            end
    end
endmodule
