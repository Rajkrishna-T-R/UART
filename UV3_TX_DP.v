

module UV3_TX_DP( 
                input wire clk, // clock
                input wire RST, //Master RESET
                input wire[7:0]data_in, // data to be transmitted
                input wire load_data,   // load data into the shift register
                input wire shift_data,       // shift_data 
                input wire rst_bit_count, // reset Bit count
                output reg[2:0] data_bit_count, // To controller
                output reg Tx_serial   // Tx serial output
                
    );

reg [7:0] S_data_reg;

//PISO register & counter 
    always @(posedge clk or posedge RST)
        begin
            if(RST==1)
                begin
                    S_data_reg<=8'd0;
                    data_bit_count<=3'd0;
                end
            else if(load_data==1)
                begin
                    S_data_reg<=data_in;
                end
            
            else if(shift_data==1)
                begin
                    Tx_serial<=S_data_reg[0];
                    S_data_reg<={1'b0,S_data_reg[7:1]};
                    
                   
                end 

            if(rst_bit_count==1)
                begin
                    data_bit_count<=0;
                end
            else if(shift_data==1)
                begin
                    data_bit_count<=data_bit_count+1'b1;
                end
                        
            
            
                    
        end
            


                    
        







endmodule
