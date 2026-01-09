`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: RAJ
// 
// Create Date: 02.01.2026 13:45:17
// Design Name: 
// Module Name: tb_rx_module
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module tb_rx_module;

reg rx_baud_tick;
integer j=0;
integer success=0;
integer failed=0;
reg clk=0;
reg Rx_serial=1'b1;
reg MASTER_RST_BAR;

wire [7:0]data_out;
wire stop_bit_detc;
reg rx_baud_tick;
wire data_rdy;
integer baud_counter=0;
// 25MHz clock and 115200 baud rate 
// Time period for 1 bit is 25M/115200*16
parameter clock_period = 40; // ns
parameter clk_per_bit  = 217; // 217.0138889
parameter bit_time   =   8680; // 8680.5555 ns
parameter bit_16_delay = 8680/16;

rx_module uut(.clk(clk),.Rx_serial(Rx_serial),.MASTER_RST_BAR(MASTER_RST_BAR)
,.data_out(data_out),.stop_bit_detc(stop_bit_detc),.baud_tick(rx_baud_tick),.data_rdy(data_rdy));



parameter in_delay=500;

task Run_rx;
    input [7:0]data;
    integer  i;
    begin

        // Send start bit
        

        Rx_serial<=1'b0; 
        
        #(bit_time); // One bit needs to be sampled 
        // #(bit_16_delay); 
        // #500;        // wait a small interval

        // send the data byte
        for(i=0;i<8;i=i+1)
            begin
                Rx_serial<=data[i];
                #(bit_time); // Time for sampling one bit
            end
        // Stop bit sending time
        Rx_serial<=1'b1;
        #(bit_time);
        
        
        
    end
endtask

task result;
    input [7:0]data_in;
    

    begin
    
            if(data_rdy==1'b1)
                begin
                
                    if(data_out==data_in)
                        begin
                            $display("The correct data recieved");
                            $display("Expected %h \t and received %h \t",data_in,data_out);
                            success=success+1;
                        end
                    else
                        begin
                            $display("The incorrect data recieved");
                            $display("Expected %h \t and received %h \t",data_in,data_out);
                            failed=failed+1;
                        end
                end
            end
      endtask
      
 //  Generate the 25MHz clock
always
    begin
         
         #(clock_period/2)clk=~clk;
     end


always @(posedge clk)
    begin
            baud_counter<=baud_counter+1;
            if(baud_counter>=13)
                begin
                    rx_baud_tick<=1'b1;
                    baud_counter<=0;
                end
            else
                begin
                    
                    rx_baud_tick<=1'b0;
                end        
    end
    // Initial block which control the trasfer of data
initial 
        begin        
               
                    
         
                    MASTER_RST_BAR=1'b0;

                    #(in_delay);
                    MASTER_RST_BAR=1'b1;

                    #(in_delay);

                //    UART_rx_tsk(8'h37);

              /*      Run_rx(8'h37);
                    #100;
                    Run_rx(8'h45);
                    #100;
                    Run_rx(8'h67);
                    #100;
                    Run_rx(8'h00);
                    #100;
                    Run_rx(8'h64);
                    #100
                    $finish;
               */
              
               
               
              /*     Run_rx(8'hAA);
                    
                    result(8'hAA);
                    #(in_delay);
                */
             
            
              for(j=0;j<256;j=j+1)
                begin
                    Run_rx(j);
                    result(j);
                    #(15*clock_period);
                end
             
                $display("The number of successfull transmissions %d",success);
                $display("The number of failed transmissions are %d",failed);
                
                $finish;
                    
                    
                              
        end
endmodule
