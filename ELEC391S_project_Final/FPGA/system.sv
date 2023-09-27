module system(clk, read,write,readdata,writedata);
	input logic clk;
	input logic read;
	output logic write;
	input logic [15:0] readdata;
	output logic [15:0] writedata;

    logic reset;
    logic [15:0] indata, outdata;
    logic sound_sample_freq;
    logic en_readready;
    logic mod_complete, mod_writeready, realdata, imagdata , real_tran_writeready, imag_tran_writeready, real_rece_writeready, 
    imag_rece_writeready,demod_writeready, real_channel_writeready, imag_channel_writeready;
    logic [15:0] real_tran, imag_tran, real_channel, imag_channel;
    logic [20:0] demod_out,encoded_data;
    logic real_tran_complete, imag_tran_complete;
    logic full, empty, rd;

    logic real_read, imag_read;

    ClockChanger #(48_000) clock48kHz (CLOCK_50, sound_sample_freq);
    
    Hamming_encoder encoder(.indata(readdata), .outdata(encoded_data), .readready(read), .writeready(en_writeready));

    QPSK_Complex modululator(.clk(clk), .reset(reset), .indata(encoded_data),.readready(en_writeready),.writeready
    (mod_writeready), .waitwrite(waitwrite), .complete (mod_complete), .real_part(realdata), .img_part(imagdata));  //clk,reset,indata,readready,writeready, waitwrite, complete, real_part, img_part

   //clk, reset,data,outdata,waitwrite,readready,writeready,complete
    raised_transmitter real_transimtter(.clk(clk),.reset(reset),.data(realdata),.outdata(real_tran), .waitwrite (waitwrite), 
    .readready(mod_writeready),.writeready(real_tran_writeready),.complete(real_tran_complete),.full(full1));
    raised_transmitter imag_transmitter(.clk(clk),.reset(reset),.data(imagdata),.outdata(imag_tran), .waitwrite (waitwrite), 
    .readready(mod_writeready),.writeready(imag_tran_writeready),.complete(imag_tran_complete),.full(full2));

    channel_connect AWGNreal (.conv_sum(real_tran), .CLK_50M(clk), .outdata(real_channel), .wr(real_tran_writeready), 
    .reset(reset), .writeready(real_channel_writeready),.waitwrite(real_read));
    channel_connect AWGNimag (.conv_sum(imag_tran), .CLK_50M(clk), .outdata(imag_channel), .wr(imag_tran_writeready), 
    .reset(reset), .writeready(imag_channel_writeready),.waitwrite(imag_read));

    //clk,reset,datain,dataout,readready,writeready,waitread
    raised_receiver real_receiver(.clk(clk),.reset(reset),.datain(real_channel),.dataout(real_rece),.readready(real_channel_writeready),
    .writeready(real_rece_writeready),.waitwrite(real_read));
    raised_receiver imag_receiver(.clk(clk),.reset(reset),.datain(imag_channel),.dataout(imag_rece),.readready(imag_channel_writeready),
    .writeready(imag_rece_writeready),.waitwrite(imag_read));

    QPSK_Complex_Demod demodulator(.clk(clk), .reset(reset),.real_comp(real_rece),.img_comp(imag_rece), .real_read_ready(real_rece_writeready),
    .imag_read_ready(imag_rece_writeready),.writeready(demod_writeready),.outdata(demod_out));
    
    Hamming_decoder decoder(.indata(demod_out),.outdata(outdata),.readready(demod_writeready), .writeready(de_writeready));
    fifo out (.data(demod_out),.rdclk(sound_sample_freq),.rdreq(rd),.wrclk(clk),.wrreq(de_writeready),.q(writedata),.rdempty(empty),
	.wrfull(full)); 

endmodule