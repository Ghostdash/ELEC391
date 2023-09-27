module Hamming_encoder (indata,outdata,readready,writeready);
    input logic [15:0] indata;
    output logic [20:0] outdata;
    input logic readready;
    output logic writeready;

    logic p1,p2,p3,p4,p5;
    //adding parity bits at position 2^0, 2^1, 2^2 .. Note that when inputing into the output, the index is position-1
    assign p1 = indata[0] + indata[1] + indata[3] + indata[4] + indata[6] + indata[8] + indata[10] + indata[11] + indata[13] + indata[15];
    assign p2 = indata[0] + indata[2] + indata[3] + indata[5] + indata[6] + indata[9] + indata[10] + indata[12] + indata[13];
    assign p3 = indata[1] + indata[2] + indata[3] + indata[7] + indata[8] + indata[9] + indata[10] +indata[14] + indata[15];
    assign p4 = indata[4] + indata[5] + indata[6] + indata[7] + indata[8] + indata[9] + indata[10];
    assign p5 = indata[11] + indata[12] + indata[13] + indata[14] + indata[15]; //adding redundant parity bits for error correction

    assign outdata = readready ? {indata[15:11],p5,indata[10:4],p4,indata[3:1],p3,indata[0],p2,p1} : 21'b0; //output data if data input is valid
    assign writeready = readready; //since the module is combinational, output is ready as soon as a a valid input is presented.
endmodule