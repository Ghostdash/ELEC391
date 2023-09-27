module tb_Hamming_encoder();
    logic [15:0] indata;
    logic [20:0] outdata;
    logic readready;
    logic writeready;

    Hamming_encoder dut (.*);

    initial begin
        indata = 16'b1010101010101010;
        readready = 1;
        #20;
        $display("The answer is %b", 21'b1010101101010110101011010101,outdata);
        $stop;
    end

endmodule