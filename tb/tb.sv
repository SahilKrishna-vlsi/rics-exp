import uvm_pkg::*;
import isa_types_pkg::*;

`include "uvm_macros.svh"
logic [31:0] mem[0:1023];
int load;
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
    //     $dumpfile("dump.vcd");
    //     $dumpvars(0, tb);
    wait (load == 500) clk = 0;
    reset = 1;
    #1 reset = 0;
    #2 reset = 1;
  end

  always #10 clk = ~clk;

  initial begin
    uvm_config_db#(virtual risc_intf)::set(null, "*", "rc_inf", rc_inf);
    run_test("risc_test");
    #1000 $finish;
  end

  initial begin
    register[0] = 0;
    foreach (da_mem[i]) begin
      da_mem[i] = i;
      //       $display("data memory %d: %h", i, da_mem[i]);
    end
    foreach (register[i]) begin
      if (i != 0) register[i] = i;
      //       $display("register %d: %h", i, register[i]);
    end
  end

  initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, tb);
  end
endmodule
