module Sine_Plus_Noise (
input logic [1:0] symbol,
input logic clk, 
input logic readready, 
input logic reset,
output logic waitwrite,
output logic finish,
output logic [15:0] data_out
);

int counter = 0;  
int phase_shift = 0;
logic [7:0] lfsr_out;

logic [15:0] memory [0:19];  
  
  
initial begin
memory[0] = 16'h8000;
memory[1] = 16'ha78d;
memory[2] = 16'hcb3c;
memory[3] = 16'he78d;
memory[4] = 16'hf9bb;
memory[5] = 16'hffff;
memory[6] = 16'hf9bb;
memory[7] = 16'he78d;
memory[8] = 16'hcb3c;
memory[9] = 16'ha78d;
memory[10] = 16'h8000;
memory[11] = 16'h5872;
memory[12] = 16'h34c3;
memory[13] = 16'h1872;
memory[14] = 16'h644;
memory[15] = 16'h0;
memory[16] = 16'h644;
memory[17] = 16'h1872;
memory[18] = 16'h34c3;
memory[19] = 16'h5872;
memory[20] = 16'h0000;
end
  
ClockChanger #(1_000_000) fast_change(clk, clk_fast);

always_comb begin
case (symbol) 
2'b00: phase_shift = 5; //90 degrees shift
2'b01: phase_shift = 10; //180 degrees shift
2'b10: phase_shift = 15; //270 degrees shift
2'b11: phase_shift = 0; //360 degrees shift
endcase
end

LFSR8bit LFSR8bit1 (.clk(clk), .lfsr_out(lfsr_out));


always @ (posedge clk_fast) begin 
if (reset == 1) begin
	waitwrite <= 1;
end
if (counter < 20) begin
	finish <= 0;
	waitwrite <= 0;
	if (readready == 1) begin
		data_out <= memory[((counter+phase_shift) % 20)] + {8'b0 , lfsr_out};
		counter <= counter + 1;
	end
end

else begin
	counter <= 0;
	waitwrite <= 1;
end

end   
endmodule

//
//
//module sine_plue_noise_tb ();
//
//logic [1:0] symbol;
//logic clk, writeready, finish;
//logic [15:0] data_out;
//
//Sine_Plus_Noise inst1 (
//.symbol(symbol),
//.clk(clk), 
//.readready(writeready), 
//.finish(finish),
//.data_out(data_out)
//);
//
//always begin
//clk = 0;
//#5;
//clk = 1;
//#5;
//end
//
//initial begin
//symbol = 2'b00;
//writeready = 1;
//
//end
//
//endmodule 