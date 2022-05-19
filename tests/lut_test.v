`define CLOCK_PERIOD 10

module LUTTest;
  localparam K = 5;
  localparam FRAME_SIZE = 1;

  localparam LUT_MEM_SIZE = 1 << K;
`ifdef FRACTURABLE
  localparam N = LUT_MEM_SIZE + FRAME_SIZE;
`else
  localparam N = LUT_MEM_SIZE;
`endif

  reg reset;
  reg clk = 0;
  always #`CLOCK_PERIOD clk = ~clk;

  reg sc_clk;
  reg [K-1:0] lut_select = {K{1'b0}};
  reg sc_en = 1'b1;
  reg sc_data;
  wire sc_data_out;

  wire lut_out;

`ifdef FRACTURABLE
  wire lut_out1;
`endif

  LUT#(
    .INPUTS(K),
    .FRAME_WIDTH(1)
  ) dut (
    .s(lut_select),
`ifdef FRACTURABLE
    .z(lut_out),
    .z1(lut_out1),
`else
    .z(lut_out),
`endif

    .config_clk(sc_clk),
    .config_en(sc_en),
    // We have to use "clk" for the test clock since the vcTest.v macros rely
    // on it.
    .config_in(sc_data),
    .config_out(sc_data_out),

    .reset(reset)
  );

  reg [N - 1:0] mem;

  integer i;
  initial
  begin
    // Fill configuration stream with random bits.
    for (i = 0; i < N; i = i + 1) begin
      mem[i] = $random % 2;
    end

    $display("%3d-LUT mem size: %4d", K, N);
`ifdef FRACTURABLE
    $display("fracturable, frame size: %3d", FRAME_SIZE);
`endif  // FRACTURABLED

    // NOTE(growly): You might want to read LUT test data here:
    // $readmemb("src/lut_test_data.txt", mem);

    // TEST 1.
    $display("*** TEST 1: LUT memory is loaded as expected ***");

    // Pulse reset.
    #`CLOCK_PERIOD reset = 1'b1;
    #`CLOCK_PERIOD;
    #`CLOCK_PERIOD reset = 1'b0;
    #`CLOCK_PERIOD;

    for (i = 0; i < N; i = i + 1) begin
      sc_clk = 1'b0;
      // We shift in backwards, otherwise, assign mem[i].
      sc_data = mem[N - 1 - i];
      #`CLOCK_PERIOD
      sc_clk = 1'b1;
      #`CLOCK_PERIOD;
    end

    // Stop programming SC_CLK.
  `ifdef FRACTURABLE
    // For fractured LUTs, our test memory looks like:
    // msb                                                          lsb
    // |<-- lut 1 mem -->|<-- lut 0 mem -->|<-- fracturable config -->|
    if (mem[LUT_MEM_SIZE/2+FRAME_SIZE-1:FRAME_SIZE] != dut.lut0.mem) begin
      $display("FAIL: \n\tlut 0 input:\t%b\n\tlut 0 stored:\t%b", mem[(N-1)/2:1], dut.lut0.mem);
    end else begin
      $display("OK  : lut0 input == output");
    end

    if (mem[LUT_MEM_SIZE+FRAME_SIZE+1:LUT_MEM_SIZE/2+FRAME_SIZE] != dut.lut1.mem) begin
      $display("FAIL: \n\tlut 1 input:\t%b\n\tlut 1 stored:\t%b", mem[N-2:(N-1)/2+1], dut.lut1.mem);
    end else begin
      $display("OK  : lut1 input == output");
    end

  `else
    if (mem != dut.lut.mem) begin
      $display("FAIL: \n\tinput:\t%b\n\tstored:\t%b", mem, dut.lut.mem);
    end else begin
      $display("OK  : input == output");
    end
  `endif  // FRACTURABLE

    // TODO(growly): Check if those are equal.
   
    // TEST 2.
    $display("*** TEST 2: LUT outputs match selection pins ***");

    // Pulse reset.
    #`CLOCK_PERIOD reset = 1'b1;
    #`CLOCK_PERIOD;
    #`CLOCK_PERIOD reset = 1'b0;
    #`CLOCK_PERIOD;

`ifdef FRACTURABLE
    // Configure fractured-ness register (this is the first bit in whatever
    // frame is allocated to the fracturable LUT in the configuration stream).
    mem[0] = 1'b0;
`endif  // FRACTURABLE

    for (i = 0; i < N; i = i + 1) begin
      sc_clk = 1'b0;
      // We shift in backwards, otherwise, assign mem[i].
      sc_data = mem[N - 1 - i];
      #`CLOCK_PERIOD
      sc_clk = 1'b1;
      #`CLOCK_PERIOD;
    end

`ifdef FRACTURABLE
    // Configure fractured-ness register (this is the first bit in whatever
    if (dut.fractured !== 1'b0) begin
      $display("FAIL: fractured bit not set correctly, %b vs %b", dut.fractured, mem[0]);
    end else begin
      $display("OK  : fractured bit set correctly, %b vs %b", dut.fractured, mem[0]);
    end
`endif  // FRACTURABLE

    for (i = 0; i < LUT_MEM_SIZE; i = i + 1) begin
      lut_select = i;
      #1;

`ifdef FRACTURABLE
      if (lut_out !== mem[i+FRAME_SIZE]) begin
        $display("FAIL:  z iter %d: %d -> %b vs %b", i, lut_select, lut_out, mem[i+FRAME_SIZE]);
      end else begin
        $display("OK  :  z iter %d: %d -> %b vs %b", i, lut_select, lut_out, mem[i+FRAME_SIZE]);
      end

      if (lut_out1 !== 1'b0) begin
        $display("FAIL: z1 iter %d: %d -> %b vs %b", i, lut_select, lut_out1, 1'b0);
      end else begin
        $display("OK  : z1 iter %d: %d -> %b vs %b", i, lut_select, lut_out1, 1'b0);
      end
`else
      if (lut_out !== mem[i]) begin
        $display("FAIL:  z iter %d: %d -> %b vs %b", i, lut_select, lut_out, mem[i]);
      end else begin
        $display("OK  :  z iter %d: %d -> %b vs %b", i, lut_select, lut_out, mem[i]);
      end
`endif  // FRACTURABLE
    end

`ifdef FRACTURABLE
    // TEST 3.
    $display("*** TEST 3: Behaviour when fractured ***");

    // Pulse reset.
    #`CLOCK_PERIOD reset = 1'b1;
    #`CLOCK_PERIOD;
    #`CLOCK_PERIOD reset = 1'b0;
    #`CLOCK_PERIOD;

    // Configure fractured-ness register (this is the first bit in whatever
    // frame is allocated to the fracturable LUT in the configuration stream).
    mem[0] = 1'b1;

    for (i = 0; i < N; i = i + 1) begin
      sc_clk = 1'b0;
      // We shift in backwards, otherwise, assign mem[i].
      sc_data = mem[N - 1 - i];
      #`CLOCK_PERIOD
      sc_clk = 1'b1;
      #`CLOCK_PERIOD;
    end

    if (dut.fractured !== 1'b1) begin
      $display("FAIL: fractured bit not set correctly, %b vs %b", dut.fractured, mem[0]);
    end else begin
      $display("OK  : fractured bit set correctly, %b vs %b", dut.fractured, mem[0]);
    end

    for (i = 0; i < LUT_MEM_SIZE/2; i = i + 1) begin
      lut_select = i;
      #1;

      if (lut_out !== mem[i+FRAME_SIZE]) begin
        $display("FAIL:  z iter %d: %d -> %b vs %b", i, lut_select, lut_out, mem[i+FRAME_SIZE]);
      end else begin
        $display("OK  :  z iter %d: %d -> %b vs %b", i, lut_select, lut_out, mem[i+FRAME_SIZE]);
      end

      if (lut_out1 !== mem[LUT_MEM_SIZE/2 + i+FRAME_SIZE]) begin
        $display("FAIL:  z iter %d: %d -> %b vs %b", i, lut_select, lut_out1, mem[LUT_MEM_SIZE/2 + i+FRAME_SIZE]);
      end else begin
        $display("OK  : z1 iter %d: %d -> %b vs %b", i, lut_select, lut_out1, mem[LUT_MEM_SIZE/2 + i+FRAME_SIZE]);
      end
    end
`endif  // FRACTURABLE

    #100;
    $finish;

  end

endmodule
