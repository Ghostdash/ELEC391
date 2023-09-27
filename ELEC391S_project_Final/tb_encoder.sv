module tb_encoder();
    logic [15:0] data;      //need 16bit data input
    logic reset;
    logic [30:0] outdata;
    logic clk = 0;
    logic readready;
    logic outready;

    BCH_encoder dut (.*);

    always #5 clk = ~clk;

    initial begin
        reset = 1;  
        #20;
        reset = 0;
        @(negedge clk);
        data = 16'd65;
        readready = 1;
        #20;
        readready = 0;
        #1000;
        $display("%31b",outdata);
        $stop;
    end



endmodule