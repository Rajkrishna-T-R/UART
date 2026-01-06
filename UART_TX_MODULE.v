
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02.01.2026 18:36:07
// Design Name: 
// Module Name: tx_module
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


module tx_module(

              input wire clk,                 // Input clk
              input wire TX_wrt_en,              // Writing data into write data_in_reg
              input wire [7:0]data_in,        // Parallel data in
              input wire baud_tick_Tx,        // Clk_en which starts transmission from baud rate generator
              input wire MASTER_RST_BAR,      // RESET 
              output reg Tx_serial,           // Serial Data out
              output reg Tx_busy,              // Busy line indication
              output wire en_baud_tx
          );

reg [7:0]data_in_reg;    //  Data received from data input (8 bit data)


reg [2:0]tr_bit_count;       // Transmitted data count 8 bit data

parameter  TX_IDLE_ST  = 2'b00; // IDLE state
parameter  TX_START_ST = 2'b01; // START state
parameter  TX_TRAM_ST  = 2'b10; // TRANSMITTING state
parameter  TX_STOP_ST  = 2'b11; // STOP state

reg [1:0] TX_curr_state;  // Current state  

assign en_baud_tx=(TX_curr_state!=(TX_IDLE_ST));



always @(posedge clk) 

    begin
            if(MASTER_RST_BAR==1'b0)

                begin   
                        TX_curr_state<=TX_IDLE_ST;     // Stay in the IDLE state   

                        tr_bit_count<=0; // keep the bit count zero
                      
                        Tx_busy<=1'b0; //status needed here?

                        Tx_serial<=1'b1; // Stay high
                        
                        data_in_reg<=8'd0;


                end
                
                
            else
            
                begin
                         

                        Tx_busy<=(TX_curr_state!=TX_IDLE_ST); // Tx line is not busy when machine in IDLE state   
                
                
   

                case(TX_curr_state)
                    
                
                    TX_IDLE_ST:
                    begin
                         

                                if ((TX_wrt_en==1'b1) && (Tx_busy!=1)) // New data must be written only when the System is free and not when it is transmitting
                                    begin
                                        TX_curr_state<=TX_START_ST;           // NEXT STATE ASSIGNMENT

                                        data_in_reg<=data_in;        // Storing the data to be transmitted

                                        tr_bit_count<=3'd0;          // count of transmitted bits

                                        Tx_serial<=1'b1;             // Keeping the Tx line High
                                    end
                                else 
                                    begin
                                    
                                        TX_curr_state<=TX_IDLE_ST; // Stay in the IDLE state

                                        Tx_serial<=1'b1;         // Default Tx line kept at high

                                    end
                            

                    end       
                    TX_START_ST: 
                    
                        begin 
                            
                            Tx_serial<=1'b0;    //  Tx Line pulled down for start bit
                            
                            if(baud_tick_Tx==1'b1) // Tx_en signal from baud rate generator

                                begin
                                           

                                            TX_curr_state<=TX_TRAM_ST;   //  Assigning the next state as Transmit
                                                // state transition here
                                end      

                            
                        
                        end

                    TX_TRAM_ST: 
                        begin
                            if(baud_tick_Tx==1'b1)
                                begin

                                     Tx_serial<=data_in_reg[0];      // LSB out

                                    data_in_reg<={1'b0,data_in_reg[7:1]};            // right shift logical

                                    if(tr_bit_count==7) // not <= 7 since the UART must not wait till next tik to go to stop bit state
                                       
                                        begin
                                                TX_curr_state<=TX_STOP_ST;  // Next state : stop state
                                                
                                                tr_bit_count<=0;
                                        end

                                    else
                                        begin   
                                       
                                                 tr_bit_count<=tr_bit_count+1;            // Increment the count

                                                TX_curr_state<=TX_TRAM_ST; // Transmit the data


                                                //Bit7 is transmitted
                                                //Immediately moves to STOP_ST
                                                //No extra baud delay
                                                // suggestion from AI                                             
                                        end
                                end
                      

                        end

                    TX_STOP_ST: 
                        begin 

                                 

                        if(baud_tick_Tx==1'b1)
                            begin   
                                
                                Tx_serial<=1'b1;     // stop bit

                                TX_curr_state<=TX_IDLE_ST; // RESTART
                                
                            end

                        else
                            begin
                                    
                                TX_curr_state<=TX_STOP_ST;   // wait till stop bit transmitted
                                
                            end
                        end

                    default: 
                        begin   

                            TX_curr_state<=TX_IDLE_ST;   //  By default stay in the IDLE state
    
                        end
                endcase


            end
    end


endmodule
