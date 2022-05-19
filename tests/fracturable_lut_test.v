`include "vcTest.v"

module FracturableLUTTest;
  localparam K = 4;
  localparam N = 16;
  localparam HALF_N = N/2;

  reg reset;

  /* We don't actually use this. */
  reg clk = 0;
  always #`CLOCK_PERIOD clk = ~clk;

  reg sc_clk;
  reg [K-1:0] lut_select0 = {K{1'b0}};
  reg [K-2:0] lut_select1 = {K{1'b0}};
  reg sc_data;
  reg sc_data_out;

  wire lut_out0;
  wire lut_out1;

  FracturableLUT#(K, N) dut
  (
    .reset(reset),
    .sc_clk(sc_clk),
    .sc_data(sc_data),
    .sc_data_out(),
    .s0(lut_select0),
    .s1(lut_select1),
    .z0(lut_out0),
    .z1(lut_out1)
  );

  `VC_TEST_SUITE_BEGIN( "FracturableLUT" )

  reg [N-1:0] mem;

  integer i;
  initial
  begin
    // Program with random bits.
    for (i = 0; i < N; i = i + 1) begin
      mem[i] = $random % 2;
    end
    $vcdpluson;
    $vcdplusoff;
  end

  `VC_TEST_CASE_BEGIN(0, "Fracturable LUT programming")
  begin
    // Pulse reset.
    #`CLOCK_PERIOD reset = 1'b1;
    #`CLOCK_PERIOD;
    #`CLOCK_PERIOD reset = 1'b0;
    #`CLOCK_PERIOD;

    for (i = 0; i < N; i = i + 1) begin
      sc_clk = 1'b0;
      sc_data = mem[i];
      #`CLOCK_PERIOD
      sc_clk = 1'b1;
      #`CLOCK_PERIOD;

    end
    sc_clk = 1'b0;

    // Program whether the LUT is fractured or not.
    sc_clk = 1'b0;
    sc_data = 1'b0;   // No fracturing.
    #`CLOCK_PERIOD;
    sc_clk = 1'b1;
    #`CLOCK_PERIOD;
    // Stop programming SC_CLK.
    sc_clk = 1'b0;

    if (1'b0 != dut.fractured) begin
      $display("FAIL: fracturing bit not correctly set");
    end else begin
      $display("OK  : fracturing bit corretly set");
    end

    if (mem != dut.data[N-1:0]) begin
      $display("FAIL: \n\tinput:\t%b\n\tstored:\t%b", mem, dut.data[N-1:0]);
    end else begin
      $display("OK  : input == output");
    end

    // TODO(aryap): Check if those are equal.
  end
  `VC_TEST_CASE_END

  `VC_TEST_CASE_BEGIN(1, "Fracturable LUT read - Not fractured")
  begin
    // Pulse reset.
    #`CLOCK_PERIOD reset = 1'b1;
    #`CLOCK_PERIOD;
    #`CLOCK_PERIOD reset = 1'b0;
    #`CLOCK_PERIOD;

    for (i = 0; i < N; i = i + 1) begin
      sc_clk = 1'b0;
      sc_data = mem[i];
      #`CLOCK_PERIOD
      sc_clk = 1'b1;
      #`CLOCK_PERIOD;

    end
    sc_clk = 1'b0;

    // Program whether the LUT is fractured or not.
    sc_clk = 1'b0;
    sc_data = 1'b0;   // No fracturing.
    #`CLOCK_PERIOD;
    sc_clk = 1'b1;
    #`CLOCK_PERIOD;
    // Stop programming SC_CLK.
    sc_clk = 1'b0;


    $display("Programming: \n\tinput:\t\t%b\n\tstored:\t\t%b\n\tfractured:\t%b",
             mem, dut.data[N-1:0], dut.fractured);


    for (i = 0; i < N; i = i + 1) begin
      lut_select0 = i;
      lut_select1 = i;  // Should do nothing.
      #1;
      // Check that the first output is correct.
      if (lut_out0 != mem[i]) begin
        $display("FAIL: i: %2d; s0: %2d -> z0: %b (expected %b)",
                 i, lut_select0, lut_out0, mem[i]);
      end else begin
        $display("OK  : i: %2d; s0: %2d -> z0: %b (expected %b)",
                 i, lut_select0, lut_out0, mem[i]);
      end
      // Check that the second output doesn't do anything.
      if (lut_out1 != 1'b0) begin
        $display("FAIL: i: %2d; s1: %2d -> z1: %b (expected %b)",
                 i, lut_select1, lut_out1, 1'b0);
      end else begin
        $display("OK  : i: %2d; s1: %2d -> z1: %b (expected %b)",
                 i, lut_select1, lut_out1, 1'b0);
      end
    end
    #100;

  end
  `VC_TEST_CASE_END

  `VC_TEST_CASE_BEGIN(2, "Fracturable LUT read - Fractured")
  begin
    // Pulse reset.
    #`CLOCK_PERIOD reset = 1'b1;
    #`CLOCK_PERIOD;
    #`CLOCK_PERIOD reset = 1'b0;
    #`CLOCK_PERIOD;

    for (i = 0; i < N; i = i + 1) begin
      sc_clk = 1'b0;
      sc_data = mem[i];
      #`CLOCK_PERIOD
      sc_clk = 1'b1;
      #`CLOCK_PERIOD;

    end
    sc_clk = 1'b0;

    // Program whether the LUT is fractured or not.
    sc_clk = 1'b0;
    sc_data = 1'b1;   // Yes fracturing.
    #`CLOCK_PERIOD;
    sc_clk = 1'b1;
    #`CLOCK_PERIOD;
    // Stop programming SC_CLK.
    sc_clk = 1'b0;


    $display("Programming: \n\tinput:\t\t%b\n\tstored:\t\t%b\n\tfractured:\t%b",
             mem, dut.data[N-1:0], dut.fractured);

    $display("%b %b", dut.data1, dut.data0);

    for (i = 0; i < HALF_N; i = i + 1) begin
      lut_select0 = i;
      #1;
      // Check that the first output is correct.
      if (lut_out0 != mem[i]) begin
        $display("FAIL: i: %2d; s0: %2d -> z0: %b (expected %b)",
                 i, lut_select0, lut_out0, mem[i]);
      end else begin
        $display("OK  : i: %2d; s0: %2d -> z0: %b (expected %b)",
                 i, lut_select0, lut_out0, mem[i]);
      end
    end

    for (i = 0; i < HALF_N; i = i + 1) begin
      lut_select1 = i;  // Should now pick from the upper half of the memory.
      // Check that the second output now picks up the upper half of the
      // memory.
      #1;
      if (lut_out1 != mem[i+HALF_N]) begin
        $display("FAIL: i: %2d; s1: %2d -> z1: %b (expected %b)",
                 i, lut_select1, lut_out1, mem[i+HALF_N]);
      end else begin
        $display("OK  : i: %2d; s1: %2d -> z1: %b (expected %b)",
                 i, lut_select1, lut_out1, mem[i+HALF_N]);
      end
    end
  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END( 3 )

endmodule;
