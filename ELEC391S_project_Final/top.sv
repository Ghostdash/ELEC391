module top(CLOCK_50, CLOCK2_50, KEY, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT);
    input  wire CLOCK_50, CLOCK2_50;
	input  [3:0] KEY;
	// I2C Audio/Video config interface
	output  wire FPGA_I2C_SCLK;
	inout  wire FPGA_I2C_SDAT;
	// Audio CODEC
	output  wire AUD_XCK;
	input  wire AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	input  wire AUD_ADCDAT;
	output  wire AUD_DACDAT;
    
    wire read_ready, write_ready, read, write;
	wire [23:0] readdata_left, readdata_right;
	reg [23:0] writedata_left, writedata_right;
	wire reset = ~KEY[0];
    
    system left (.clk(CLOCK_50), .read(read), .write(write), .readdata(readdata_left), .writedata(writedata_left));
    system right (.clk(CLOCK_50), .read(read), .write(write), .readdata(readdata_right), .writedata(writedata_right));
    //Audio codec instantiation
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