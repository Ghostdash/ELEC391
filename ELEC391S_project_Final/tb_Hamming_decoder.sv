module tb_Hamming_decoder();
    logic [20:0] indata;
    logic [15:0] outdata;
    logic readready;
    logic writeready;

    Hamming_decoder dut (.*);

    initial begin
        indata = 21'b101011010101011011001;
        readready = 1;
        #20;
        $display("Correct answer is %b, the real answer is %b\n", 16'b1010101010101010, outdata);
        readready = 0;
        #20;
        indata = 21'b101011010101011011101;
        readready = 1;
        #20;
        $display("Correct answer is %b, the real answer is %b", 16'b1010101010101010, outdata);
        readready = 0;
        #20;
        indata = 21'b001011010101011011001;
        readready = 1;
        #20;
        $display("Correct answer is %b, the real answer is %b\n", 16'b1010101010101010, outdata);
        readready = 0;
        $stop;
    end

endmodule