import uvm_pkg::*;
import isa_types_pkg::*;
logic signed [31:0] mem[0:1023];
int load;
`include "uvm_macros.svh"
// `include "interface.sv"
`include "data_pkt.sv"
`include "seqr.sv"
`include "seq.sv"
`include "mon.sv"
`include "driver.sv"
`include "scr.sv"
`include "ag.sv"
`include "env.sv"
`include "test.sv"

//=============== test bench =============
module tb;
  bit clk;
  bit reset;
  risc_intf rc_inf (
      clk,
      reset
  );
  single_core sc (rc_inf);

  initial begin
    #0 reset = 1;
    //     load =0;
    //     $dumpfile("dump.vcd");
    //     $dumpvars(0, tb);
    wait (load == 499) clk = 0;
    reset = 1;
  end

  always #10 clk = ~clk;
  //   always @(posedge clk) begin
  //     $display("%t",$time);
  //     $display("%h",ins_mem[0]);
  //     $display("%h",ins_mem[1]);
  //   end

  initial begin
    uvm_config_db#(virtual risc_intf)::set(null, "*", "rc_inf", rc_inf);
    run_test("risc_test");
    #1000 $finish;
  end

  initial begin
    register[0] = 31'd0;
    register[1] = 31'd512;
    register[2] = 31'd1024;
    register[3] = 31'd2048;
    register[4] = 31'd1208;
    register[5] = 31'd1708;
    register[6] = 31'd1840;
    register[7] = 31'd2000;
    register[8] = 31'd1080;
    foreach (da_mem[i]) begin
      da_mem[i] = i;
      //       $display("data memory %d: %h", i, da_mem[i]);
    end
    foreach (register[i]) begin
      if (i > 8) register[i] = i;
      //       $display("register %d: %h", i, register[i]);
    end
    #5 register[1] = 31'd512;
    register[2] = 31'd1024;
    register[3] = 31'd2048;
    register[4] = 31'd1208;
    register[5] = 31'd1708;
    register[6] = 31'd1840;
    register[7] = 31'd2000;
    register[8] = 31'd1080;

  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
  end
endmodule
