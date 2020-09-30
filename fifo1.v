// Code by Shashank Shviashankar: Asynchronous FIFO using (N+1)-bit pointers and gray code conversions
// Reference [1]:  https://github.com/JonathanJing/Asynchronous-FIFO
// Reference [2]: https://www.verilogpro.com/asynchronous-fifo-design/


`timescale 1ns/100ps

module fifo1 #(parameter DEPTH = 16, parameter DATA_WIDTH = 8) (rclk, wclk, reset, put, get, data_in, empty_bar, full_bar, data_out);

function integer log;
 input integer n;
 begin
   log = 0;
   while(2**log < n)
   begin
     log = log + 1; 
   end
 end
endfunction

integer i; 
parameter ADDR_WIDTH = log(DEPTH);

input rclk, wclk, reset, put, get; 
input [DATA_WIDTH-1:0] data_in;

output empty_bar, full_bar;
output [DATA_WIDTH-1:0] data_out;

reg [ADDR_WIDTH:0] wptr, wptr_s, wptr_ss;
reg [ADDR_WIDTH:0] rptr, rptr_s, rptr_ss;

wire [ADDR_WIDTH:0] wptr_bin, wptr_gray;
wire [ADDR_WIDTH:0] rptr_bin, rptr_gray; 

reg [DATA_WIDTH-1:0] fifomem [DEPTH-1:0]; 

// Read pointer synchronized to the writer's side
always@(posedge wclk)
begin
  rptr_s <= rptr_gray;
  rptr_ss <= rptr_s; 
end

// Write pointer synchronized to the reader's side
always@(posedge rclk)
begin
  wptr_s <= wptr_gray;
  wptr_ss <= wptr_s; 
end

// Writing funtcion of the FIFO
always@(posedge wclk or posedge reset)
begin
  if(reset)
    wptr <= 0;
  else
  begin
    if(put && get)
    begin
      if(~empty_bar)
      begin
        wptr <= wptr + 1;
        fifomem[wptr[ADDR_WIDTH-1:0]] <= data_in; 
      end
    end

    else if(put && ~get)
    begin
      if(full_bar)
      begin
        wptr <= wptr + 1;
        fifomem[wptr[ADDR_WIDTH-1:0]] <= data_in;
      end
    end
  end
  
  $display("At time %d ns wclk = %b, rclk = %b, reset = %b, put = %b, get = %b, data_in = %h, data_out = %h, empty_bar = %b, full_bar = %b, Mem is: %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h", $time, wclk, rclk, reset, put, get, data_in, data_out, empty_bar, full_bar, fifomem[0], fifomem[1], fifomem[2], fifomem[3], fifomem[4], fifomem[5], fifomem[6], fifomem[7], fifomem[8], fifomem[9], fifomem[10], fifomem[11], fifomem[12], fifomem[13], fifomem[14], fifomem[15]);
end

// Reading function of the FIFO
always@(posedge rclk or posedge reset)
begin
  if(reset)
    rptr <= 0;
  else
  begin
    if(get && put)
    begin
      if(empty_bar)
      begin
        rptr <= rptr + 1;
      end
    end

    else if(get && ~put)
    begin
      if(empty_bar)
      begin
        rptr <= rptr + 1;     
      end
    end
  end
  
  $display("At time %d ns wclk = %b, rclk = %b, reset = %b, put = %b, get = %b, data_in = %h, data_out = %h, empty_bar = %b, full_bar = %b, Mem is: %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h %h", $time, wclk, rclk, reset, put, get, data_in, data_out, empty_bar, full_bar, fifomem[0], fifomem[1], fifomem[2], fifomem[3], fifomem[4], fifomem[5], fifomem[6], fifomem[7], fifomem[8], fifomem[9], fifomem[10], fifomem[11], fifomem[12], fifomem[13], fifomem[14], fifomem[15]);
end

// Binary to gray code conversion
assign wptr_gray = wptr ^ (wptr >> 1);
assign rptr_gray = rptr ^ (rptr >> 1); 

// Gray to binary code conversion
assign wptr_bin = wptr_ss ^ (wptr_ss >> 1) ^ (wptr_ss >> 2) ^ (wptr_ss >> 3) ^ (wptr_ss >> 4); 
assign rptr_bin = rptr_ss ^ (rptr_ss >> 1) ^ (rptr_ss >> 2) ^ (rptr_ss >> 3) ^ (rptr_ss >> 4);

// Empty_bar generation 
assign empty_bar = (rptr == wptr_bin) ? 0 : 1; 

// Full_bar generation
assign full_bar = ({~wptr[ADDR_WIDTH], wptr[ADDR_WIDTH-1:0]} == rptr_bin) ? 0 : 1; 

// Data out generation
assign data_out = (get && empty_bar) ? fifomem[rptr[ADDR_WIDTH-1:0]] : 8'bX; 
endmodule
