`include "vcTest.v"

module S44Test;
  localparam K = 4;
  localparam N = 32;  // There are 2 4-LUTs to fill.

  reg reset;

  /* We don't actually use this. */
  reg clk = 0;
  always #`CLOCK_PERIOD clk = ~clk;

  reg sc_clk;
  reg [K-1:0] lut_select0 = {K{1'b0}};
  reg [K-1:0] lut_select1 = {K{1'b0}};
  reg sc_data;
  reg sc_data_out;

  wire lut_out0;
  wire lut_out1;

  S44 dut
  (
    .reset(reset),
    // We have to use "clk" for the test clock since the vcTest.v macros rely
    // on it.
    .sc_clk(sc_clk),
    .sc_data(sc_data),
    .s0(lut_select0),
    .s1(lut_select1),
    .sc_data_out(),
    .z0(lut_out0),
    .z1(lut_out1)
  );

  `VC_TEST_SUITE_BEGIN( "S44" )

  reg [N-1:0] mem;
  wire [N/2-1:0] mem_upper, mem_lower;
  assign mem_upper = mem[N-1:N/2];
  assign mem_lower = mem[N/2-1:0];
  reg [K-1:0] lut1_s;

  integer i, j;
  initial
  begin
    // Program with random bits.
    for (i = 0; i < N; i = i + 1) begin
      mem[i] = $random % 2;
    end
    $vcdpluson;
    $vcdplusoff;
  end

  `VC_TEST_CASE_BEGIN(0, "S44 LUT programming")
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

    if (mem_upper != dut.lut1.data) begin
      $display("FAIL: \n\tinput:\t%b\n\tstored:\t%b", mem_upper, dut.lut1.data);
    end else begin
      $display("OK  : input == output");
    end

    if (mem_lower != dut.lut0.data) begin
      $display("FAIL: \n\tinput:\t%b\n\tstored:\t%b", mem_lower, dut.lut0.data);
    end else begin
      $display("OK  : input == output");
    end
  end
  `VC_TEST_CASE_END

  `VC_TEST_CASE_BEGIN(1, "S44 LUT read - Not fractured")
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

    $display("Programming: \n\tinput:\t\t%b\n\tstored:\t\t%b %b\n\tfractured:\t%b",
             mem, dut.lut1.data, dut.lut0.data, dut.fractured);

    for (i = 0; i < N/2; i = i + 1) begin
      lut_select0 = i;

      for (j = 0; j < N/2; j = j + 1) begin
        lut_select1 = j;

        lut1_s = {lut_select1[3:1],mem_lower[lut_select0]};

        // Since the S44 is not fractured, we expect the output of z1 to be the
        // output of lut_select0 on dut.lut0, and then the output of
        // {lut_select1[3:1], dut.lut0.z} at z1.
        #1;

        if (lut_out0 != mem_lower[lut_select0]) begin
          $display("FAIL: i: %2d; s0: %2d -> z0: %b (expected %b)",
                   i, lut_select0, lut_out0, mem_lower[lut_select0]);
        end else begin
          $display("OK  : i: %2d; s0: %2d -> z0: %b (expected %b)",
                   i, lut_select0, lut_out0, mem_lower[lut_select0]);
        end

        if (lut_out1 != mem_upper[lut1_s]) begin
          $display("FAIL: j: %2d; s1: %2d -> lut1_s: %b -> z1: %b (expected %b)",
                   j, lut_select1, lut1_s, lut_out1, mem_upper[lut1_s]);
        end else begin
          $display("OK  : j: %2d; s1: %2d -> lut1_s: %b -> z1: %b (expected %b)",
                   j, lut_select1, lut1_s, lut_out1, mem_upper[lut1_s]);
        end
      end
    end
    #100;

  end
  `VC_TEST_CASE_END

  `VC_TEST_CASE_BEGIN(2, "S44 LUT read - Fractured")
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
    sc_data = 1'b1;   // YES fracturing.
    #`CLOCK_PERIOD;
    sc_clk = 1'b1;
    #`CLOCK_PERIOD;
    // Stop programming SC_CLK.
    sc_clk = 1'b0;

    $display("Programming: \n\tinput:\t\t%b\n\tstored:\t\t%b %b\n\tfractured:\t%b",
             mem, dut.lut1.data, dut.lut0.data, dut.fractured);

    for (i = 0; i < N/2; i = i + 1) begin
      lut_select0 = i;

      for (j = 0; j < N/2; j = j + 1) begin
        lut_select1 = j;

        lut1_s = {lut_select1[3:1],mem_lower[lut_select0]};

        // Since the S44 *is* fractured, we expect the output of z1 to be the
        // output of lut_select0 on dut.lut0, and then the output of
        // lut_select1 at z1.
        #1;

        if (lut_out0 != mem_lower[lut_select0]) begin
          $display("FAIL: i: %2d; s0: %2d -> z0: %b (expected %b)",
                   i, lut_select0, lut_out0, mem_lower[lut_select0]);
        end else begin
          $display("OK  : i: %2d; s0: %2d -> z0: %b (expected %b)",
                   i, lut_select0, lut_out0, mem_lower[lut_select0]);
        end

        if (lut_out1 != mem_upper[lut_select1]) begin
          $display("FAIL: j: %2d; s1: %2d -> z1: %b (expected %b)",
                   j, lut_select1, lut_out1, mem_upper[lut_select1]);
        end else begin
          $display("OK  : j: %2d; s1: %2d -> z1: %b (expected %b)",
                   j, lut_select1, lut_out1, mem_upper[lut_select1]);
        end
      end
    end
    #100;

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END( 3 )

endmodule;
