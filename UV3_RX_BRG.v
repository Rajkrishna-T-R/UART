

module UV3_RX_BRG(            
                input wire clk,
                input wire start_baud,
                input wire RST,
                output reg baud_tick_Rx);
    
    parameter factor=5'd16; // for oversampling
    parameter clk_in_frq=24000000; // Unit Hz 
    parameter Baud_rate=115200;    // FIxed baud rate for now
    localparam Rx_en_count=(clk_in_frq)/(Baud_rate*factor); // Count for Tick of Rx 
    localparam num_ff_rx=$clog2(Rx_en_count+1); // Number of flip flops


    reg [num_ff_rx-1:0]Rx_count; // Counter variable
    

    always @(posedge clk or posedge RST)
        begin
            if(RST==1'b1 || (~start_baud))
                begin
                // Reset
                    Rx_count<=0; 
                    baud_tick_Rx<=0;
                end
            else if (Rx_count==(Rx_en_count-1)) 
                begin
                // Overflow of counter and producing the baud tick
                    Rx_count<=0;
                    baud_tick_Rx<=1;
                end
            else 
            // normal counting
                begin
                    Rx_count<=Rx_count+1;
                    baud_tick_Rx<=0;
                end 
        end
endmodule
