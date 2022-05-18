module Predecoder #(
  parameter INPUTS=4,
  parameter WIDTH=1<<INPUTS
) (
  input wire [WIDTH-1:0] values,
  input wire [INPUTS-1:0] s,
  output wire z
);

`ifdef PREDECODE_2
wire [1:0] s_predecode
  = (s[1:0] == 2'b00) ? 4'b0001
  : (s[1:0] == 2'b01) ? 4'b0010
  : (s[1:0] == 2'b10) ? 4'b0100
  : (s[1:0] == 2'b11) ? 4'b1000 : 4'b0000;
wire values_intermediate = values[INPUTS-1:2];
assign z = values_intermediate[s_predecode];
`else
assign z = values[s];
`endif

endmodule
