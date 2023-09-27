module tb_encodingmodule();
    logic [15:0] datain;
    logic [20:0] encode_out;
    logic [20:0] decode_in;
    logic [15:0] dataout;
    logic [20:0] buffer;

    logic en_readready;
    logic en_writeready;
    logic de_readready;
    logic de_writeready;

    Hamming_encoder encode (datain,encode_out,en_readready,en_writeready);
    Hamming_decoder decode (decode_in,dataout,de_readready,de_writeready);

    initial begin
        en_readready = 1;
        datain = 16'b0010010010010001;
        #5;
        buffer = encode_out;
        #5;
        buffer[4] = ~buffer[4];
        decode_in = buffer;
        #5
        de_readready = 1;
        #5;
        $display("input is %b, output is %b\n", datain, dataout);
        #5;
        en_readready = 0;
        de_readready = 0;
        #5;
        en_readready = 1;
        datain = 16'b1101101101101101;
        #5;
        buffer = encode_out;
        #5;
        buffer[6] = ~buffer[6];
        decode_in = buffer;
        #5;
        de_readready = 1;
        #5;
        $display("input is %b, output is %b\n", datain, dataout);       
        en_readready = 0; 


    end
endmodule