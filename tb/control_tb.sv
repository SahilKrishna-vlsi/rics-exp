`timescale 1ns/1ps

module tb_control_unit;

  // Inputs
  logic [31:0] inst;
  logic        zeros;
  logic        flag_ltu;
  logic        flag_lt;

  // Outputs
  operator     alu_op_select;
  logic        alu_scr_sel_1;
  logic        alu_scr_sel_2;
  logic        reg_write;
  logic        mem_read;
  logic        mem_write;
  logic [1:0]  PC_select;
  logic [1:0]  write_from;

  // DUT
  control_unit dut (
    .inst(inst),
    .zeros(zeros),
    .flag_ltu(flag_ltu),
    .flag_lt(flag_lt),
    .alu_op_select(alu_op_select),
    .alu_scr_sel_1(alu_scr_sel_1),
    .alu_scr_sel_2(alu_scr_sel_2),
    .reg_write(reg_write),
    .mem_read(mem_read),
    .mem_write(mem_write),
    .PC_select(PC_select),
    .write_from(write_from)
  );

  // Task to apply instruction
  task apply_inst(input [31:0] i);
    begin
      inst = i;
      #1;
    end
  endtask

  initial begin
    // defaults
    inst     = 32'b0;
    zeros    = 0;
    flag_lt  = 0;
    flag_ltu = 0;

    // ----------------------------
    // R-TYPE: ADD
    // opcode=0110011, funct3=000, funct7=0000000
    // ----------------------------
    apply_inst({7'b0000000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011});

    // ----------------------------
    // R-TYPE: SUB
    // ----------------------------
    apply_inst({7'b0100000, 5'd2, 5'd1, 3'b000, 5'd3, 7'b0110011});

    // ----------------------------
    // I-TYPE: ADDI
    // opcode=0010011, funct3=000
    // ----------------------------
    apply_inst({12'd5, 5'd1, 3'b000, 5'd2, 7'b0010011});

    // ----------------------------
    // LOAD
    // opcode=0000011
    // ----------------------------
    apply_inst({12'd8, 5'd1, 3'b010, 5'd2, 7'b0000011});

    // ----------------------------
    // STORE
    // opcode=0100011
    // ----------------------------
    apply_inst({7'd1, 5'd2, 5'd1, 3'b010, 5'd3, 7'b0100011});

    // ----------------------------
    // BRANCH: BEQ (taken)
    // opcode=1100011, funct3=000
    // ----------------------------
    zeros = 1;
    apply_inst({7'd1, 5'd2, 5'd1, 3'b000, 5'd3, 7'b1100011});

    // ----------------------------
    // BRANCH: BLT (taken)
    // ----------------------------
    flag_lt = 1;
    apply_inst({7'd1, 5'd2, 5'd1, 3'b100, 5'd3, 7'b1100011});

    // ----------------------------
    // JAL
    // opcode=1101111
    // ----------------------------
    apply_inst({20'd0, 5'd1, 7'b1101111});

    // ----------------------------
    // JALR
    // opcode=1100111
    // ----------------------------
    apply_inst({12'd0, 5'd1, 3'b000, 5'd2, 7'b1100111});

    #10;
    $finish;
  end

endmodule
