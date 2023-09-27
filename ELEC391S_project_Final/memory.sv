module memory(CLOCK_50, reset, datain, dataout, readready, read);
input logic CLOCK_50,reset;
input logic [15:0] datain;
output logic [15:0] dataout;
input logic read;
input logic readready;

int write_index;
int read_index;

logic [15:0] mem [0:109];
enum {RESET, STORE} state;

always @(posedge CLOCK_50) begin
    if (reset) state <= RESET;
    else case(state)
        RESET: begin
            state <= STORE;
            write_index <= 0;
            read_index <= 0;
        end
        STORE: begin
            if (readready) begin
                mem[write_index] <= datain;
                write_index <= write_index + 1;
            end
            if (read) dataout <= mem[read_index];
            else read_index <= read_index + 1;

            if (write_index == 109) write_index <= 0;
            if (read_index == 109) read_index <= 0;
        end
    endcase
end

endmodule