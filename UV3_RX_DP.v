

module UV3_RX_DP(
                input wire Rx_serial,     // Serial data from the Tx module
                input wire clk,           // Clock
                input wire RST,           // Master reset
                input wire baud_tick,     // from baud rate generator
                input wire tick,          // from the controller which signals to sample the data 
                input wire inc_Scount,    // increment signal for sample count
                input wire inc_BiCount,   // increment signal for bit index
                input wire rst_sample_count, // reset sample count
                input wire clear_data,       // reset the data register
                input wire rst_bit_index_count, // reset bit index count

                output wire start_bit_edge,     // start bit edge
                output reg [7:0]data_out,       // data_out 
                output wire Rx_CP,          // Rx_synchronised for the controll path
                output wire  [3:0]DS_count, // For control path (Data sample count)
                output wire  [2:0]BI_count  // For the control path
    );



    
    parameter SCount   = 4;      // 4 bit sample count to count till 16 for oversampling 
    parameter BiCount  = 3;      // 3 bit index count to count till 8 bits 

    
    // Rx_Serial-->Rx_sync1-->Rx_sync2-->Rx_in
    // 3 stage RX receiver synchroniser

    reg Rx_sync_1,Rx_sync_2,Rx_in;      // Flip flops for synchronising
    reg [SCount-1:0]samp_count;         // sample count
    reg [BiCount-1:0]bit_index_count;   // bit index count
    reg [7:0] S_Data_reg;               // Shift data SIPO register
    
   assign Rx_CP=Rx_in; // For the control path


   //-----------------------------------------------
   assign start_bit_edge=(((Rx_sync_2)&&(~Rx_in)));  // detect the start bit using the values in the flip flops
   //-----------------------------------------------
   
   assign DS_count=samp_count;         // sampling count for the control path
   assign BI_count=bit_index_count;    // bit index count for the control path


   // LOW Signal coming -->  Falling edge of the RX line as start bit

    always@(posedge clk or posedge RST)
        begin
            if(RST==1)
                begin
                    data_out<=8'd0;
                end
            else if((data_valid==1))  // if data valid signal come from controller then accept the data
                    begin
                        data_out<=S_Data_reg; // data out register updated with the newly receieved data
                    end
                       
        end    
// Synchronising 
    always @(posedge clk or posedge RST) 
            begin
                    if(RST==1'b1)
                        begin   
                                Rx_sync_1<=0;
                                Rx_sync_2<=0;
                                Rx_in<=0;
                        end

                    else // Synchronising the signals using 3 stage synchroniser
                        begin
                                Rx_sync_1<=Rx_serial;
                                Rx_sync_2<=Rx_sync_1;   
                                Rx_in<=Rx_sync_2;  // Rx_in is the synchronised signal for the Receiver
                        end 
                       
            end


    // Data path
    always @(posedge clk or posedge RST)
        begin
             if(RST==1'b1)
                begin   
                    samp_count       <= 0;
                    bit_index_count  <= 0;
                    S_Data_reg       <= 0; 
                end
            else  
                begin

                    if(clear_data==1'b1)
                        begin
                            S_Data_reg<=8'd0;
                        end
                    else if(tick==1 && clear_data==1'b0)
                        begin

                            S_Data_reg<= {S_Data_reg[6:0],Rx_in};  // shift in the data 
                            
                          
                            if (rst_bit_index_count==1) // bit index count reset 
                                begin
                                    bit_index_count<=2'd0;  
                                end
                            else if(inc_BiCount==1)  // Bit index count incremented by the controller
                                begin
                                    bit_index_count<=bit_index_count+1'b1;
                                end
                        end
                    end
            end
        

// Oversampling 
    always @(posedge clk or posedge RST)
            begin
                if((RST==1'b1)||(rst_sample_count==1'b1)) 
                // reset the sample count when master reset or the reset signal from the controller comes
                    begin
                        samp_count<=0;
                    end
                else if (baud_tick & inc_Scount)
                // Baud tick and the increment signal comes, increment the sample count
                    begin  
                        samp_count<=samp_count+1'b1;
                    end

            end
             
      
endmodule
