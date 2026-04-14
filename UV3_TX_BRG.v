
module UV3_TX_BRG(
                input wire clk,
                input wire RST,
                output reg baud_tick_Tx
                
    );

    parameter factor=5'd16; // not used in Tx baud rate generator
    parameter clk_in_frq=25000000; // Unit Hz 
    parameter Baud_rate=115200;    // FIxed baud rate for now
    localparam Tx_en_count=(clk_in_frq)/(Baud_rate); // Count for Tick of Tx 
    localparam num_ff_tx=$clog2(Tx_en_count+1);


    reg [num_ff_tx-1:0]Tx_count;
    

    always @(posedge clk or posedge RST)
        begin
            if(RST==1'b1)
                begin
                      // Reset
                    Tx_count<=0;
                    baud_tick_Tx<=0;
                end
            else if (Tx_count==(Tx_en_count-1)) 
                begin
                    // Overflow of counter and producing the baud tick
                    Tx_count<=0;
                    baud_tick_Tx<=1;
                end
            else 
                begin
                    // normal counting
                    Tx_count<=Tx_count+1;
                    baud_tick_Tx<=0;
                end 
        end

endmodule
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
                
      
