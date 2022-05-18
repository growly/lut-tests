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

reg fractured;

wire z0;
wire z1;

wire config_internal;

BaseLUT #(
  .INPUTS(INPUTS-1),
  .MEM_SIZE(1 << (INPUTS-1)),
  .FRAME_WIDTH(FRAME_WIDTH)
) lut0 (
  .s(s[INPUTS-2:0]),
  .z(z0),
  .config_clk(config_clk),
  .config_en(config_en),
  .config_in(config_in),
  .config_out(config_internal),
  .reset(reset)
);

BaseLUT #(
  .INPUTS(INPUTS-1),
  .MEM_SIZE(1 << (INPUTS-1)),
  .FRAME_WIDTH(FRAME_WIDTH)
) lut1 (
  .s(s[INPUTS-2:0]),
  .z(z1),
  .config_clk(config_clk),
  .config_en(config_en),
  .config_in(config_internal),
  .config_out(config_out),
  .reset(reset)
);

always @(*) begin
  if (reset) begin
  end else if (~fractured) begin
    z = s[INPUTS-1] ? z1 : z0;
    z1 = 1'b0;
  end else if (fractured) begin
    z = z0;
    z1 = z1;
  end
end

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
