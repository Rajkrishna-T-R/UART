`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.01.2026 07:21:27
// Design Name: 
// Module Name: tb_top_test_mod
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


module tb_top_test_mod;

integer success=0;
integer failed=0;
reg rst_bar;
reg [7:0]data_in;
reg tx_wr_en;
reg clk=0;

wire [7:0]data_out;
wire RX_data_rdy;
wire tx_busy;
wire stop_bit_detc;


// parameters


// 25MHz clock and 115200 baud rate 
// Time period for 1 bit is 25M/115200*16
parameter clock_period = 40; // ns
parameter clk_per_bit  = 217; // 217.0138889
parameter bit_time   =   8680; // 8680.5555 ns
parameter bit_16_delay = 8680/16;

integer i=0;

wire bit_acc;



top_test_mod uut( 
                  // input 
                .rst_bar(rst_bar),
                .data_in(data_in),
                .tx_wr_en(tx_wr_en),
                .clk(clk),
                  // output
                .data_out(data_out),
                .RX_data_rdy(RX_data_rdy),
                .tx_busy(tx_busy),
                .stop_bit_detc(stop_bit_detc),
                .bit_acc(bit_acc)
    );














always //clock
    begin
         
         #(clock_period/2)clk=~clk;
     end


task run;
    input [7:0]data;
    
    
   
    begin
        
        
        // Send start bit
        data_in<=data; // load data
        if(tx_busy==0)
        
            begin
                
                tx_wr_en=1'b1;
                
            end
            
        else 
        
            begin
                
                tx_wr_en=1'b0;
                
            end
            
        #(clock_period);
        
        tx_wr_en<=1'b0;
        
        #(10*218*clock_period);
        
        check_data(data);
        
        $display("The number of successfull transmissions %d",success);
        $display("The number of failed transmissions are %d",failed);
        
        

        
    end
endtask





task check_data;
    input [7:0]data;
           
    
            if(RX_data_rdy==1'b1)
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
          
      endtask
                        
          

    
  
/*

Tx module tranmission of start bit and the reciever sampling and reseting the sample count at count 7 
This might be the issue which is causing the misallignment

*/






initial
    begin
        
        rst_bar=1;
        clk=0;
        #(clock_period);
        
        rst_bar=0;
        #(clock_period);
        
        rst_bar=1;
        
        #(2*clock_period);
        
      for(i=0;i<256;i=i+1)
       
        begin
            
            run(i[7:0]);
            check_data(i[7:0]);
            
        end
       
        #(bit_time);
        
        $finish;
        
        
    
    end









endmodule
