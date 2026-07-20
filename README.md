# UART
UART implementation using Verilog HDL
--------------------------------------------------------------------------------------------------------------

Version 3 of the UART module 
Separate control and data paths for both Receiver module and the Transmitter module

This version features a UART Transmitter and Receiver module which consists of RX, TX and Baud Rate Generator for each rx and tx module 
This is the newest version of the UART i made my self.

-------------------------------------------------------------------------------------------------------------
In this Project I Simulated the UART communication protocol in xilinx vivado 2024.2 using a task based testbench testing multiple cases



Verification of the Top module was done using a testbench written in verilog HDL.


Test bench instantiates two UART top module and established a communication between them.

Test case 1 -> Single byte transmission of the data from each module to the other one.
  data bytes were 0x55 and 0xAA.

  
Test case 2 -> 128 bytes are transmitted one after the other from each top module to the other one.
    One module starts sending from 0x00 to 0xFF and other module starts transmitting from 0xFF to 0x00.




