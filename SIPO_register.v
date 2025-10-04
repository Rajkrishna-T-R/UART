
module SIPO_register(Ser_data_in, clk,load,clr_bar,Parallel_data_out,en_data_out);

    parameter N = 8;
    
    input Ser_data_in;
    input en_data_out;
    input clk;
    input clr_bar;
    input load;
    
    output [7:0]Parallel_data_out;
    
     reg [N-1:0]Par_data_out;
     
     assign Parallel_data_out=en_data_out?Par_data_out:{N{1'b0}};
    
    always@(posedge clk or negedge clr_bar)
        
        begin
            
            if(clr_bar==1'b0)
                
                begin
                    
                    Par_data_out<={N{1'b0}};
                    
                end
                
             
             else if(load==1'b1)
                 
                 
                 begin  
                  
                            Par_data_out<={Ser_data_in,Par_data_out[N-1:1]};
                        
                 end
                 
             else
              
                begin
                    
                    Par_data_out<=Par_data_out;
                    
                end    
       end
       
       
       
    
    
    
    
endmodule
