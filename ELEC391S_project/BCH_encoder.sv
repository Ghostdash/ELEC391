module BCH_encoder (clk,reset,data,readready,outready,outdata);
    input logic [15:0] data;      //need 16bit data input
    input logic reset;
    input logic clk;
    input logic readready;
    output logic outready;
    output logic [30:0] outdata;
    
    logic [15:0] codeword;
    logic [14:0] checkbits;
    logic [30:0] message;
    logic [15:0] buffer;
    int index = 15;
    int digit = 0;
    int shift = 0;
    
    assign codeword = 16'b1000111110101111; //generated using x^5 + x^2 + 1
    assign message = {data, 15'b0};

    enum {RESET,shift0,XOR1,addzero,out} states;
    always @(posedge clk) begin
        if (RESET == 1) states <= RESET;
        else case (states)
            RESET: if(readready) begin
                states <= shift0;
                buffer <= data;
                digit <= 16;
                index <= 15;
                outready <= 0;
            end
            shift0: begin
                if (buffer[15]==1 || index == 0) begin
                    if (digit != 0) states <= XOR1;
                    else states <= addzero;
                end
                else begin
                    digit <= digit - 1;
                    index <= index - 1;
                    buffer <= buffer << 1;   //shift bits to left
                end
            end
            XOR1: begin
                buffer <= buffer ^ codeword;
                states <= shift0;
                index <= 15;
            end
            addzero:begin                                                 
                if (buffer[15]==0)
                    buffer <= buffer << 1;
                else begin
                    states <= out;
                    checkbits <= buffer[15:1];
                end
            end
            out: begin
                outready <= 1;
                outdata <= {data,checkbits};
                states <= RESET;
            end
            default: states <= RESET;
        endcase
    end
endmodule
