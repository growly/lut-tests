module LUT #(
  parameter INPUTS=6,
  parameter MEM_SIZE=1<<INPUTS,
  parameter FRAME_WIDTH=1
) (
  input [INPUTS-1:0] s,
  output z,

  `ifdef FRACTURABLE
  output z1,
  `endif

  input config_clk,
  input config_en,
  `ifdef LATCH_EXTERNAL
  input [MEM_SIZE-1:0] config_in,
  `else
  input [FRAME_WIDTH-1:0] config_in,
  `endif
  output [FRAME_WIDTH-1:0] config_out,

  input wire reset
);

`ifdef FRACTURABLE

reg [FRAME_WIDTH-1:0] fractured;

wire z0_internal;
wire z1_internal;

wire config_internal;

BaseLUT #(
  .INPUTS(INPUTS-1),
  .MEM_SIZE(1 << (INPUTS-1)),
  .FRAME_WIDTH(FRAME_WIDTH)
) lut0 (
  .s(s[INPUTS-2:0]),
  .z(z0_internal),
  .config_clk(config_clk),
  .config_en(config_en),
  .config_in(fractured),
  .config_out(config_internal),
  .reset(reset)
);

BaseLUT #(
  .INPUTS(INPUTS-1),
  .MEM_SIZE(1 << (INPUTS-1)),
  .FRAME_WIDTH(FRAME_WIDTH)
) lut1 (
  .s(s[INPUTS-2:0]),
  .z(z1_internal),
  .config_clk(config_clk),
  .config_en(config_en),
  .config_in(config_internal),
  .config_out(config_out),
  .reset(reset)
);

assign z = (~fractured & s[INPUTS-1]) ? z1_internal : z0_internal;
assign z1 = fractured ? z1_internal : 1'b0;

`ifdef LATCH_EXTERNAL
always @(config_en or config_in or reset)
  if (reset)
    fractured = 1'b0;
  else if (config_en)
    fractured = config_in[0];
`elsif LATCH_INTERNAL
`else

  // Flop-based scan chain.
  // Stream style configuration logic, in frames of size FRAME_WIDTH.
  always @(posedge config_clk) begin
    if (reset) begin
      fractured[0] <= 0;
    end else if (config_en) begin
      fractured[FRAME_WIDTH-1:0] <= config_in;
    end
  end
`endif

`else

BaseLUT #(
  .INPUTS(INPUTS),
  .MEM_SIZE(MEM_SIZE),
  .FRAME_WIDTH(FRAME_WIDTH)
) lut (
  .s(s),
  .z(z),
  .config_clk(config_clk),
  .config_en(config_en),
  .config_in(config_in),
  .config_out(config_out),
  .reset(reset)
);

`endif

endmodule
