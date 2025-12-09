`timescale 1ns/1ps

module Tx
        (
          input wire clk,          // Input clk
          input wire wrt_en,       // Writing data into write data_in_reg
          input wire [7:0]data_in, // Parallel data in
          input wire Tx_en,        // Clk_en which starts transmission from baud rate generator
          input wire rst,          // RESET 
          output reg Tx,           // Serial Data out
          output wire Tx_busy      // Busy line indication
          );

reg [7:0]data_in_reg;    //  Data received from data input (8 bit data)


reg [2:0]count;       // Transmitted data count 8 bit data

parameter  IDLE  = 2'b00; // IDLE state
parameter  START = 2'b01; // START state
parameter  TRAM  = 2'b10; // TRANSMITTING state
parameter  STOP  = 2'b11; // STOP state

reg [1:0] curr_state;  // Current state  

reg [1:0] next_state;  // Next state


assign Tx_busy=(curr_state!=IDLE);


always @(posedge clk) 

    begin
            if(rst==1'b1)
                begin   
                        next_state<=IDLE;                     
                end
                
            else
                begin
                        curr_state<=next_state;                       
                end

   

            case(curr_state)
                
               
                IDLE:
                  begin

                    if(wrt_en==1'b1)
                        begin
                            next_state<=START;    // NEXT STATE ASSIGNMENT

                            data_in_reg<=data_in; // Storing the data to be transmitted

                            count<=3'd0;          // count of transmitted bits

                            Tx<=1'b1;             // Keeping the Tx line High
                        end
                    else 
                            begin
                                    next_state<=IDLE;

                                    Tx<=1'b1;   // Default Tx line kept at high

                                    count<=3'd0;

                            end

                 end       
                START: 
                     begin 
                        
                        if(Tx_en==1'b1) // Tx_en signal from baud rate generator

                            begin
                                        Tx<=1'b0;           //  Tx Line pulled down

                                        next_state<=TRAM;   //  Assigning the next state as Transmit

                            end      

                        else 

                            begin

                                        next_state<=START; //  Stay in the start state until Tx_en signal comes
                                        
                                        Tx<=1'b0;          //  Tx line kept at low since currently at start state
                                
                            end
                      
                     end

                TRAM: 
                      begin

                         if(count==3'd7) 
                            begin   
                                    next_state<=STOP;  // Next state : stop state
                                    
                                    Tx<=1'b0;          // Stop bits at the last place

                            end
                       else
                           begin  
                                
                                if(Tx_en==1'b1)
                                    begin

                                            count<=count+1;         // Increment the count

                                            Tx<=data_in_reg[count]; // LSB out

                                           // data_in_reg<={1'b0,data_in_reg[7:1]};     // Shifting the data (right shift)

                                            next_state <= TRAM; // Still transmitting

                                           
                                    
                                    end
                                else 
                                    begin                                     

                                            count<=count;        // Count kept same if no bit transfered
                                            // This condition may not occur since the transmission is continuously done

                                            next_state<=TRAM;    // Still in transmitting state

                                    end

                           end

                      end
                STOP: 
                    begin 

                    Tx<=1'b1;          // Pulled to high

                    if(Tx_en==1'b1)
                        begin   

                            next_state<=IDLE; // RESTART
                            count<=0;

                            
                        end

                    else
                        begin
                            
                           next_state<=STOP;   // After the last bit transmitted stop the transmission
                           count<=0;
                        
                        end
                    end

                default: 
                    begin   

                        next_state<=IDLE;   //  By default stay in the IDLE state
 
                        Tx<=1'b1;           // Tx line kept at high

                        count<=0;

                    end
            endcase


        end


endmodule
