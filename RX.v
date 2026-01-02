

module rx_module
        (           input wire clk,                    // CLOCK
                    input wire Rx_serial,              // RX_serial line 
                    input wire MASTER_RST_BAR,         // reset everything
                    
                    input wire baud_tick,               // from the baud rate generator
                    output reg[7:0] data_out,          // Data output
                    output reg stop_bit_detc,          // Stop bit detected
                    output reg data_rdy                // data ready indication flag
                    
                    
        );

//--------------------------------------------------------------------------------------------------------------------------------------------------


    reg [2:0] curr_state;            // Register to store the current state 
   
    reg [7:0] data_frm;              // Data byte is stored in this temporary shift register
   
   


    parameter BIT_INDEX_SIZE=3;                   // No of bits needed to represet the data byte
    parameter num_ff_sc = 4;                      // oversampling for 16 counts

    reg [num_ff_sc-1:0]sample_count;                // Used to sample the data from at the middle of the bit 
    reg [BIT_INDEX_SIZE-1:0] Bit_index_count;     // To count the index while receiving the data bits

//--------------------------------------------------------------------------------------------------------------------------------------------------

                // STATE definitions //


    parameter IDLE_ST = 3'b000;          // Stay idle until the start bit falling transition received
    parameter START_BIT_ST = 3'b001;     // When start bit detetced sample the start bit
    parameter DATA_BYTE_ST = 3'b010;     // Sample the data bit when rx_en signal is enabled
    parameter STOP_BIT_ST = 3'b011;      // Stop bit is sampled and move to the end state 
    parameter END_ST = 3'b100;           // Move the data from the register to the output register and also enable the ready signal

//--------------------------------------------------------------------------------------------------------------------------------------------------    
    // clock synchronizer from AI suggestion, need to study

    reg buf1_syn;
    reg buf2_syn;

    always@(posedge clk)
        begin
            buf1_syn<=Rx_serial;
            buf2_syn<=buf1_syn;
        end

//--------------------------------------------------------------------------------------------------------------------------------------------------


// main block

    always@(posedge clk)

        begin
                if(MASTER_RST_BAR==1'b0)

                        begin

                            curr_state<=IDLE_ST;

                            data_rdy<=1'b0;              // data ready flag auto cleared

                            Bit_index_count<=3'd0;       // Bit index count cleared

                            sample_count<=0;             // Sampling count reset
                            
                            data_out<=8'd0;              // clear the data output

                        end


                    else
                            begin


                                case(curr_state)
                                    

                                        IDLE_ST:
                                            begin
                                                    data_frm<=8'h00;  // clear the data frame temporary shift register;
                                                    
                                                //    data_out<=8'h00;  // data out register is cleared 

                                                    Bit_index_count<=0;       // Bit index count cleared
                                                    
                                                    sample_count<=0;             // Sampling count reset

                                                  //  data_rdy<=1'b0;             // auto cleared

                                                    stop_bit_detc<=1'b0;        // auto cleared
                                                    
                                                    if(buf2_syn==1'b0)
                                                        begin
                                                            
                                                            curr_state<=START_BIT_ST; // not using next_st var, need to check event scheduling in verilog
                                                            sample_count<=0;          // reset the sample count
                                                        end

                                                    else 
                                                        begin
                                                            curr_state<=curr_state; // stay in the IDLE state 
                                                        end                                               
                                            end

                                             //   mid(start bit) + 16 ticks = mid(data bit 0) (from AI)

                                        START_BIT_ST:

                                                begin
                                                        if(baud_tick==1'b1)
                                                            begin
                                                                sample_count<=sample_count+1; 
                                                                // when baud tick comes increment the sample_count

                                                                if(sample_count==7)  // zero to seven --> eight counts
                                                                    begin
                                                                        if(buf2_syn==1'b0)
                                                                            begin
                                                                          //      data_rdy<=1'b0;
                                                                                // start bit detected
                                                                                sample_count<=0;    // reset the sample count
                                                                                // sampling of the start bit is done                                                                       
                                                                                Bit_index_count<=0; // bit index count reset 
                                                                                // going to start the bit index count for data
                                                                                curr_state<=DATA_BYTE_ST;
                                                                            end
                                                                        else
                                                                            begin
                                                                                    curr_state<=IDLE_ST;
                                                                            end
                                                                            
                                                                    end

                                                                // else condition needed?
                                                            end

                                                end

                                        DATA_BYTE_ST: 
                                                begin
                                                        if(baud_tick==1'b1)
                                                            begin
                                                                sample_count<=sample_count+1; // when baud tick comes increment the sample_count
                                                                if(sample_count==15)
                                                                
                                                                 //after reseting the sample count the 15 count will sample the 
                                                                // bit at the mid point of the next bit
                                                                // this like-->
                                                                // id(start bit) + 16 ticks = mid(data bit 0

                                                                    begin
                                                                        data_frm<={buf2_syn,data_frm[7:1]}; // sample the data and left shift the reg
                                                                        // {rx bit, seven other bits}
                                                                        Bit_index_count<=Bit_index_count+1;  // increment the bit count
                                                                        sample_count<=0; // reset the sample count
                                                                        if(Bit_index_count==3'd7)
                                                                            begin
                                                                                curr_state<=STOP_BIT_ST;
                                                                            end
                                                                        else
                                                                            begin
                                                                                curr_state<=DATA_BYTE_ST;
                                                                            end
                                                                    end
                                                                // else condition needed ?

                                                            end
                                                end
                                        STOP_BIT_ST:
                                            begin
                                                    if(baud_tick==1'b1)
                                                        begin
                                                            sample_count<=sample_count+1; // when baud tick comes increment the sample_count
                                                            if(sample_count==15)
                                                                begin
                                                                    if(buf2_syn==1'b1)
                                                                            begin

                                                                                sample_count<=0; // reset the sample count

                                                                                curr_state<=IDLE_ST; // end of operation

                                                                                data_out<=data_frm;   // data out 

                                                                                data_rdy<=1'b1;  // indication for data availability

                                                                                stop_bit_detc<=1'b1; // indication for simulation

                                                                            end
                                                                    else
                                                                        begin
                                                                                curr_state<=STOP_BIT_ST; // wait till the stop bit is sampled
                                                                        end

                                                                end
                                                        end
                                                        // else statement needed  ?

                                            end
                                        default: 
                                            begin
                                                    curr_state<=IDLE_ST; // stay in the IDLE state by default
                                            end

                                    endcase
                            end

                                            
            end            

endmodule
