/** RTL model of the "soft-wired S44 LUT" described in Feng, Greene
  * & Mischenko, "Improving FPGA Performance with a S44 LUT Structure".
  *
  * Arya Reais-Parsi (aryap@berkeley.edu, growly@google.com)
  */
module s44_soft #()(
  //input wire reset,
  input wire clk,
  input wire sc_data,
  input wire sc_en,

  input wire [3:0] s0,
  input wire [3:0] s1,

  output wire sc_data_out,
  output wire z0,
  output wire z1
);

wire lut0_z;

reg fractured;

wire lut1_s_0;
wire lut1_sc_data;

assign lut1_s_0 = fractured ? s1[0] : lut0_z;

assign z0 = lut0_z;

// There are two 4-LUTs in here.
//
// sc_data is shifted in as follows:
// fractured => lut1 => lut0
lut #(
  .INPUTS(4),
  .CONFIG_WIDTH(1)
) lut0 (
  .config_clk(clk),
  .config_en(sc_en),
  .config_in(lut1_sc_data),
  .config_out(sc_data_out),
  .addr(s0),
  .out(lut0_z)
);

lut #(
  .INPUTS(4),
  .CONFIG_WIDTH(1)
) lut1 (
  .config_clk(clk),
  .config_en(sc_en),
  .config_in(fractured),
  .config_out(lut1_sc_data),
  .addr({s1[3:1],lut1_s_0}),
  .out(z1)
);

always @(posedge clk) begin
  fractured <= sc_data;
end

endmodule
