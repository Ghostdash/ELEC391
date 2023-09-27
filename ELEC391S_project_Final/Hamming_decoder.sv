module Hamming_decoder (indata,outdata,readready,writeready);
    input logic [20:0] indata;
    output logic [15:0] outdata;
    input logic readready;
    output logic writeready;

    logic p1,p2,p3,p4,p5;
    logic [4:0] index;
    logic [20:0] buffer;
    assign index = {p5,p4,p3,p2,p1}; //the index of the error
    assign p5 = indata[20]+indata[19]+indata[18]+indata[17]+indata[16]+indata[15]; //assign the bits according to even parity : even number
                                                                                    //of ones become 0
    assign p4 = indata[14]+indata[13]+indata[12]+indata[11]+indata[10]+indata[9]+indata[8]+indata[7]; 
    assign p3 = indata[20]+indata[19]+indata[14]+indata[13]+indata[12]+indata[11]+indata[6]+indata[5]+indata[4]+indata[3];
    assign p2 = indata[18]+indata[17]+indata[14]+indata[13]+indata[10]+indata[9]+indata[6]+indata[5]+indata[2]+indata[1];
    assign p1 = indata[20]+indata[18]+indata[16]+indata[14]+indata[12]+indata[10]+indata[8]+indata[6]+indata[4]+indata[2]+indata[0];
    assign writeready = readready;

    always_comb begin
        buffer = indata;
        if (readready == 1 && index != 5'b0) begin
            buffer[index-1] = ~buffer[index-1];   //reverse the bit position at the index
            outdata = {buffer[20:16],buffer[14:8],buffer[6:4],buffer[2]};
        end
        else if (readready == 1) outdata = {buffer[20:16],buffer[14:8],buffer[6:4],buffer[2]}; //otherwise extract the information bits
                                                                                                //and output normally
        else outdata = 16'b0;
    end
endmodule