module ClockChanger #(parameter int DESIRED_FREQUENCY = 48_000) (input logic clk_50MHz, output logic clk_out);
  
  localparam int DIVIDER = 50_000_000 / (2*DESIRED_FREQUENCY);
  logic [31:0] counter = 0;
  logic toggle = 0;

  always @(posedge clk_50MHz) begin
    if (counter == DIVIDER - 1) begin
      counter <= 0;
      toggle <= ~toggle;
    end else begin
      counter <= counter + 1;
    end
  end

  assign clk_out = toggle;
  
endmodule
