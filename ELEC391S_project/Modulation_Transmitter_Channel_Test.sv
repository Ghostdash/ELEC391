module modulation_test (
input logic clk,
input logic [20:0] sample,
input logic readready,
input logic reset,
output [15:0] transmitted_data
);

logic [15:0] noise_added;
logic [1:0] intermediate2, intermediate1;
logic clk_slow, clk_fast;
logic writeready, complete, writeready_fast;
logic finish, finish_slow;
logic waitwrite;


ClockChanger #(48_000) slow_change(clk, clk_slow);


ClockChanger #(1_000_000) fast_change(clk, clk_fast);


clock_sync_slow_to_fast #(2) sync1(.slowclk(clk_slow), 
.fastclk(clk_fast), .data_in(intermediate1), .data_out(intermediate2));


clock_sync_slow_to_fast #(1) sync2(.slowclk(clk_slow), 
.fastclk(clk_fast), .data_in(writeready), .data_out(writeready_fast));


clock_sync_fast_to_slow #(1) sync3(.slowclk(clk_slow), 
.fastclk(clk_fast), .data_in(finish), .data_out(finish_slow));


Sine_Plus_Noise sine_inst1(
.symbol(intermediate2), .clk(clk_fast), .readready(writeready), .reset(reset), .waitwrite(waitwrite),
.finish(finish), .data_out(noise_added));


QPSK_modulator mod1 (.clk(clk_slow), .reset(reset),
.indata(sample), .readready(readready), .writeready(writeready),
.waitwrite(waitwrite), .complete(complete), 
.outdata(intermediate1));


assign transmitted_data	= (finish)? noise_added : transmitted_data;  

endmodule  

 
module modulation_tb ();
logic clk, readready, reset;
logic [20:0] sample;
logic [15:0] signal_output;

modulation_test dut1(.clk(clk), .sample(sample), .readready(readready),
.transmitted_data(signal_output), .reset(reset));


always begin
#5;
clk = 1;
#5;
clk = 0;
end


initial begin
reset = 1;
sample = 21'b101110011001001100101;				
readready = 1;
#14020;
reset = 0;
#10;
wait (dut1.mod1.complete == 1);
$stop;
end

endmodule 