`timescale 1ps / 1ps
module part2_tb();
	logic CLOCK_50 = 1, CLOCK2_50;
	logic [1:0] KEY;
	// I2C Audio/Video config interface
	logic FPGA_I2C_SCLK;
	wire FPGA_I2C_SDAT;
	// Audio CODEC
	logic AUD_XCK;
	logic AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	logic AUD_ADCDAT;
	logic AUD_DACDAT;

    part2 dut(.*);

    always #5 CLOCK_50 = ~CLOCK_50;
    initial begin
        KEY[0] = 0;
		#11;
		KEY[0] = 1;
		KEY[1] = 1;
		force dut.codec.read_ready = 1'b1;
		force dut.codec.readdata_right = 24'd1000000;
		@(posedge CLOCK_50);
		@(negedge CLOCK_50);
		force dut.codec.readdata_right = 24'd1000001;
		@(negedge CLOCK_50);
		force dut.codec.readdata_right = 24'd1000002;
		@(negedge CLOCK_50);
		force dut.codec.readdata_right = 24'd1000003;
		@(negedge CLOCK_50);
		force dut.codec.readdata_right = 24'd1000004;
		@(negedge CLOCK_50);
		force dut.codec.readdata_right = 24'd1000005;
		@(negedge CLOCK_50);
		force dut.codec.readdata_right = 24'd1000006;
		@(negedge CLOCK_50);
		force dut.codec.readdata_right = 24'd1000007;
		@(negedge CLOCK_50);
		force dut.codec.readdata_right = 24'd1000008;
		@(negedge CLOCK_50);
		force dut.codec.readdata_right = 24'd1000005;
		@(negedge CLOCK_50);
		force dut.codec.read_ready = 1'b0;
		#50;
		@(negedge CLOCK_50);
		force dut.codec.read_ready = 1'b1;
		force dut.codec.readdata_right = 24'd1000010;
		@(negedge CLOCK_50);
		force dut.codec.readdata_right = 24'd1000005;
		@(negedge CLOCK_50);
		force dut.codec.readdata_right = 24'd1000005;
		@(negedge CLOCK_50);
		force dut.codec.readdata_right = 24'd1000005;
        $stop;
    end
endmodule