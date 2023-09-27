module QPSK_Complex(clk,reset,indata,readready,writeready,
waitwrite, complete, real_part, img_part);
    input logic clk;
    input logic reset;
    input logic readready;
    input logic waitwrite;
    input logic [20:0] indata;
	 
    output logic writeready;
    output logic complete;
    output logic real_part;
    output logic img_part;
	 	 
    logic [21:0] buffer;
	logic [1:0] outdata;
    int counter;
	 
    enum {RESET,WRITE,FINISHED} state;

    always @(posedge clk) begin
        if (reset == 1) state <= RESET; 
        else case(state)
            RESET: begin
                if (readready) begin
                    buffer <= {indata,1'b0}; //zero pad the input to make even number of bits for QPSK modulation
                    state <= WRITE;
                    counter <= 21;
                    complete <= 0;
                end
                writeready <= 0;
            end
            WRITE: begin 
                writeready <= 1;
                if (counter >= 1 )begin
                    outdata <= {buffer[counter],buffer[counter-1]}; //selecting 2 bits at a time in the input signal
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
	 
	 
	 always_comb begin
	 case (outdata)
	 2'b00: begin   //symbolize first quadrant; both real and imaginary are positive; 1 = positive, 0 = negative
			  real_part = 1;
			  img_part = 1;
			  end
	 
	 2'b01: begin  //2nd quadrant
			  real_part = 0;
			  img_part = 1;	 
			  end
	 2'b10: begin  //3rd quadrant
	 		  real_part = 0;
			  img_part = 0;
			  end
	 2'b11: begin  //4th quadrant
	        real_part = 1;
			  img_part = 0;
	        end
	 endcase	 
	 end
	 
endmodule 