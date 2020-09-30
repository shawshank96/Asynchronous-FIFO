`timescale 1ns/100ps 

module fifo1_tb();
parameter DEPTH = 16, WIDTH = 8; 

reg rclk, wclk, reset, put, get;
reg [WIDTH-1:0] data_in;

wire empty_bar, full_bar;
wire [WIDTH-1:0] data_out;

fifo1 #(DEPTH, WIDTH) DUT(.rclk(rclk), .wclk(wclk), .reset(reset), .put(put), .get(get), .data_in(data_in), .empty_bar(empty_bar), .full_bar(full_bar), .data_out(data_out));

always #17 rclk = ~rclk;
always #8 wclk = ~wclk; 

initial
begin
  rclk = 0; wclk = 0; reset = 1; put = 0; get = 0; data_in = $random; #80; 
  reset = 0; 

  $display("######## WRITE CYCLE ########");
  repeat(16)
  begin
    @(negedge wclk) put = 1; get = 0; data_in = $random;
  end

  $display("######## READ CYCLE ########"); 
  repeat(16)
  begin
    @(negedge rclk) put = 0; get = 1; 
  end   

  $display("######## PUT = 1; GET = 1 ########");
  repeat(16)
  begin
    @(negedge wclk) put = 1; get = 1; data_in = $random; 
  end  

  $display("########");
  @(negedge wclk) put = 1; data_in = $random;
  @(negedge wclk) put = 1; data_in = $random;
  @(negedge wclk) put = 1; data_in = $random;
  put = 0; 
  @(negedge rclk) get = 1;
  @(negedge rclk) get = 1;
  @(negedge rclk) get = 1;  

  #20; 
$finish;
end

initial
begin
  $dumpfile("test.vcd");
  $dumpvars(0, DUT);
  //@(posedge wclk) $monitor("At time %d ns wclk = %b, rclk = %b, reset = %b, put = %b, get = %b, data_in = %b, empty_bar = %b, full_bar = %b, data_out = %b", $time, wclk, rclk, reset, put, get, data_in, empty_bar, full_bar, data_out);
end
endmodule
