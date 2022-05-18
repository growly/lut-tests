`include "vcTest.v"

module LUTTest;
  localparam K = 7;
  localparam N = 128;

  reg reset;
  reg clk = 0;
  always #`CLOCK_PERIOD clk = ~clk;

  reg sc_clk;
  reg [K-1:0] lut_select = {K{1'b0}};
  reg sc_data;
  reg sc_data_out;

  wire lut_out;

  LUT#(K, N) dut
  (
    .reset(reset),
    .clk(clk),
    // We have to use "clk" for the test clock since the vcTest.v macros rely
    // on it.
    .sc_clk(sc_clk),
    .sc_data(sc_data),
    .sc_data_out(),
    .s(lut_select),
    .z(lut_out)
  );

  `VC_TEST_SUITE_BEGIN( "LUT" )

  reg [N-1:0] mem;

  integer i;
  initial
  begin
    for (i = 0; i < N; i = i + 1) begin
      mem[i] = $random % 2;
    end
    // TODO(aryap): How do I get it to find this file? How do I get Hammer to
    // include it even though it's a .txt?
    // $readmemb("src/lut_test_data.txt", mem);
    $vcdpluson;
    $vcdplusoff;
  end

  `VC_TEST_CASE_BEGIN(0, "LUT programming")
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

    // Stop programming SC_CLK.

    if (mem != dut.data) begin
      $display("FAIL: \n\tinput:\t%b\n\tstored:\t%b", mem, dut.data);
    end else begin
      $display("OK  : input == output");
    end

    // TODO(aryap): Check if those are equal.
  end
  `VC_TEST_CASE_END

  `VC_TEST_CASE_BEGIN(1, "LUT read")
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

    // Stop programming SC_CLK.

    for (i = 0; i < N; i = i + 1) begin
      lut_select = i;
      #1;
      if (lut_out != mem[i]) begin
        $display("FAIL: iter %d: %d -> %b vs %b", i, lut_select, lut_out, mem[i]);
      end else begin
        $display("OK  : iter %d: %d -> %b vs %b", i, lut_select, lut_out, mem[i]);
      end
    end
    #100;

  end
  `VC_TEST_CASE_END

  `VC_TEST_SUITE_END( 2 )

endmodule;
