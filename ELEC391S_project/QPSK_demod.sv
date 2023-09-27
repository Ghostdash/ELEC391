module QPSK_demod(clk,reset,datain,dataout,readready,writeready,waitread);
    input logic clk, reset, readready;
    input logic [15:0] datain;
    output logic [20:0] dataout;
    output logic writeready;
    output logic waitread;

    enum {RESET, RECEIVE1, RECEIVE2, RECEIVE3,RECEIVE4,DEMOD, OUT} state;
    logic [1:0] bit2;
    logic [63:0] buffer1, buffer2,buffer3, buffer4; 
    int counter;
    int numpacked;
    logic shift;
    logic [21:0] temp;
    logic [15:0] point1,point2,point3,point4;
    
    always @(posedge clk) begin
        if (reset == 1) state <= RESET;
        else case (state)
            RESET: begin
                buffer1 <= 64'd0;
                buffer2 <= 64'd0;
                buffer3<= 64'd0;
                buffer4 <= 64'd0;
                counter <= 0;
                numpacked <= 1;
                shift <= 0;
                temp <= 0;
                state <= RECEIVE1;
                writeready <= 0;
            end
            RECEIVE1: begin
                if (shift == 0) begin
                    shift <= 1;
                    temp <= temp << 2;
                end
                if (counter < 15) begin
                    if (readready) begin
                    writeready <= 0;
                        buffer1 <= buffer1 + datain;
                        counter <= counter + 1;
                    end
                end
                else begin
                    point1 <= buffer1/15;
                    buffer1 <= 0;
                    buffer2 <= buffer2 + datain;
                    counter <= 1;
                    state <= RECEIVE2;
                end
            end
            RECEIVE2: begin
                if (counter < 15) begin                 
                    if (readready) begin
                        buffer2 <= buffer2 + datain;
                        counter <= counter + 1;
                    end
                end
                else begin
                    point2 <= buffer2/15;
                    buffer2 <= 0;
                    buffer3 <= buffer3 + datain;
                    counter <= 1;
                    state <= RECEIVE3;
                end
            end
            RECEIVE3: begin
                if (counter < 15) begin                
                    if (readready) begin
                        buffer3 <= buffer3 + datain;
                        counter <= counter + 1;
                    end
                end
                else begin
                    point3 <= buffer3/15;
                    buffer3 <= 0;
                    buffer4 <= buffer4 + datain;
                    counter <= 1;
                    state <= RECEIVE4;
                end
            end
            RECEIVE4: begin
                if (counter < 15) begin                
                    if (readready) begin
                        buffer4 <= buffer4 + datain;
                        counter <= counter + 1;
                    end
                end
                else  begin
                    point4 <= buffer4/15;
                    buffer4 <= 0;
                    counter <= 0;
                    state <= DEMOD;
                end
            end
            DEMOD: begin
                if (numpacked < 11) begin
                    numpacked <= numpacked + 1;
                    state <= RECEIVE1;
                    shift <= 0;
                    if (point1 > 16'd50000) temp <= temp + 2'b00;
                    else if (point1 > 16'd10000 && point1 < 16'd50000) begin
                        if (point2 > 16'd40000) temp <= temp + 2'b11;
                        else temp <= temp + 2'b01;
                    end
                    else temp <= temp + 2'b10;
                end
                else begin
                    state <= OUT; 
                    if (point1 > 16'd50000) temp <= temp + 2'b00;
                    else if (point1 > 16'd10000 && point1 < 16'd50000) begin
                        if (point2 > 16'd40000) temp <= temp + 2'b11;
                        else temp <= temp + 2'b01;
                    end
                    else temp <= temp + 2'b10;
                end
            end
            OUT: begin
                writeready <= 1;
                dataout <= temp [21:1];
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