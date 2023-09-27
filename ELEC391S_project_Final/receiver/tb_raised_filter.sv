module tb_raised_filter();
    logic clk = 1'b1;
    logic reset;
    logic [15:0] indata;

    logic mod_readready, mod_writeready, demod_writeready, en_readready,de_writeready;
    logic complete;
    logic read;  //waitread & waitwrite combined

    logic [15:0] mod_outdata;
    logic [20:0] encoded_data;
    logic [15:0] outdata;
    logic [20:0] receiver_out;
    logic waitwrite;

    //clk,reset,data,outdata,waitwrite,readready,writeready,complete
    //clk,reset,datain,dataout,readready,writeready,waitread

    Hamming_encoder encoder(indata,encoded_data,en_readready,en_writeready);
    raised_transmitter transmitter(clk,reset,encoded_data,mod_outdata, waitwrite,en_writeready,mod_writeready,complete);
    raised_receiver receiver(clk,reset,mod_outdata,receiver_out,mod_writeready,demod_writeready,waitwrite);
    Hamming_decoder decoder(receiver_out,outdata,demod_writeready, de_writeready);

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