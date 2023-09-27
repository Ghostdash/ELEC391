module raised_transmitter(clk, reset,data,outdata,waitwrite,readready,writeready,complete);
    input logic clk;
    input logic reset;
    input logic [20:0] data;
    output logic [15:0] outdata;
    input logic waitwrite;
    input logic readready;
    output logic writeready;
    output logic complete;
    
    enum {RESET,SELMODE, OUTPUT0, OUTPUTP, OUTPUT, FINISHED} state;
    logic [15:0] lut [0:20];
    logic [15:0] conv [0:9];

    int counter, index, digit;
    logic [20:0] buffer;
    logic [1:0] mode;

    initial begin
        // Initialize the lookup table with the provided data
        lut[0]  = -16'd1665;
        lut[1]  = 16'd1020;
        lut[2]  = 16'd4328;
        lut[3]  = 16'd8096;
        lut[4]  = 16'd12109;
        lut[5]  = 16'd16122;
        lut[6]  = 16'd19872;
        lut[7]  = 16'd23104;
        lut[8]  = 16'd25594;
        lut[9]  = 16'd27163;
        lut[10] = 16'd27699;
        lut[11] = 16'd27163;
        lut[12] = 16'd25594;
        lut[13] = 16'd23104;
        lut[14] = 16'd19872;
        lut[15] = 16'd16122;
        lut[16] = 16'd12109;
        lut[17] = 16'd8096;
        lut[18] = 16'd4328;
        lut[19] = 16'd1020;
        lut[20] = -16'd1665;

        conv[0] = 16'd26032;
        conv[1] = 16'd28184;
        conv[2] = 16'd29920;
        conv[3] = 16'd31200;
        conv[4] = 16'd31984;
        conv[5] = 16'd32248;
        conv[6] = 16'd31984;
        conv[7] = 16'd31200;
        conv[8] = 16'd29920;
        conv[9] = 16'd28184;
    end


    always @(posedge clk) begin
        if (reset) state <= RESET;
        else case (state) 
            RESET: begin
                complete <= 1;
                if (readready) begin
                    state <= SELMODE;
                    counter <= 20;
                    buffer <= data;
                    writeready <= 0;
                end
            end
            SELMODE: begin
                digit <= 0;
                if (counter >= 1) begin
                    mode <= {buffer[counter], buffer[counter-1]}; //for debugging
                    case({buffer[counter], buffer[counter-1]})
                        2'b00: state <= OUTPUT0;
                        2'b01: begin
                            state <= OUTPUT;
                            index <= 0;
                        end
                        2'b10: begin
                            state <= OUTPUT;
                            index <= 11;
                        end
                        2'b11: begin
                            state <= OUTPUTP;
                            index <= 0;
                        end
                    endcase
                end
                else state <= FINISHED;
            end
            OUTPUT: begin
                writeready <= 0;
                if (digit < 10) begin
                    if (waitwrite) begin
                        writeready <= 1;
                        outdata <= lut[index];
                        index <= index + 1;
                        digit <= digit + 1;
                    end
                end
                else begin
                    state <= SELMODE;
                    counter <= counter - 1;
                end
            end
            OUTPUTP: begin
                writeready <= 0;
                if (digit < 10) begin
                    if (waitwrite) begin
                        writeready <= 1;
                        outdata <= conv[index];
                        index <= index + 1;
                        digit <= digit + 1;
                    end
                end
                else begin
                    state <= SELMODE;
                    counter <= counter - 1;
                end

            end
            OUTPUT0: begin
                writeready <= 0;
                if (digit < 10) begin
                    if (waitwrite) begin
                        writeready <= 1;
                        outdata <= 16'd0;
                        digit <= digit + 1;
                    end
                end
                else begin
                    state <= SELMODE;
                    counter <= counter - 1;
                end

            end
            FINISHED: begin
                complete <= 1;
                state <= RESET;
            end
            default: state <= RESET;
        endcase
    end
    

endmodule