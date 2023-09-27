module tb_modulator();
    logic clk = 0;
    logic reset, en_writeready, mod_writeready, waitwrite, mod_complete, realdata, imagdata, real_read_ready, imag_read_ready,
    demod_writeready;
    logic [20:0] encoded_data, demod_out;

    QPSK_Complex modululator(.clk(clk), .reset(reset), .indata(encoded_data),.readready(en_writeready),.writeready
    (mod_writeready), .waitwrite(1'b1), .complete (mod_complete), .real_part(realdata), .img_part(imagdata));  //clk,reset,indata,readready,writeready, waitwrite, complete, real_part, img_part

    QPSK_Complex_Demod demodulator(.clk(clk), .reset(reset),.real_comp(realdata),.img_comp(imagdata), .real_read_ready(1'b1),
    .imag_read_ready(1'b1),.writeready(demod_writeready),.outdata(demod_out));

    always #1 clk = ~clk;

    initial begin
        reset = 1;
        #5;
        reset = 0;
        encoded_data = 21'd12345;
        en_writeready = 1;
        #40;
        en_writeready = 0;
        wait(demod_writeready);
        $display("The data input is %d, the transmitted data is %d", 21'd12345, demod_out);
        encoded_data = 21'd10101;
        en_writeready = 1;
        #40;
        en_writeready = 0;
        wait(demod_writeready);
        $display("The data input is %d, the transmitted data is %d", 21'd10101, demod_out);
        $stop;
    end
endmodule