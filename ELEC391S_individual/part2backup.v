module part2 (CLOCK_50, CLOCK2_50, KEY, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, 
		        AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT);

	input CLOCK_50, CLOCK2_50;
	input [0:0] KEY;
	// I2C Audio/Video config interface
	output FPGA_I2C_SCLK;
	inout FPGA_I2C_SDAT;
	// Audio CODEC
	output AUD_XCK;
	input AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input AUD_ADCDAT;
	output AUD_DACDAT;
	
	// Local wires.
	wire read_ready, write_ready, read, write;
	wire [23:0] readdata_left, readdata_right;
	wire [23:0] writedata_left, writedata_right;
	wire reset = ~KEY[0];

	/////////////////////////////////
	// Your code goes here 
	/////////////////////////////////
    wire [23:0] data1,data2,data3,data4,data5,data6,data7,data8,outdata;
	reg [23:0] in1,in2,in3,in4,in5,in6,in7,in8;
	reg en1,en2,en3,en4,en5,en6,en7,en8;
	reg [3:0] state;


    vDFFE #24 Load1(CLOCK_50,en1,in1,data1);
	vDFFE #24 Load2(CLOCK_50,en2,in2,data2);
	vDFFE #24 Load3(CLOCK_50,en3,in3,data3);
	vDFFE #24 Load4(CLOCK_50,en4,in4,data4);
	vDFFE #24 Load5(CLOCK_50,en5,in5,data5);
	vDFFE #24 Load6(CLOCK_50,en6,in6,data6);
	vDFFE #24 Load7(CLOCK_50,en7,in7,data7);
	vDFFE #24 Load8(CLOCK_50,en8,in8,data8);

	always @(posedge CLOCK_50) begin
		if (reset) state <= 0;
		else case(state)
			4'd0: begin
				if (read_ready)begin
					{en1,en2,en3,en4,en5,en6,en7,en8} <= 8'b00000000; //set enables to 0 to avoid loading the wrong data
					state <= 4'd1;									  //begin playback
				end	
				else begin
					{en1,en2,en3,en4,en5,en6,en7,en8} <= 8'b11111111; //load 0 into every flip flop for the calculation of outdata
					in1 <= 24'b0;
					in2 <= 24'b0;
					in3 <= 24'b0;
					in4 <= 24'b0;
					in5 <= 24'b0;
					in6 <= 24'b0;
					in7 <= 24'b0;
					in8 <= 24'b0;
				end
			end
			4'd1: begin
				en8 <= 0;
				en1 <= 1;
				if (read_ready) begin						//if theaudio module is ready
					in1 <= readdata_right;                  //load the current readdata_right value to the flip flop
					state <= 4'd2;
				end
			end
			4'd2: begin
				en1 <= 0;
				en2 <= 1;
				if (read_ready) begin
					in2 <= readdata_right;
					state <= 4'd3;
				end
			end
			4'd3: begin
				en2 <= 0;
				en3 <= 1;
				if (read_ready) begin
					in3 <= readdata_right;
					state <= 4'd4;
				end
			end
			4'd4: begin
				en3 <= 0;
				en4 <= 1;
				if (read_ready) begin
					in4 <= readdata_right;
					state <= 4'd5;
				end
			end
			4'd5: begin
				en4 <= 0;
				en5 <= 1;
				if (read_ready) begin
					in5 <= readdata_right;
					state <= 4'd6;
				end
			end
			4'd6: begin
				en5 <= 0;
				en6 <= 1;
				if (read_ready) begin
					in6 <= readdata_right;
					state <= 4'd7;
				end
			end
			4'd7: begin
				en6 <= 0;
				en7 <= 1;
				if (read_ready) begin
					in7 <= readdata_right;
					state <= 4'd8;
				end
			end
			4'd8: begin
				en7 <= 0;
				en8 <= 1;
				if (read_ready) begin
					in8 <= readdata_right;
					state <= 4'd6;
				end
			end
			default: state <= 4'd0;
		endcase
	end

	assign writedata_left = readdata_left;        
	assign writedata_right = outdata;
	assign read = read_ready;
	assign write = write_ready;
	assign outdata = data1 >> 3 + data2 >> 3 + data3 >> 3 + data4 >> 3 + data5 >> 3 + data6 >> 3 + data7 >> 3 + data8 >> 3; //averages 8 values then output the result

	
/////////////////////////////////////////////////////////////////////////////////
// Audio CODEC interface. 
//
// The interface consists of the following wires:
// read_ready, write_ready - CODEC ready for read/write operation 
// readdata_left, readdata_right - left and right channel data from the CODEC
// read - send data from the CODEC (both channels)
// writedata_left, writedata_right - left and right channel data to the CODEC
// write - send data to the CODEC (both channels)
// AUD_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio CODEC
// I2C_* - should connect to top-level entity I/O of the same name.
//         These signals go directly to the Audio/Video Config module
/////////////////////////////////////////////////////////////////////////////////
	clock_generator my_clock_gen(
		// inputs
		CLOCK2_50,
		reset,

		// outputs
		AUD_XCK
	);

	audio_and_video_config cfg(
		// Inputs
		CLOCK_50,
		reset,

		// Bidirectionals
		FPGA_I2C_SDAT,
		FPGA_I2C_SCLK
	);

	audio_codec codec(
		// Inputs
		CLOCK_50,
		reset,

		read,	write,
		writedata_left, writedata_right,

		AUD_ADCDAT,

		// Bidirectionals
		AUD_BCLK,
		AUD_ADCLRCK,
		AUD_DACLRCK,

		// Outputs
		read_ready, write_ready,
		readdata_left, readdata_right,
		AUD_DACDAT
	);

endmodule

/*
module vDFFE(clk,en,in,out);
    parameter n = 24;
    input clk,en;
    input [n-1:0] in;
    output [n-1:0] out;
    reg [n-1:0] out;
    wire [n-1:0] next_out;

    assign next_out = in;
    always @(posedge clk) begin
        out = next_out;
    end

endmodule
*/

module vDFFE(clk, en, in, out) ;
  parameter n = 1;  // width
  input clk, en ;
  input  [n-1:0] in ;
  output [n-1:0] out ;
  reg    [n-1:0] out ;
  wire   [n-1:0] next_out ;

  assign next_out = en ? in : out;

  always @(posedge clk)
    out = next_out;  
endmodule

module noise_generator (clk, enable, Q);
	input clk, enable;
	output [23:0] Q;
	reg [2:0] counter;
	always @(posedge clk)
		if (enable)
			counter = counter + 1'b1;
	assign Q = {{10{counter[2]}},counter,11'd0};

endmodule
