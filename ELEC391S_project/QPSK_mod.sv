module QPSK_mod(clk,reset,indata,readready,writeready,waitwrite, complete, outdata);
    input logic clk;
    input logic reset;
    input logic readready;
    input logic waitwrite;
    input logic [20:0] indata;

    output logic writeready;
    output logic complete;
    output logic [15:0] outdata;

    logic [21:0] buffer;
    logic [5:0] index;
    logic [1:0] mode;
    logic [15:0] out45, out135, out225, out315;

    int counter;
    enum {RESET,SELMODE,WRITE, FINISHED} state;

    lookup45 looktable45(index,out45);
    lookup135 looktable135(index,out135);
    lookup225 looktable225(index,out225);
    lookup315 looktable315(index,out315);

    always @(posedge clk) begin
        if (reset == 1) state <= RESET;
        else case(state)
            RESET: begin
                if (readready) begin
                    buffer <= {indata,1'b0}; //append zero
                    state <= SELMODE;
                    counter <= 21;
                    complete <= 0;
                end
                writeready <= 0;
            end
            SELMODE: begin
                writeready <= 0;
                if (counter >= 1)begin
                    mode <= {buffer[counter],buffer[counter-1]};
                    counter <= counter - 2;
                    state <= WRITE;
                    index <= 0;
                end
                else state <= FINISHED;
            end
            WRITE: begin
                if (index < 40 && waitwrite == 1) begin //halt output if not ready
                    index <= index + 1;
                    writeready <= 1;
                    case (mode)
                        2'b00: outdata <= out45;
                        2'b01: outdata <= out135;
                        2'b10: outdata <= out225;
                        2'b11: outdata <= out315;
                    endcase 
                end
                else if (index == 40) begin
                    state <= SELMODE;
                    writeready <= 0;
                end
            end
            FINISHED: begin
                complete <= 1;
                state <= RESET;
            end
        endcase
    end
endmodule

module lookup45 (index,dataout);
    input logic [5:0] index;
    output logic [15:0] dataout;

    always_comb begin
        case(index)
            6'd0:dataout= 16'd55938;
            6'd1:dataout = 16'd59277;
            6'd2:dataout = 16'd61964;
            6'd3:dataout = 16'd63931;
            6'd4:dataout = 16'd65132;
            6'd5:dataout = 16'd65535;
            6'd6:dataout = 16'd65132;
            6'd7:dataout = 16'd63931;
            6'd8:dataout = 16'd61964;
            6'd9:dataout = 16'd59277;
            6'd10:dataout = 16'd55938;
            6'd11:dataout = 16'd52028;
            6'd12:dataout = 16'd47644;
            6'd13:dataout = 16'd42893;
            6'd14:dataout = 16'd37893;
            6'd15:dataout = 16'd32768;
            6'd16:dataout = 16'd27642;
            6'd17:dataout = 16'd22642;
            6'd18:dataout = 16'd17891;
            6'd19:dataout = 16'd13507;
            6'd20:dataout = 16'd9597;
            6'd21:dataout = 16'd6258;
            6'd22:dataout = 16'd3571;
            6'd23:dataout = 16'd1604;
            6'd24:dataout = 16'd403;
            6'd25:dataout = 16'd0;
            6'd26:dataout = 16'd403;
            6'd27:dataout = 16'd1604;
            6'd28:dataout = 16'd3571;
            6'd29:dataout = 16'd6258;
            6'd30:dataout = 16'd9597;
            6'd31:dataout = 16'd13507;
            6'd32:dataout = 16'd17891;
            6'd33:dataout = 16'd22642;
            6'd34:dataout = 16'd27642;
            6'd35:dataout = 16'd32768;
            6'd36:dataout = 16'd37893;
            6'd37:dataout = 16'd42893;
            6'd38:dataout = 16'd47644;
            6'd39:dataout = 16'd52028;
            default: dataout = 16'bx;
        endcase
    end
endmodule

module lookup135 (index,dataout);
    input logic [5:0] index;
    output logic [15:0] dataout;

    always_comb begin
        case(index)
            6'd0:dataout= 16'd55938;
            6'd1:dataout = 16'd52028;
            6'd2:dataout = 16'd47644;
            6'd3:dataout = 16'd42893;
            6'd4:dataout = 16'd37893;
            6'd5:dataout = 16'd32768;
            6'd6:dataout = 16'd27642;
            6'd7:dataout = 16'd22642;
            6'd8:dataout = 16'd17891;
            6'd9:dataout = 16'd13507;
            6'd10:dataout = 16'd9597;
            6'd11:dataout = 16'd6258;
            6'd12:dataout = 16'd3571;
            6'd13:dataout = 16'd1604;
            6'd14:dataout = 16'd403;
            6'd15:dataout = 16'd0;
            6'd16:dataout = 16'd403;
            6'd17:dataout = 16'd1604;
            6'd18:dataout = 16'd3571;
            6'd19:dataout = 16'd6258;
            6'd20:dataout = 16'd9597;
            6'd21:dataout = 16'd13507;
            6'd22:dataout = 16'd17891;
            6'd23:dataout = 16'd22642;
            6'd24:dataout = 16'd27642;
            6'd25:dataout = 16'd32768;
            6'd26:dataout = 16'd37893;
            6'd27:dataout = 16'd42893;
            6'd28:dataout = 16'd47644;
            6'd29:dataout = 16'd52028;
            6'd30:dataout = 16'd55938;
            6'd31:dataout = 16'd59277;
            6'd32:dataout = 16'd61964;
            6'd33:dataout = 16'd63931;
            6'd34:dataout = 16'd65132;
            6'd35:dataout = 16'd65535;
            6'd36:dataout = 16'd65132;
            6'd37:dataout = 16'd63931;
            6'd38:dataout = 16'd61964;
            6'd39:dataout = 16'd59277;
            default: dataout = 16'bx;
        endcase
    end
endmodule

module lookup225 (index,dataout);
    input logic [5:0] index;
    output logic [15:0] dataout;

    always_comb begin
        case(index)
            6'd0:dataout= 16'd9597;
            6'd1:dataout = 16'd6258;
            6'd2:dataout = 16'd3571;
            6'd3:dataout = 16'd1604;
            6'd4:dataout = 16'd403;
            6'd5:dataout = 16'd0;
            6'd6:dataout = 16'd403;
            6'd7:dataout = 16'd1604;
            6'd8:dataout = 16'd3571;
            6'd9:dataout = 16'd6258;
            6'd10:dataout = 16'd9597;
            6'd11:dataout = 16'd13507;
            6'd12:dataout = 16'd17891;
            6'd13:dataout = 16'd22642;
            6'd14:dataout = 16'd27642;
            6'd15:dataout = 16'd32768;
            6'd16:dataout = 16'd37893;
            6'd17:dataout = 16'd42893;
            6'd18:dataout = 16'd47644;
            6'd19:dataout = 16'd52028;
            6'd20:dataout = 16'd55938;
            6'd21:dataout = 16'd59277;
            6'd22:dataout = 16'd61964;
            6'd23:dataout = 16'd63931;
            6'd24:dataout = 16'd65132;
            6'd25:dataout = 16'd65535;
            6'd26:dataout = 16'd65132;
            6'd27:dataout = 16'd63931;
            6'd28:dataout = 16'd61964;
            6'd29:dataout = 16'd59277;
            6'd30:dataout = 16'd55938;
            6'd31:dataout = 16'd52028;
            6'd32:dataout = 16'd47644;
            6'd33:dataout = 16'd42893;
            6'd34:dataout = 16'd37893;
            6'd35:dataout = 16'd32768;
            6'd36:dataout = 16'd27642;
            6'd37:dataout = 16'd22642;
            6'd38:dataout = 16'd17891;
            6'd39:dataout = 16'd13507;            
            default: dataout = 16'bx;
        endcase
    end
endmodule

module lookup315 (index,dataout);
    input logic [5:0] index;
    output logic [15:0] dataout;
    always_comb begin
        case(index)
            6'd0: dataout = 16'd9597;
            6'd1: dataout = 16'd13507;
            6'd2: dataout = 16'd17891;
            6'd3: dataout = 16'd22642;
            6'd4: dataout = 16'd27642;
            6'd5: dataout = 16'd32768;
            6'd6: dataout = 16'd37893;
            6'd7: dataout = 16'd42893;
            6'd8: dataout = 16'd47644;
            6'd9: dataout = 16'd52028;
            6'd10: dataout = 16'd55938;
            6'd11: dataout = 16'd59277;
            6'd12: dataout = 16'd61964;
            6'd13: dataout = 16'd63931;
            6'd14: dataout = 16'd65132;
            6'd15: dataout = 16'd65535;
            6'd16: dataout = 16'd65132;
            6'd17: dataout = 16'd63931;
            6'd18: dataout = 16'd61964;
            6'd19: dataout = 16'd59277;
            6'd20: dataout = 16'd55938;
            6'd21: dataout = 16'd52028;
            6'd22: dataout = 16'd47644;
            6'd23: dataout = 16'd42893;
            6'd24: dataout = 16'd37893;
            6'd25: dataout = 16'd32768;
            6'd26: dataout = 16'd27642;
            6'd27: dataout = 16'd22642;
            6'd28: dataout = 16'd17891;
            6'd29: dataout = 16'd13507;
            6'd30: dataout = 16'd9597;
            6'd31: dataout = 16'd6258;
            6'd32: dataout = 16'd3571;
            6'd33: dataout = 16'd1604;
            6'd34: dataout = 16'd403;
            6'd35: dataout = 16'd0;
            6'd36: dataout = 16'd403;
            6'd37: dataout = 16'd1604;
            6'd38: dataout = 16'd3571;
            6'd39: dataout = 16'd6258;
            default: dataout = 16'bx;
        endcase
    end
endmodule