module Predecoder #(
  parameter INPUTS=4,
  parameter WIDTH=1<<INPUTS
) (
  input wire [WIDTH-1:0] values,
  input wire [INPUTS-1:0] s,
  output wire z
);

`ifdef PREDECODE_2
localparam LOWER_BITS = WIDTH/4;

// One hot encoding would be useful if we had transmission gates.
//wire [1:0] s_predecode
//  = (s[1:0] == 2'b00) ? 4'b0001
//  : (s[1:0] == 2'b01) ? 4'b0010
//  : (s[1:0] == 2'b10) ? 4'b0100
//  : (s[1:0] == 2'b11) ? 4'b1000 : 4'b0000;

wire [INPUTS-3:0] s_lower = s[INPUTS-3:0];

// TODO(growly): Couldn't get this to work.  //wire [3:0] values_intermediate = {
//    values[4*LOWER_BITS-1:3*LOWER_BITS][s_lower],
//    values[3*LOWER_BITS-1:2*LOWER_BITS][s_lower],
//    values[2*LOWER_BITS-1:1*LOWER_BITS][s_lower],
//    values[1*LOWER_BITS-1:0*LOWER_BITS][s_lower]};

// There must be a nicer way.
wire [LOWER_BITS-1:0] values_11 = values[4*LOWER_BITS-1:3*LOWER_BITS];
wire select_11 = values_11[s_lower];
wire [LOWER_BITS-1:0] values_10 = values[3*LOWER_BITS-1:2*LOWER_BITS];
wire select_10 = values_10[s_lower];
wire [LOWER_BITS-1:0] values_01 = values[2*LOWER_BITS-1:1*LOWER_BITS];
wire select_01 = values_01[s_lower];
wire [LOWER_BITS-1:0] values_00 = values[1*LOWER_BITS-1:0*LOWER_BITS];
wire select_00 = values_00[s_lower];

// TODO(growly): How to make sure this is a balanced tree?
reg z_int;
always @(*) begin
  case (s[INPUTS-1:INPUTS-2])
    2'b00: z_int = select_00;
    2'b01: z_int = select_01;
    2'b10: z_int = select_10;
    2'b11: z_int = select_11;
  endcase
end
assign z = z_int;

// Extract the two most-significant selection bits. These are pre-decoded:
//wire p1 = s[INPUTS-1];
//wire p0 = s[INPUTS-2];

//always @(*) begin
//  if (~p1 & ~p0) begin
//    z_int = select_00;
//  end else if (~p1 & p0) begin
//    z_int = select_01;
//  end else if (p1 & ~p0) begin
//    z_int = select_10;
//  end else begin
//    z_int = select_11;
//  end
//end

//assign z
//  = ~p1 & ~p0 ? select_00
//  : ~p1 & p0 ? select_01
//  : p1 & ~p0 ? select_10
//  : p1 & p0 ? select_11 : 1'bz;
           

`else
assign z = values[s];
`endif

endmodule
