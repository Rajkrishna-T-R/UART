`timescale 1ns / 1ps


module RX
         (
            input wire clk,               // clock 
            input wire Rx_en,             // Rx enable signal from Baud rate generator
            input wire Rx,                // Rx line
            input wire rst,               // RESET
            input wire data_rdy_clr,      // data_rdy_clr
            output reg[7:0] data,         // received Data output
            output reg data_rdy           // Data ready indication

         );

    parameter START=2'b00;  // START
    parameter SAMPLE=2'b01; // SAMPLE DATA
    parameter STOP=2'b10;   // STOP 

    reg [7:0]data_frm;     // 8 bit data frame
    reg [2:0]idx_count;    // For Tracking the index of data bits
    reg [1:0]curr_state;   // Current state
    reg [1:0]next_state;   // Next state
    reg [3:0]sample_count; // Sampling counter for oversampling purposes (over sampling of 16 needed)
    
    


    always@(posedge clk)
        begin

        
            if(rst==1'b1)
                begin
                        curr_state<=START;     // Resetting the Rx module 
                        data<=0;               // Data out reset
                        data_rdy<=0;           // Indicating data not ready
                        idx_count<=0;          // Index count
                        sample_count<=4'd0;    // Reset the sample count
                end
                
            else if(data_rdy_clr==1'b0)
                begin
                        data_rdy<=0;        // Data ready indication reset
                        data<=8'b0;         // Data reset
                        idx_count<=3'b0;    // Index count reset
                end

            else 
                begin
                        
                curr_state<=next_state; // State transition

                end


         

            if(Rx_en==1'b1)

                case(curr_state)
                
                START:
                        begin
                                if(Rx==1'b0 || sample_count!=4'd0) // Pulling the Rx line down for --> Starting the receiving process <--
                                        begin
                                                sample_count<=sample_count+1'b1; // Sampling count being incremented 
                                                // --> First triggered by the Rx=0 condition
                                                // --> Then sample count not equal to zero so that the same loop triggers again and count incremented 
                                                next_state<=START;              
                                        end
                                

                                else if(Rx==1'b1 && sample_count==4'd8) 
                                        begin
                                                next_state<=SAMPLE;              // state change
                                               // sampled_bit<=Rx;               //first sample bit stored
                                        end
                                else                          // Max of sampling count reached
                                        begin
                                                sample_count<=4'b0;                  // assigning Sample count to 0
                                                //  data<=8'b0;
                                                idx_count<=0;                        //  Index count assigned to zero
                                                next_state<=START;              
                                        end
                                    
                        end

                 SAMPLE:
                     begin

                         sample_count<=sample_count+1'b1;                        //  The non blocking assignment samples the data and also 
                                                                                 //  Sample count incremented at the same time
 
                                if(sample_count==4'd8)                           //  Sampling each data bit
                                    begin
                                            next_state <= SAMPLE;                  // Same state
                                            data_frm[idx_count] <= Rx;             // Assign the bit of Rx to the position corresponding to index
                                            idx_count <= idx_count+1'b1;           // Increment the index to the next position only if data received                      
                                    end 

                               if(idx_count==3'd8 && sample_count==4'd15)        // Sampling of the last data bit is done
                                    begin
                                            next_state <= STOP;                    // Sampling done 8 bit data received. Go to Stop state.
                                    end

                        
                     end

                 STOP:
                     begin
                                            
                                            
                                   if(sample_count==4'd15)                     // Sampling of the stop bit is done 
                                        begin
                                            next_state<=START;                 // Go to start state
                                            sample_count<=4'd0;                // Sample count reset
                                            data<=data_frm;                    // Transfer the data received to the output port
                                            data_rdy<=1'b1;                     // Signal for letting know data is ready to be read
                                        end
                                 else
                                        begin
                                                sample_count<=sample_count+1'b1; // Sampling of the stop bit being
                                                next_state<=STOP;               // Stay in the stop state until sampling is completed
                                        end
                     end
                default:  
                        begin
                                next_state<=START;                                      //  dafault to the start state
                                data<=8'b0;                                             //  Data cleared
                                data_rdy<=1'b0;                                          // Data not ready to be read
                        end
            endcase

                
        end

endmodule
