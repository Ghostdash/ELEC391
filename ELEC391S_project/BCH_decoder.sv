module BCH_decoder(clk,reset,data,readready,outready,outdata);
    input logic [15:0] data;      //need 16bit data input
    input logic reset;
    input logic clk;
    input logic readready;
    output logic outready;
    output logic [30:0] outdata;


endmodule


module binary_divison(clk,reset,data,codeword,readready,outready,remainder);
    parameter data_width = 31;
    parameter code_width = 5;
    input logic [data_width-1:0] data;      //need 16bit data input
    input logic [code_width-1:0] codeword;
    input logic reset;    
    input logic clk;
    input logic readready;
    output logic outready;
    output logic [code_width-2:0] remainder;
    
    logic [code_width-1:0] buffer;
    int msb = code_width -1;
    int in_left = data_width - 1;
    int in_right = data_width - code_width;
    
    enum {RESET,shift0,XOR1,addzero,out} states;
    always @(posedge clk) begin
        if (RESET == 1) states <= RESET;
        else case (states)
            RESET: if(readready) begin
                states <= shift0;
                buffer <= data[in_left:in_right];
                outready <= 0;
            end
            shift0: begin
                if (buffer[msb]==1) begin
                    if (in_right != 0) states <= XOR1;
                    else states <= addzero;
                end
                else begin
                    digit <= digit - 1;
                    in_left <= in_left - 1;
                    in_right <= in_right - 1;
                    buffer <= data[in_left-1:in_right-1];   //shift bits to left
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