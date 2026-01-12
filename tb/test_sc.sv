module test_sc ();

  logic clk, reset;


  single_core SC_dut (
      .clk  (clk),
      .reset(reset)
  );

  initial begin
    $dumpfile("sim/SC_wave.vcd");
    $dumpvars(0, test_sc);
    $readmemh("sw/inst_set.hex", SC_dut.instructions.mem);
    $display(" Memory loaddded form testbench");
    #0 clk = 1'b0;
    reset = 1'b1;
    #50 reset = 1'b0;
    #50 reset = 1'b1;
    #100 clk = 1'b1;
    repeat (14) #100 clk = ~clk;
    #10 $finish;
  end




endmodule
