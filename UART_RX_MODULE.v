

module rx_module
        (           input wire clk,                    // CLOCK
                    input wire Rx_serial,              // RX_serial line 
                    input wire MASTER_RST_BAR,         // reset everything
                    
                    input wire RX_baud_tick,               // from the baud rate generator
                    output reg [7:0] data_out,          // Data output
                    output reg stop_bit_detc,          // Stop bit detected
                    output reg RX_data_rdy,                // data ready indication flag
                    
                    output wire en_baud_rx,               // start baud tick
                    
                    output wire bit_acc          // signal which shows bit is accepted
                    
        );

//--------------------------------------------------------------------------------------------------------------------------------------------------


    reg [2:0] RX_curr_state;            // Register to store the current state 
   
    reg [7:0] data_frm;              // Data byte is stored in this temporary shift register
   
  


    parameter RX_BIT_INDEX_SIZE=3;                   // No of bits needed to represet the data byte
    parameter num_ff_sc = 4;                      // oversampling for 16 counts

    reg [5:0]sample_count;                // Used to sample the data from at the middle of the bit 
    reg [RX_BIT_INDEX_SIZE-1:0] RX_Bit_index_count;     // To count the index while receiving the data bits
    
    parameter sample_count_start=22; // sample start bit at this count
    parameter sample_count_data=15;  // sample data bit at this count
    parameter sample_count_stop=15;  // sample stop bit at this count
//--------------------------------------------------------------------------------------------------------------------------------------------------

                // STATE definitions //


    parameter RX_IDLE_ST      = 3'b000;          // Stay idle until the start bit falling transition received
    parameter RX_START_BIT_ST = 3'b001;     // When start bit detetced sample the start bit
    parameter RX_DATA_BYTE_ST = 3'b010;     // Sample the data bit when rx_en signal is enabled
    parameter RX_STOP_BIT_ST  = 3'b011;      // Stop bit is sampled and move to the end state 
    parameter RX_END_ST       = 3'b100;           // Move the data from the register to the output register and also enable the ready signal

//--------------------------------------------------------------------------------------------------------------------------------------------------    
    // clock synchronizer from AI suggestion, need to study

   /* reg buf1_syn;
      reg buf2_syn;

    always@(posedge clk)
        begin
            buf1_syn<=Rx_serial;
            buf2_syn<=buf1_syn;
        end
  */
//--------------------------------------------------------------------------------------------------------------------------------------------------

assign en_baud_rx=(RX_curr_state!=RX_IDLE_ST);
assign bit_acc=(sample_count==0);
// main block

    always@(posedge clk)

        begin
                if(MASTER_RST_BAR==1'b0)

                        begin
                           
                            

                            RX_curr_state<=RX_IDLE_ST;

                            RX_data_rdy<=1'b0;              // data ready flag auto cleared

                            RX_Bit_index_count<=3'd0;       // Bit index count cleared

                            sample_count<=0;             // Sampling count reset
                            
                            data_out<=8'd0;              // clear the data output

                        end


                    else
                            begin


                                case(RX_curr_state)
                                    

                                        RX_IDLE_ST:
                                            begin   
                                                    
                                                    
                                                    data_frm<=8'h00;  // clear the data frame temporary shift register;
                                                    
                                                //    data_out<=8'h00;  // data out register is cleared 

                                                    RX_Bit_index_count<=0;       // Bit index count cleared
                                                    
                                                    sample_count<=0;             // Sampling count reset

                                                  //  data_rdy<=1'b0;             // auto cleared

                                                    stop_bit_detc<=1'b0;        // auto cleared
                                                    
                                                    if(Rx_serial==1'b0)
                                                        begin
                                                            
                                                            RX_curr_state<=RX_START_BIT_ST; // not using next_st var, need to check event scheduling in verilog
                                                            sample_count<=0;          // reset the sample count
                                                        end

                                                    else 
                                                        begin
                                                            RX_curr_state<=RX_curr_state; // stay in the IDLE state 
                                                        end                                               
                                            end

                                             //   mid(start bit) + 16 ticks = mid(data bit 0) (from AI)

                                        RX_START_BIT_ST:

                                                begin
                                                        if(RX_baud_tick==1'b1)
                                                            begin
                                                                sample_count<=sample_count+1; 
                                                                // when baud tick comes increment the sample_count
//*************************15+7=22*************************************
                                                                if(sample_count==sample_count_start)  // zero to seven --> eight counts
                                                                    begin
                                                                        if(Rx_serial==1'b0)
                                                                            begin
                                                                          //      data_rdy<=1'b0;
                                                                                // start bit detected
                                                                                  sample_count<=0;    // reset the sample count
                                                                                
                                                                                
                                                                                // sampling of the start bit is done                                                                       
                                                                                RX_Bit_index_count<=0; // bit index count reset 
                                                                                // going to start the bit index count for data
                                                                                RX_curr_state<=RX_DATA_BYTE_ST;
                                                                            end
                                                                        else
                                                                            begin
                                                                                    RX_curr_state<=RX_IDLE_ST;
                                                                            end
                                                                            
                                                                    end

                                                                // else condition needed?
                                                            end

                                                end

                                        RX_DATA_BYTE_ST: 
                                                begin
                                                        if(RX_baud_tick==1'b1)
                                                            begin
                                                                sample_count<=sample_count+1; // when baud tick comes increment the sample_count
//****************************************************************
                                                                if(sample_count==sample_count_data)
                                                                
                                                                 //after reseting the sample count the 15 count will sample the 
                                                                // bit at the mid point of the next bit
                                                                // this like-->
                                                                // id(start bit) + 16 ticks = mid(data bit 0

                                                                    begin
                                                                        data_frm<={Rx_serial,data_frm[7:1]}; // sample the data and left shift the reg
                                                                        // {rx bit, seven other bits}
                                                                        RX_Bit_index_count<=RX_Bit_index_count+1;  // increment the bit count
                                                                        sample_count<=0; // reset the sample count
                                                                        if(RX_Bit_index_count==3'd7)
                                                                            begin
                                                                                RX_curr_state<=RX_STOP_BIT_ST;
                                                                            end
                                                                        else
                                                                            begin
                                                                                RX_curr_state<=RX_DATA_BYTE_ST;
                                                                            end
                                                                    end
                                                                // else condition needed ?

                                                            end
                                                end
                                        RX_STOP_BIT_ST:
                                            begin
                                                    if(RX_baud_tick==1'b1)
                                                        begin
                                                            sample_count<=sample_count+1; // when baud tick comes increment the sample_count
 //**************************************************************                                                        
                                                            if(sample_count==sample_count_stop)
                                                                begin
                                                                    if(Rx_serial==1'b1)
                                                                            begin

                                                                                sample_count<=0; // reset the sample count

                                                                                RX_curr_state<=RX_IDLE_ST; // end of operation

                                                                                data_out<=data_frm;   // data out 

                                                                                RX_data_rdy<=1'b1;  // indication for data availability

                                                                                stop_bit_detc<=1'b1; // indication for simulation

                                                                            end
                                                                    else
                                                                        begin
                                                                                RX_curr_state<=RX_STOP_BIT_ST; // wait till the stop bit is sampled
                                                                        end

                                                                end
                                                        end
                                                        // else statement needed  ?

                                            end
                                        default: 
                                            begin
                                                    RX_curr_state<=RX_IDLE_ST; // stay in the IDLE state by default
                                            end

                                    endcase
                            end

                                            
            end            

endmodule
