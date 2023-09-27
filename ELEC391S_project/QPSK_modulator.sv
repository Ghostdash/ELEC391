module QPSK_modulator(clk,reset,indata,readready,writeready,waitwrite, complete, outdata);
    input logic clk;
    input logic reset;
    input logic readready;
    input logic waitwrite;
    input logic [20:0] indata;

    output logic writeready;
    output logic complete;
    output logic [1:0] outdata;

    logic [21:0] buffer;
    int counter;

    enum {RESET,WRITE,FINISHED} state;

    always @(posedge clk) begin
        if (reset == 1) state <= RESET; 
        else case(state)
            RESET: begin
                if (readready) begin
                    buffer <= {indata,1'b0}; //append zero
                    state <= WRITE;
                    counter <= 21;
                    complete <= 0;
                end
                writeready <= 0;
            end
            WRITE: begin
                writeready <= 1;
                if (counter >= 1 )begin
                    outdata <= {buffer[counter],buffer[counter-1]};
                    if (waitwrite == 1) begin
                        counter <= counter - 2;
                        writeready <= 1;
                    end
                end
                else state <= FINISHED;
            end
            FINISHED: begin
                writeready <= 0;
                complete <= 1;
                state <= RESET;
            end
        endcase
    end
endmodule