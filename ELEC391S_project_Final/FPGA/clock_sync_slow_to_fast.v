module clock_sync_slow_to_fast #(parameter length = 1) (slowclk, fastclk, data_in, data_out);
//clock synchronizer for two different clock domains 
input wire slowclk, fastclk; //slow clock and fast clock 
input wire [length-1:0] data_in; //incoming data
output wire [length-1:0] data_out; 

//registers required for this clock synchronizer 
reg [length-1:0] r1,r2,r3; 
reg r4,r5; 
wire en; //enable for a register 

assign en = r5;
assign data_out = r3;

always @(posedge slowclk)
begin 
r1 <= data_in;
end 

always @(posedge fastclk)
begin 
if (en) r2 <= r1;
end

always @(posedge fastclk)
begin
r3 <= r2;
end

always @(posedge (~fastclk))
begin
r4 <= slowclk;
r5 <= r4;
end

endmodule

