// UC Berkeley CS250
// Authors: Arya Reais-Parsi (aryap@berkeley.edu)
//          Ryan Thornton (rpthornton@berkeley.edu)

// Assumptions:
//  MEM_SIZE is a multiple of FRAME_WIDTH 

// Configuration latches an external configuration bus all at once.
//`define LATCH_EXTERNAL

// TODO(growly): Configuration latches implement shift register with two
// non-overlapping clocks.
//`define LATCH_INTERNAL

module BaseLUT #(
    parameter INPUTS=4,
    parameter MEM_SIZE=1<<INPUTS,
    parameter FRAME_WIDTH=1
) (
    input [INPUTS-1:0] s, 
    output z,

    // Stream Style Configuration
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

// This is memory storage. Without specification, the synthesis tool can infer
// what kind of cells we want based on how we define the behaviour between
// each element.
reg [MEM_SIZE-1:0] mem = 0;

// This makes our decoder + mux.
// assign z = mem[s];

Predecoder #(
  .INPUTS(INPUTS),
  .WIDTH(MEM_SIZE)
) predecode (
  .values(mem),
  .s(s),
  .z(z)
);

`ifdef LATCH_EXTERNAL
generate 
  genvar i;
  always @(config_en or config_in or reset)
    if (reset)
      mem = 0;
    else if (config_en)
      mem = config_in
endgenerate
assign config_out = mem[MEM_SIZE-1];

`elsif LATCH_INTERNAL
`else

// Flop-based scan chain.
// Stream style configuration logic, in frames of size FRAME_WIDTH.
generate 
  genvar i;
  for (i=1; i<(MEM_SIZE/FRAME_WIDTH); i=i+1) begin
    always @(posedge config_clk) begin
      if (reset) begin
        mem[i] <= 0;
      end else if (config_en) begin
        mem[(i+1)*FRAME_WIDTH-1:i*FRAME_WIDTH] <= mem[(i)*FRAME_WIDTH-1:(i-1)*FRAME_WIDTH];
      end
    end
  end
  always @(posedge config_clk) begin
    if (reset) begin
      mem[0] <= 0;
    end else if (config_en) begin
      mem[FRAME_WIDTH-1:0] <= config_in;
    end
  end
endgenerate
assign config_out = mem[MEM_SIZE-1:MEM_SIZE-FRAME_WIDTH];
`endif

endmodule
