module raised_receiver(clk,reset,datain,dataout,readready,writeready,waitread);
    input logic clk, reset, readready;
    input logic [15:0] datain;
    output logic [20:0] dataout;
    output logic writeready;
    output logic waitread;

    enum {RESET, RECEIVE, RECEIVE2, DEMOD, SHIFT, OUT} state;
    int check1, check0;
    int counter;
    int numpacked;
    logic shift;
    logic variation;
    logic [20:0] temp;
    logic [63:0] buffer;
    
    always @(posedge clk) begin
        if (reset == 1) state <= RESET;
        else case (state)
            RESET: begin
                check0 <= 0;
                check1 <= 0;
                counter <= 1;
                numpacked <= 1;
                shift <= 0;
                temp <= 0;
                buffer <= 0;
                state <= RESET;
                state <= RECEIVE;
                writeready <= 0;
                variation <= 0;
            end
            RECEIVE: begin
                if (shift == 0) begin
                    shift <= 1;
                    temp <= temp << 1;
                end
                if (numpacked == 21) state <= OUT;
                if (counter < 10) begin
                    if (readready) begin
                        dataout <= 0;
                        writeready <= 0;
                        if (datain[15] == 1'b1) buffer <= buffer + 0;
                        else buffer <= buffer + datain;
                        if (counter == 6) begin
                            if (buffer/5 < 16'd12109) variation <= 1;    //increasing
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
                end
            end
            DEMOD: begin
                if (numpacked < 20) begin
                    if (check1 > check0) begin
                        if (variation == 1) temp <= temp + 1'b0;
                        else temp <= temp + 1'b1;
                    end
                    else begin
                        if (variation == 1) temp <= temp + 1'b0;
                        else temp <= temp + 1'b1;
                    end
                    state <= RECEIVE;
                    buffer <= 0;
                    numpacked <= numpacked + 1;
                    shift <= 0;
                end
                else begin
                    state <= SHIFT; 
                    if (check1 > check0) temp <= temp + 1'b1;
                    else temp <= temp + 1'b0;
                end
                check0 <= 0;
                check1 <= 0;
            end
            SHIFT: begin
                temp <= temp << 1;
                state <= OUT;
            end
            OUT: begin
                dataout <= temp;
                writeready <= 1;
                state <= RESET;
            end
            default: state <= RESET;
        endcase
    end
    always_comb begin
        case(state)
            RESET: waitread = 0;
            DEMOD: waitread = 0;
            OUT: waitread = 0;
            default: waitread = 1;
        endcase
    end




endmodule