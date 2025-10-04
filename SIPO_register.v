

module SIPO_register(Ser_data_in, clk,load,clr_bar,Par_data_out);

    parameter N = 8;
    
    input Ser_data_in;
    input clk;
    input clr_bar;
    input load;
    output reg [N-1:0]Par_data_out;
    
    always@(posedge clk or negedge clr_bar)
        
        begin
            
            if(clr_bar==1'b0)
                
                begin
                    
                    Par_data_out<=8'b0;
                    
                end
                
                
           else if(load==1'b1 && clr_bar==1'b0)
                 
                 begin  
                    
                    Par_data_out<=8'b0;
                    
                  end
            
                
             else if(load==1'b1 && clr_bar==1'b1)
                 
                 begin  
                    
                    Par_data_out<={Ser_data_in,Par_data_out[7:1]};
                    
                  end
              else
              
                begin
                    
                    Par_data_out<=Par_data_out;
                    
                end    
       end
       
       
       
    
    
    
    
endmodule
