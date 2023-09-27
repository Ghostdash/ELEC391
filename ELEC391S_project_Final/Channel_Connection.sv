module channel_connect(
input logic [15:0] conv_sum, //data_in should be sync-ed in 50MHz.
input logic CLK_50M,
input logic wr,  
input logic reset,
input logic waitwrite,
output logic [15:0] outdata,
output logic writeready
);
logic rd=0;
logic [15:0] channel_output;
logic clk_slow, full, empty_input, full_input, full_output;
logic [7:0] lfsr;
logic [15:0] slow_conv_sum, intermediate; //initializing the variables

ClockChanger #(1_000_000) slow_change (CLK_50M, clk_slow);  //initializing a clock changer from 1MHz clock
LFSR8bit lfsr_inst1(
  .clk(clk_slow),
  .lfsr_out(lfsr)
);

fifo fifo1    //fifo for storing channel input
(
	.data(conv_sum),
	.rdclk(clk_slow),
	.rdreq(rd),
	.wrclk(CLK_50M),
	.wrreq(wr),
	.q(intermediate),
	.rdempty(empty_input),
	.wrfull(full_input)
);
assign channel_output = intermediate + {8'b0, lfsr}; //add the noise to the input data

fifo fifo2   //fifo for storing channel output
(
	.data(channel_output),
	.rdclk(CLK_50M),
	.rdreq(waitwrite),
	.wrclk(clk_slow),
	.wrreq(rd),
	.q(outdata),
	.rdempty(empty),
	.wrfull(full_output)
);

assign writeready = ~empty;  //ready to output if not empty

always_ff @ (posedge clk_slow) begin
if (~wr) begin     //assert read
rd <= 1;
end
else begin 
rd <= 0;
end
end


endmodule 



module channel_connect_tb(); //channel test bench


logic [15:0] conv_sum;
logic clk, wr, reset, full, rd;
logic [15:0] channel_output;

channel_connect tb1(
conv_sum, //data_in should be sync-ed in 50MHz.
clk,
wr,  
reset,
channel_output,
full
);

always begin 
clk = 0;
#5;
clk = 1;
#5;
end

initial begin
reset = 1;
wr = 1;
#10;
reset = 0;
#10;
conv_sum = 16'd14232;
#10
conv_sum = 16'd120;
#10;
conv_sum = 16'd240;
#10;
conv_sum = 16'd14232;
#10
conv_sum = 16'd120;
#10;
conv_sum = 16'd240;
#10;
conv_sum = 16'd14232;
#10
conv_sum = 16'd120;
#10;
conv_sum = 16'd240;
#100;
wr = 0;
end

endmodule 