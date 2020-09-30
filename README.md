# Asynchronous-FIFO
A simple 16-location 8-bit FIFO with different clock domains for Read and Write. 
Data transfer is kept secure by converting the write pointers and read pointers to gray code before sending the pointer values across the parent domain
Difference between empty and full conditions is established by looking at the MSB of the (n+1)-bit pointers. Since there are 16 locations the width of the pointers used here are 5-bit wide. 
- This repo consists of a design file and a testbench to verify the design. *fifo_tb.v* is the testbench for *fifo.v*. 
