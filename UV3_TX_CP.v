
module UV3_TX_CP(
        input wire clk, // Clock
        input wire RST, // reset
        input wire baud_tick_Tx, // baud tick signal from baud rate generator
        input wire[2:0]data_bit_count, // data bit counting purposes 
        input wire Tx_serial, // The Tx_serial line from Data path 
        input wire Start,     // Start signal from the driver
        output reg load_data, // Load data signal to the data path
        output reg shift_data,// shift data signal to the data path
        output reg TX,         // Tx line for sending
        output reg rst_bit_count    
    );



// state definitions
parameter IDLE_ST  = 2'b00;
parameter START_ST = 2'b01;
parameter DATA_ST  = 2'b10;
parameter STOP_ST  = 2'b11;


reg [1:0]Curr_state;
reg [1:0]Next_state;


// State assignment
always@(posedge clk or posedge RST)
    begin
        if(RST==1)
            begin
                Curr_state<=IDLE_ST;
            end
        else 
            begin
                Curr_state<=Next_state;
            end
    end


// Next state and output 
always@(*)

        begin   // initializations

        rst_bit_count=1'b0;
        load_data=1'b0;
        TX=1'b1; // By default the line is kept at high 
        shift_data=1'b0;

        case(Curr_state)
            IDLE_ST:
                begin
                        if(Start==1) // start transmission
                            begin
                                load_data=1; // load the data 
                                Next_state=START_ST;
                                // go to the start state
                            end
                        else 
                            begin
                                Next_state=IDLE_ST;
                                // go back to idle state
                            end
                 end
            START_ST:
                    begin
                        if(baud_tick_Tx==1)
                            begin
                                TX=1'b0;
                                Next_state=DATA_ST;
                            end
                        else 
                            begin
                                TX=1'b1;
                                Next_state=START_ST;
                            end
                    end
            DATA_ST:
                    begin   
                        if(baud_tick_Tx==1'b1)
                            begin
                                shift_data=1;
                                TX=Tx_serial;
                                if(data_bit_count==7) 
                                    begin
                                        Next_state=STOP_ST;
                                        
                                    end
                                else
                                    begin
                                        Next_state=DATA_ST;
                                    end
                                

                            end
                        else 
                            begin
                                Next_state=DATA_ST;
                            end                        
                    end
            STOP_ST:
                    begin
                        rst_bit_count=1'b1;
                        if(baud_tick_Tx==1'b1)
                            begin
                                TX=1'b1;
                                Next_state=IDLE_ST;
                                
                                
                            end
                        else
                             begin
                                    Next_state=STOP_ST;
                             end
                    end

            default:
                    begin
                        Next_state=IDLE_ST;
                    end


        endcase

        end
endmodule