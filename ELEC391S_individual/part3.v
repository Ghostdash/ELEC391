module part3 (CLOCK_50, CLOCK2_50, KEY, FPGA_I2C_SCLK, FPGA_I2C_SDAT, AUD_XCK, 
		        AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK, AUD_ADCDAT, AUD_DACDAT);

	input CLOCK_50, CLOCK2_50;
	input [3:0] KEY;
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
	reg [23:0] writedata_left, writedata_right;
	wire reset = ~KEY[0];

	/////////////////////////////////
	// Your code goes here 
	/////////////////////////////////

	wire [23:0] out2_left, out4_left,out6_left;        //shifted 2, shifted 4, shifted 6
	wire [23:0] out2_right, out4_right,out6_right;     //shifted 2, shifted 4, shifted 6

	fifo_filter_2 filt2 (CLOCK_50, reset, readdata_left,readdata_right,out2_left,out2_right);
	fifo_filter_4 filt4 (CLOCK_50, reset, readdata_left,readdata_right,out4_left,out4_right);
	fifo_filter_6 filt6 (CLOCK_50, reset, readdata_left,readdata_right,out6_left,out6_right);

	wire [23:0] plusnoise1;
	wire [23:0] plusnoise2;
	wire [23:0] noise;

	assign plusnoise1 = (noise[23])? readdata_left - (~(noise)+ 1) : readdata_left + noise;  
	assign plusnoise2 = (noise[23])? readdata_right - (~(noise)+ 1) : readdata_right + noise; 

	noise_generator gen(CLOCK_50,1'b1,reset,noise);

	always @(*) begin
		if (~KEY[1]) begin
			writedata_left = out2_left;
			writedata_right = out2_right;
		end
		else if (~KEY[2]) begin
			writedata_left = out4_left;
			writedata_right = out4_right;
		end
		else if (~KEY[3]) begin
			writedata_left = out6_left;
			writedata_right = out6_right;
		end
		else begin
			writedata_left = plusnoise1;
			writedata_right = plusnoise2;
		end
	end

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

module noise_generator (clk, enable, reset, Q);
	input clk, enable,reset;
	output [23:0] Q;
	reg [2:0] counter;
	always @(posedge clk) begin
		if (reset) 
			counter = 0;
		if (enable)
			counter = counter + 1'b1;
	end
	assign Q = {{10{counter[2]}},counter,11'd0};
endmodule

module accum (clk, reset, in_data, out_data); 
	input clk, reset; 
	input  [23:0] in_data; 
	output [23:0] out_data; 
	reg    [23:0] temp;  
 
    always @(posedge clk) begin 
      if (reset) 
        temp <= 24'd0; 
      else 
        temp <= temp + in_data; 
    end 
  assign Q = temp; 
endmodule 

module fifo_filter_2 (CLOCK_50, reset, readdata_left, readdata_right, writedata_left, writedata_right);
	input [23:0] readdata_left, readdata_right;
	output [23:0] writedata_left, writedata_right;
	input CLOCK_50, reset;

	wire empty1, empty2;
	wire read1,read2;
	reg write1,write2;
	wire full1, full2;
	wire almost1,almost2;
	wire [3:0] usedw1;
	wire [3:0] usedw2;

	wire [23:0] noise;
	wire [23:0] plusnoise1;
	wire [23:0] plusnoise2;
	wire [23:0] outdata1;
	wire [23:0] outdata2;
	reg [23:0] leftout, rightout;
	wire [23:0] lefttemp, righttemp;
	wire [23:0] temp1, temp2;
	wire [23:0] noisetemp1, noisetemp2;
 
    FIFO2 dataleft(CLOCK_50,plusnoise1,read1,write1,almost1,empty1,full1,outdata1,usedw1);
	FIFO2 dataright(CLOCK_50,plusnoise2,read2,write2,almost2,empty2,full2,outdata2,usedw2);

	noise_generator gen(CLOCK_50,1'b1,reset,noise);

	assign plusnoise1 = (noise[23])? readdata_left - (~(noise)+ 1) : readdata_left + noise;  
	assign plusnoise2 = (noise[23])? readdata_right - (~(noise)+ 1) : readdata_right + noise; 

	assign writedata_left = temp1;
	assign writedata_right = temp2;

	assign temp1 = (reset)? 24'd0: leftout + noisetemp1 - lefttemp ;
	assign temp2 = (reset)? 24'd0: rightout +noisetemp2 - righttemp;

	assign noisetemp1 = plusnoise1 >> 2;
	assign noisetemp2 = plusnoise2 >> 2;

	assign 	read1 = almost1;
	assign	read2 = almost2;

	assign lefttemp = (almost1)? (outdata1 >> 2): 0;
	assign righttemp = (almost2)? (outdata2 >> 2): 0;

	always @(posedge CLOCK_50) begin 
    	if (reset) begin
			leftout <= temp1;
			rightout <= temp2;
			write1 <= 0;
			write2 <= 0;
		end
    	else begin
			write1 <= 1;
			write2 <= 1;
			leftout <= temp1;
			rightout <= temp2;
		end 
    end 
endmodule

module fifo_filter_4 (CLOCK_50, reset, readdata_left, readdata_right, writedata_left, writedata_right);
	input [23:0] readdata_left, readdata_right;
	output [23:0] writedata_left, writedata_right;
	input CLOCK_50, reset;

	wire empty1, empty2;
	wire read1,read2;
	reg write1,write2;
	wire full1, full2;
	wire almost1,almost2;
	wire [3:0] usedw1;
	wire [3:0] usedw2;

	wire [23:0] noise;
	wire [23:0] plusnoise1;
	wire [23:0] plusnoise2;
	wire [23:0] outdata1;
	wire [23:0] outdata2;
	reg [23:0] leftout, rightout;
	wire [23:0] lefttemp, righttemp;
	wire [23:0] temp1, temp2;
	wire [23:0] noisetemp1, noisetemp2;
 
    FIFO4 dataleft(CLOCK_50,plusnoise1,read1,write1,almost1,empty1,full1,outdata1,usedw1);
	FIFO4 dataright(CLOCK_50,plusnoise2,read2,write2,almost2,empty2,full2,outdata2,usedw2);

	noise_generator gen(CLOCK_50,1'b1,reset,noise);

	assign plusnoise1 = (noise[23])? readdata_left - (~(noise)+ 1) : readdata_left + noise;  
	assign plusnoise2 = (noise[23])? readdata_right - (~(noise)+ 1) : readdata_right + noise; 

	assign writedata_left = temp1;
	assign writedata_right = temp2;

	assign temp1 = (reset)? 24'd0: leftout + noisetemp1 - lefttemp ;
	assign temp2 = (reset)? 24'd0: rightout +noisetemp2 - righttemp;

	assign noisetemp1 = plusnoise1 >> 4;
	assign noisetemp2 = plusnoise2 >> 4;

	assign 	read1 = almost1;
	assign	read2 = almost2;

	assign lefttemp = (almost1)? (outdata1 >> 4): 0;
	assign righttemp = (almost2)? (outdata2 >> 4): 0;

	always @(posedge CLOCK_50) begin 
    	if (reset) begin
			leftout <= temp1;
			rightout <= temp2;
			write1 <= 0;
			write2 <= 0;
		end
    	else begin
			write1 <= 1;
			write2 <= 1;
			leftout <= temp1;
			rightout <= temp2;
		end 
    end 
endmodule

module fifo_filter_6 (CLOCK_50, reset, readdata_left, readdata_right, writedata_left, writedata_right);
	input [23:0] readdata_left, readdata_right;
	output [23:0] writedata_left, writedata_right;
	input CLOCK_50, reset;

	wire empty1, empty2;
	wire read1,read2;
	reg write1,write2;
	wire full1, full2;
	wire almost1,almost2;
	wire [3:0] usedw1;
	wire [3:0] usedw2;

	wire [23:0] noise;
	wire [23:0] plusnoise1;
	wire [23:0] plusnoise2;
	wire [23:0] outdata1;
	wire [23:0] outdata2;
	reg [23:0] leftout, rightout;
	wire [23:0] lefttemp, righttemp;
	wire [23:0] temp1, temp2;
	wire [23:0] noisetemp1, noisetemp2;
 
    FIFO6 dataleft(CLOCK_50,plusnoise1,read1,write1,almost1,empty1,full1,outdata1,usedw1);
	FIFO6 dataright(CLOCK_50,plusnoise2,read2,write2,almost2,empty2,full2,outdata2,usedw2);

	noise_generator gen(CLOCK_50,1'b1,reset,noise);

	assign plusnoise1 = (noise[23])? readdata_left - (~(noise)+ 1) : readdata_left + noise;  
	assign plusnoise2 = (noise[23])? readdata_right - (~(noise)+ 1) : readdata_right + noise; 

	assign writedata_left = temp1;
	assign writedata_right = temp2;

	assign temp1 = (reset)? 24'd0: leftout + noisetemp1 - lefttemp ;
	assign temp2 = (reset)? 24'd0: rightout +noisetemp2 - righttemp;

	assign noisetemp1 = plusnoise1 >> 6;
	assign noisetemp2 = plusnoise2 >> 6;

	assign 	read1 = almost1;
	assign	read2 = almost2;

	assign lefttemp = (almost1)? (outdata1 >> 6): 0;
	assign righttemp = (almost2)? (outdata2 >> 6): 0;

	always @(posedge CLOCK_50) begin 
    	if (reset) begin
			leftout <= temp1;
			rightout <= temp2;
			write1 <= 0;
			write2 <= 0;
		end
    	else begin
			write1 <= 1;
			write2 <= 1;
			leftout <= temp1;
			rightout <= temp2;
		end 
    end 
endmodule