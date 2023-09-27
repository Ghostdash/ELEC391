module  tb_raised_filter();
    logic clk = 0;
    logic data;
    logic [15:0] transmitted_out;
    logic reset;

    logic readready, complete, full, writeready, outdata , r_writeready, t_writeready;

    raised_transmitter transmitted(.clk(clk),.reset(reset),.data(data),.outdata(transmitted_out),.waitwrite(1'b1),.readready(readready),
    .writeready(t_writeready), .complete(complete),.full(full));
    raised_receiver receiver(.clk(clk),.reset(reset),.datain(transmitted_out),.dataout(outdata),.readready(t_writeready),.writeready(r_writeready),.waitwrite(1'b1));

    always #1 clk = ~clk;

    initial begin
        reset = 1;
        #11;
        reset = 0;
        data = 1;
        readready = 1;
        #5;
        data = 0;
        readready = 0;
        wait (r_writeready==1);
        $stop;
    end
endmodule