# UART
UART implementation using Verilog HDL


The files whose names start with the 'UART' are the final module used to test the design and it was successfully transmitting data when connected as 
TX to RX this TOP_TEST module is the interconnection of the TX and RX module including a baud rate generator module.

The design still needs a validation on the variables in UART_RX_MODULE which are,
        1. sample_count_start
        2. sample_count_data
        3. sample_count_stop


Waveform pics branch contains some of the test output waveforms
