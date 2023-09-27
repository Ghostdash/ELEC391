module part2 (CLOCK_50, CLOCK2_50, KEY, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, 
		        AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT);

	input CLOCK_50, CLOCK2_50;
	input [1:0] KEY;
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

	//(~KEY[1])? noise : 

	wire [23:0] plusnoise1;
	wire [23:0] plusnoise2;
	wire [23:0] noise;

	noise_generator gen(CLOCK_50,1'b1,reset,noise);
	assign plusnoise1 = (noise[23])? readdata_left - (~(noise)+ 1) : readdata_left + noise;  
	assign plusnoise2 = (noise[23])? readdata_right - (~(noise)+ 1) : readdata_right + noise;  

	filter dataleft(CLOCK_50,reset,read_ready,readdata_left,writedata_left);
	filter dataright(CLOCK_50,reset,read_ready,readdata_right,writedata_right);
	assign read = read_ready;
	assign write = write_ready;


 	
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

module noise_generator (clk, enable, reset,  Q);
	input clk, enable, reset;
	output [23:0] Q;
	reg [2:0] counter;
	always @(posedge clk) begin
		if (reset) 
			counter = 0;
		if (enable)
			counter = counter + 1'b1;
	end
	assign Q = {{18{counter[2]}},counter,3'd0};

endmodule

module filter(CLOCK_50, reset, read_ready, in_data, out_data);
	input CLOCK_50, reset,read_ready;
	input [23:0] in_data;
	output [23:0] out_data;

    wire [23:0] data1,data2,data3,data4,data5,data6,data7;
	reg en;
	reg [23:0] in;

	reg state;
	reg enable;
	wire [47:0] buffer;
	reg [3:0] counter;

    vDFFE #24 Load1(CLOCK_50,en,in,data1);
	vDFFE #24 Load2(CLOCK_50,en,data1,data2);
	vDFFE #24 Load3(CLOCK_50,en,data2,data3);
	vDFFE #24 Load4(CLOCK_50,en,data3,data4);
	vDFFE #24 Load5(CLOCK_50,en,data4,data5);
	vDFFE #24 Load6(CLOCK_50,en,data5,data6);
	vDFFE #24 Load7(CLOCK_50,en,data6,data7);
	
	always @(posedge CLOCK_50) begin
		if (reset) begin
			state <= 0;
			counter <= 0;
		end
		else case (state)
			1'b0:begin                             //initialize the flip flops to 0
				en <= 1'b1;
			    in <= 24'd0;
				enable <= 0;
				if (counter == 4'd8) begin
					counter <= counter;
					if (read_ready) begin
						state <= 3'd1;
						enable <= 1'b1;
					end
					en <= 1'b0;
				end
				else 
					counter <= counter + 1'b1;					
			end
			1'b1: begin
				en <= 0;
				if (read_ready) begin
					in <= in_data;
					en <= 1'b1;
				end
			end
			default: state <= 0;
		endcase
	end
	assign buffer = (in_data >> 3) + (data1 >> 3) + (data2 >> 3) + (data3 >> 3) + (data4 >> 3) + (data5 >> 3) + (data6 >> 3) + (data7 >> 3); 
	assign out_data = buffer[23:0];
endmodule
