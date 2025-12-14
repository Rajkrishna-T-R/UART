`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 14.12.2025 15:05:21
// Design Name: 
// Module Name: tb_Rx_module
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


module tb_Rx_module;

reg clk=0;
reg Rx_serial=1'b1;
reg MASTER_RST_BAR;
reg rdy_clr;
wire [7:0]data_out;
wire stop_bit_detc;


// 25MHz clock and 115200 baud rate 
// Time period for 1 bit is 25M/115200

parameter clock_period = 40; // ns
parameter clk_per_bit  = 217; // 217.0138889
parameter bit_time   =   8680; // 8680.5555 ns

Rx_module uut(.clk(clk),.Rx_serial(Rx_serial),.MASTER_RST_BAR(MASTER_RST_BAR),.rdy_clr(rdy_clr)
,.data_out(data_out),.stop_bit_detc(stop_bit_detc));


task UART_rx_tsk;
    input [7:0]data;
    integer  i;

    begin
 
        // Send start bit
        rdy_clr<=1'b1;
        #(clock_period);
        rdy_clr<=1'b0;
        #(clock_period);
        
        Rx_serial<=1'b0; 
        #(bit_time); // One bit needs to be sampled 
        #400;        // wait a small interval
        

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


 //  Generate the 25MHz clock
always #(clock_period)clk=~clk;


// Initial block which control the trasfer of data


initial 
        begin
                    #100;
                    
                    MASTER_RST_BAR=1'b0;
                    
                    #100;
                    MASTER_RST_BAR=1'b1;
                    
                    #100;
               
                    UART_rx_tsk(8'h37);
            
                
                    if(data_out==8'h37)
                        begin
                            $display("The correct data recieved");
                        end
                    else
                        begin
                            $display("The incorrect data recieved");
                        end
                    $finish;
                


        end









endmodule
