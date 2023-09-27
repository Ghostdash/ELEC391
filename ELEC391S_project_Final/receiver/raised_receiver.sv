module raised_receiver(clk,reset,datain,dataout,readready,writeready,waitwrite);
    input logic clk, reset, readready;
    input logic [15:0] datain;
    output logic dataout;
    output logic waitwrite;
    output logic writeready;

    enum {RESET, RECEIVE, DEMOD} state;
    int check1, check0;
    int counter;
    int numpacked;
    logic shift;
    logic variation;
    logic [63:0] buffer;
    logic [15:0] check;
    
    always @(posedge clk) begin
        if (reset == 1) state <= RESET;
        else case (state)
            RESET: begin
                check0 <= 0;
                check1 <= 0;
                counter <= 1;
                buffer <= 0;
                state <= RECEIVE;
                variation <= 0;
                waitwrite <= 1;
                check <= 0;
                writeready <= 0;
            end
            RECEIVE: begin
                if (counter < 10) begin
                    if (readready) begin
                        dataout <= 0;
                        writeready <= 0;
                        if (datain[15] == 1'b1) buffer <= buffer + 0;
                        else buffer <= buffer + datain;
                        if (counter == 6) begin
                            if (buffer/5 < 16'd8096) variation <= 1;    //increasing
                            else variation <= 0; //decreasing
                        end
                        if (datain < 16'd8096 || datain[15] == 1'b1) begin
                            check0 <= check0 + 1;
                        end
                        else check1 <= check1 + 1;
                        counter <= counter + 1;
                    end
                end
                else begin
                    if (datain < 16'd8096 || datain[15] == 1'b1) check0 <= check0 + 1;
                    else check1 <= check1 + 1;
                    counter <= 1;
                    state <= DEMOD;
                    waitwrite <= 0;
                end
            end
            DEMOD: begin
                state <= RESET;
                buffer <= 0;
                writeready <= 1;
                if (check1 > check0) begin
                    if (variation == 1) dataout <= 1'b0;
                    else dataout <= 1'b1;
                end
                else begin
                    if (variation == 1) dataout <= 1'b0;
                    else dataout <= 1'b1;
                end
                check0 <= 0;
                check1 <= 0;
            end
            default: state <= RESET;
        endcase
    end
endmodule