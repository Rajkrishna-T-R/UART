`timescale 1ns / 1ps

module tb_tx_module;



 
reg baud_tick_Tx;

integer j=0;
//integer success,failed;
reg clk=0;
wire Tx_serial;
reg [7:0]data_in;
reg MASTER_RST_BAR;
reg wrt_en;
wire Tx_busy;

integer baud_counter=0;





// 25MHz clock and 115200 baud rate 
// Time period for 1 bit is 25M/115200
parameter clock_period = 40; // ns
parameter clk_per_bit  = 217; // 217.0138889
parameter bit_time   =   8680; // 8680.5555 ns
 

parameter in_delay=100;
tx_module uut
        (
           .clk(clk),                 // Input clk
           .wrt_en(wrt_en),              // Writing data into write data_in_reg
           .data_in(data_in),        // Parallel data in
           .baud_tick_Tx(baud_tick_Tx),        // Clk_en which starts transmission from baud rate generator
           .MASTER_RST_BAR(MASTER_RST_BAR),      // RESET 
           .Tx_serial(Tx_serial),           // Serial Data out
           .Tx_busy(Tx_busy)              // Busy line indication
         
          );

task UART_tx_tsk;
    input [7:0]data;
    integer  i;
    begin
        
        
        // Send start bit
        data_in<=data; // load data
        wrt_en<=1'b1;
        
        #(clock_period);
        wrt_en<=1'b0;
        #(clock_period);

        
    end
endtask

 //  Generate the 25MHz clock
always  #(clock_period/2)clk=~clk;
// Initial block which control the trasfer of data


always @(posedge clk)
    begin
            
            baud_counter<=baud_counter+1;
            if(baud_counter>=217)
                begin
                    baud_tick_Tx<=1'b1;
                    baud_counter<=0;
                end
            else
                begin
                    
                    baud_tick_Tx<=1'b0;
                end        
    end

initial 
        begin        
                   
                    #(in_delay);

                    MASTER_RST_BAR=1'b0;

                    #(clock_period);
                    MASTER_RST_BAR=1'b1;

                    #(clock_period);

               
               
             /*    
                    UART_tx_tsk(8'hAA);
                    #(in_delay);
             
             */ 
                
            
               for(j=0;j<256;j=j+1)
                begin
                    
                  
                    UART_tx_tsk(j);
                    #(10*218*clock_period);
                end
              
               
                
                $finish;
                    
                    
                              
        end
endmodule
