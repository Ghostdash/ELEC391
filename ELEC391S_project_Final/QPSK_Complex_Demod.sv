module QPSK_Complex_Demod (
	input logic clk, 
	input logic reset,
	input logic real_comp,
	input logic img_comp, 
	input logic real_read_ready,
	input logic imag_read_ready,
	output logic writeready,
	output logic [20:0] outdata
);

enum {RESET, RECEIVE,SHIFT, OUT} state;
logic [21:0] buffer;
int counter;
always @(posedge clk) begin
	if (reset) state <= RESET;
	else case (state)
		RESET: begin
			buffer <= 0;
			state <= RECEIVE;
			writeready <= 1;
			counter <= 1;
		end
		RECEIVE: begin
			if (counter < 11) begin
				if (real_read_ready && imag_read_ready) begin
					counter <= counter + 1;
					writeready <= 0;
					if ({real_comp, img_comp} == 2'b00) begin
						buffer <= (buffer + 2'b10) << 2;
					end 
					else if ({real_comp, img_comp} == 2'b01) begin
						buffer <= (buffer + 2'b01) << 2;
					end
					else if ({real_comp, img_comp} == 2'b10) begin
						buffer <= (buffer + 2'b11) << 2;
					end
					else begin
						buffer <= (buffer + 2'b00) << 2;
					end	
				end
			end
			else begin
				state <= OUT;
				if (real_read_ready && imag_read_ready) begin  //if both imaginary and real input are valid
					writeready <= 0;
					if ({real_comp, img_comp} == 2'b00) begin  //3rd quadrant
					end 
					else if ({real_comp, img_comp} == 2'b01) begin //2nd quadrant
						buffer <= (buffer + 2'b01);
					end
					else if ({real_comp, img_comp} == 2'b10) begin //4th quadrant
						buffer <= (buffer + 2'b11);
					end
					else begin                           //1st quadrant
						buffer <= (buffer + 2'b00);
					end	
				end
			end
		end
		OUT: begin
			outdata <= buffer [21:1];   //remove the zero at the LSB
			writeready <= 1;   //write to the decoder
			state <= RESET;
		end
	endcase
end
endmodule 