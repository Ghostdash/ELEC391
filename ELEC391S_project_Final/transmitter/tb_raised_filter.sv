module  tb_raised_filter();
    logic clk = 0;
    logic data;
    logic [15:0] transmitted_out;

    logic readreaby, complete, full, writeready;

    raised_transmitter transmitted(.clk(clk),.reset(reset),.data(data),.outdata(transmitted_out),.waitwrite(1'b1),.readready(readready),
    .writeready(),complete,full);
    raised_receiver receiver();

    always #1 clk = ~clk;

    initial begin
        reset = 1;
        #11;
        reset = 0;
        indata = 16'd12345;
        en_readready = 1;
        #5;
        en_readready = 0;
        wait (demod_writeready==1);
        #50;
        $display("The transmitted data is %d, the input data is %d", outdata,16'd12345);
        indata = 21'd10101;
        en_readready = 1;
        #5;
        en_readready = 0;
        wait (demod_writeready==1);
        $display("The transmitted data is %d, the input data is %d", outdata,16'd10101);
        #50;
        $stop;
    end
endmodule