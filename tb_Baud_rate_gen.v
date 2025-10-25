`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.10.2025 16:36:37
// Design Name: 
// Module Name: tb_baud_generator
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


module tb_baud_generator;


 reg clk,rst;
 wire Rx_en,Tx_en;
 
 integer tx_count=0;
 integer rx_count=0;
 Baud_generator uut(.clk(clk),.rst(rst),.Tx_en(Tx_en),.Rx_en(Rx_en));
 
 
 
 initial   
        begin
            
            clk=0;rst=0;
            forever #5 clk=~clk;
            
        end
        
        initial 
           begin
                #15;
                rst=1;
                #15;
                rst=0;
            end
  initial 
  
        begin
            $monitor("Rx_Enable=%b,Tx_Enable=%b",Rx_en,Tx_en);
            #875; $finish;
            
            
        end
    always@(posedge Rx_en)
        begin
            
           
            rx_count<=rx_count+1;
            
           
            $display("Rx count=%d, Time=%t",rx_count,$time);
            
            
            
        end
     always@(posedge Tx_en)
     
     begin
     
           $display("TX Count=%d,Time=%t",tx_count,$time);
           tx_count<=tx_count+1;
          
     end
endmodule
