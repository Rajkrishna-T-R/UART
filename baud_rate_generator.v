
module Baud_generator(

            input rst,
            
            input clk,
            
            output  Tx_en,
            
            output  Rx_en

    );
    parameter factor = 16; //usually taken factor
    
    parameter inputclk_freq=10000000; // unit Hz (10MHz clock as input)
    
    parameter Baud_rate=115200;// unit bps
    
    parameter Tx_en_count = inputclk_freq/(Baud_rate);
    
    parameter Rx_en_count = inputclk_freq/(Baud_rate*factor);
   
    
    localparam  num_ff_Tx_en= $clog2(Tx_en_count+1); // number of flip flops needed
    
    localparam  num_ff_Rx_en= $clog2(Rx_en_count+1); // number of flip flops needed
    
    
    
    // 'localparam used -> because it defines internal constants that cannot be overidden'
    
    reg [num_ff_Tx_en-1:0] Tx_count;
    reg [num_ff_Rx_en-1:0] Rx_count; 
  
  assign Tx_en=(Tx_count==Tx_en_count-1) ? 1'b1:1'b0;
  assign Rx_en=(Rx_count==Rx_en_count-1) ? 1'b1:1'b0;
  
  
  
    always@(posedge clk)
        
        begin
        
              if(rst==1'b1)
              
                begin
                
                //  reset the count
                
                     Tx_count<=0;
                    
                
                end
                
              else if(Tx_count==Tx_en_count-1)
              
                    begin  
                    
                   //  reset the count
                
                     Tx_count<=0; 
                     
                       
                    end
                    
                
                    
                    
               else 
               
                    begin
                               
                        Tx_count<=Tx_count+1'b1;
                        
                        
                    
                    end     
            
        end
    
    always@(posedge clk)
            
            begin
            
                if(rst==1)
                
                    begin
                        
                        
                         Rx_count<=0; 
                         
                    end
                    
                    
                
                else if(Rx_count==Rx_en_count-1) // To get a sqaure wave use the half count
              
                    begin  
 
                     Rx_count<=0; 
                    
                    end  
                    
                  else 
                        begin
                        
                            Rx_count<=Rx_count+1'b1;
                           
                            
                        end
                    
             end
    
endmodule
