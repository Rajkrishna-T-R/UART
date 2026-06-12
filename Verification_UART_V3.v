`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03.04.2026 11:01:39
// Design Name: 
// Module Name: Verification_UART_V3
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


module Verification_UART_V3;
parameter clock_period=24;


parameter Transmission_delay=500000;// 50us for this testbench given the time scale is => `timescale 1ns / 1ps


reg clk;
reg RST;

integer success=0;
integer failure=0;

integer i=0;
integer dat1=8'd0;

reg Start1,Start2;

wire [7:0]data_out1,data_out2;
reg [7:0]data_in1,data_in2;

wire TX_serial1,RX_serial1;
wire TX_serial2,RX_serial2;


reg clear_done_Tra1,clear_done_Tra2;
reg clear_done_Rec1,clear_done_Rec2;

wire done_Tra1,done_Tra2;
wire done_Rec1,done_Rec2;



// Cross connection 
assign RX_serial2=TX_serial1;
assign RX_serial1=TX_serial2;

 UV3_TOP_IP UUT1(
            .clk(clk),
            .RST(RST),
            .Start(Start1), // begin transmission
            // Need a signal to clear the data  ???
            .DATA_in(data_in1),
            .RX_serial(RX_serial1),
            .TX_serial(TX_serial1),
            .DATA_out(data_out1),
            .clear_done_Tra(clear_done_Tra1), // clear done transmission signal
            .done_Tra(done_Tra1),
            
            
            .clear_done_Rec(clear_done_Rec1), // clear done receival flag signal
            .done_Rec(done_Rec1)
            
    );
    
  UV3_TOP_IP UUT2(
            .clk(clk),
            .RST(RST),
            .Start(Start2), // begin transmission
            // Need a signal to clear the data  ???
            .DATA_in(data_in2),
            .RX_serial(RX_serial2),
            .TX_serial(TX_serial2),
            .DATA_out(data_out2),
            .clear_done_Tra(clear_done_Tra2), // clear done transmission signal
            .done_Tra(done_Tra2),
            
            
            .clear_done_Rec(clear_done_Rec2), // clear done receival flag signal
            .done_Rec(done_Rec2)
    );
    
   // clock generation 
  always
    begin
      #(clock_period/2) clk<=~clk;
    end
    
   // load data and transmit from module 1
    
    task Trans_1;
        input [7:0]data;
        
        begin
            data_in1<=data;
            #(clock_period);
            Start1=1;
            #(2*clock_period);
            Start1=0;
        end
        
     endtask
     // load and transmit from module 2
     task Trans_2;
        input [7:0]data;
        
        begin
            data_in2<=data;
            #(clock_period);
            Start2=1;
            #(2*clock_period);
            Start2=0;
        end
        
     endtask
   
   
   
   // check data transmitted from module 1 is received at module 2 or not
   
   task Check_data2;
         
         input [7:0]data_expec;
         
         begin
                if(data_expec==data_out2)
                    begin 
                    
                       $display("The correct data recieved");
                       $display("Expected %h \t and received %h \t",data_expec,data_out2);
                       success=success+1;
                   end
                else 
                    begin
                    
                        $display("The data is not received correctly");
                        failure=failure+1;
                   end
             
        end
            
        endtask
        
        
      task reset_all;
        begin
            RST=1;
            Start1=0;
            Start2=0;
            data_in1=0;
            data_in2=0;
            clear_done_Tra1=0;
            clear_done_Tra2=0;
            clear_done_Rec1=0;
            clear_done_Rec2=0;
            #(3*clock_period);
            RST=0;
        end
      endtask 
        
   // check data transmitted from module 2 is received at module 1 or not
   
      
      
    task Check_data1;
         
         input [7:0]data_expec;
         
         begin
                if(data_expec==data_out1)
                    begin 
                    
                       $display("The correct data recieved");
                       $display("Expected %h \t and received %h \t",data_expec,data_out1);
                       success=success+1;
                   end
                else 
                    begin
                       $display("The data is not received correctly");
                       failure=failure+1;
                    end
           end 
      
            
        endtask
        
        
        
      
        initial
            begin
               clk=0;
                reset_all;
                
                
                #(clock_period);
                
          
            
     //-------------------------------------------------------------------------      
             // ----- TEST 1 ----- //
     //-------------------------------------------------------------------------
     
             // Simultaneous sending   
       /*     
               Trans_1(8'hAA); // Module 1 to Module 2
                
               Trans_2(8'h55); // Module 2 to Module 1
                
       */
       
    //--------------------------------------------------------------------------   
            // ----- TEST 2 ----- //
    //--------------------------------------------------------------------------        
             // Continious transmission and receival both modules
       /*
             for(i=0;i<=127;i=i+1)
                begin
                    Trans_1(127-dat1);
                    Trans_2(dat1);
                    #(Transmission_delay);
                    
                    Check_data1(dat1);   // One get data from Two
                    Check_data2(127-dat1); // Two get data from One
                    
                    dat1=dat1+1;
                    
                end
        */
        
        
        
    
    
        
                $finish;
            end
    
endmodule