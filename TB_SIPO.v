`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04.10.2025 16:07:27
// Design Name: 
// Module Name: Tb_SIPO
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


module Tb_SIPO;

wire [7:0]Parallel_data_out;
reg clk,clr_bar,Ser_data_in,load,en_data_out;


SIPO_register uut(.clr_bar(clr_bar),.en_data_out(en_data_out),.clk(clk),.Ser_data_in(Ser_data_in),.load(load),.Parallel_data_out(Parallel_data_out));

initial     

        begin
            
            en_data_out=1'b0;
            
            clk=1'b0;
            
            clr_bar=1'b1;
            
            Ser_data_in=1'b0;
            
            load=1'b0;
            
            forever #5 clk=~clk;
            
            
         end
         
         
initial
    
    begin
        
        #10;
        clr_bar=1'b0;
        
        #10;
        
        clr_bar=1'b1;
        
        #10;
        
        Ser_data_in=1'b1;
        #10;
        
        load=1'b1;
        #5;
        
        // 1 // 1101 1101
        
        Ser_data_in=1'b1;
        #10;
        
        Ser_data_in=1'b0;
        #10;
        
        Ser_data_in=1'b1;
        #10;
        
        Ser_data_in=1'b1;
        #10;
        
        Ser_data_in=1'b1;
        #10;
        
        Ser_data_in=1'b0;
        #10;
        
        Ser_data_in=1'b1;
        #10;
        
        Ser_data_in=1'b1;
        #10;
        
        en_data_out=1'b1;
        #5;
        
        load=0;
        #5;
        
        Ser_data_in=1'b0;
        #10;
        
        Ser_data_in=1'b1;
        #10;
        
        clr_bar=1'b0;
        
        #5;
        
       
        $finish;
        
        
    end
         


endmodule
