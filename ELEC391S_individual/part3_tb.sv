`timescale 1ps / 1ps
module part3_tb();
	logic CLOCK_50 = 1, CLOCK2_50;
	logic [3:0] KEY;
	// I2C Audio/Video config interface
	logic FPGA_I2C_SCLK;
	wire FPGA_I2C_SDAT;
	// Audio CODEC
	logic AUD_XCK;
	logic AUD_DACLRCK, AUD_ADCLRCK, AUD_BCLK;
	logic AUD_ADCDAT;
	logic AUD_DACDAT;

    part3 dut(.*);

    logic [7:0] i;
    always #5 CLOCK_50 = ~CLOCK_50;
    initial begin
        KEY[0] = 0;
	KEY[1] = 0 ;
        force dut.codec.readdata_left = 24'd1000000;
        force dut.codec.readdata_right = 24'd1000000;
	#11;
        KEY[0] = 1;
        force dut.codec.read_ready = 1'b1;
        for (i = 0; i < 40; i++) begin
		    force dut.codec.readdata_right = 24'd1000000 + i;
            force dut.codec.readdata_left = 24'd1000000 + i;
            @(posedge CLOCK_50);
        end
	for (i = 40; i>0; i--)begin
		    force dut.codec.readdata_right = 24'd1000000 - i;
            force dut.codec.readdata_left = 24'd1000000 - i;
            @(posedge CLOCK_50);
	end
        #50;
        $stop;
    end

endmodule