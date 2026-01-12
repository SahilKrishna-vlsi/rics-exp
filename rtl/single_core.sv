import isa_types_pkg::*;
module single_core (
    input logic clk,
    input logic reset

);
  logic [31:0] pc;
  logic [31:0] inst;
  logic [31:0] A_value;
  logic [31:0] B_value;
  logic [31:0] reg_A_value;
  logic [31:0] reg_B_value;
  logic [31:0] offset;
  logic z_flag, lt_flag, ltu_flag;
  logic [31:0] alu_result;
  logic [31:0] pc_4;
  logic reg_write, mem_read, mem_write, alu_select_1, alu_select_2;
  logic [1:0] pc_select, write_from;
  logic [31:0] write_data, mem_data;
  operator_t alu_opcode;
  fetch_block Fetch (
      .clock    (clk),
      .reset    (reset),
      .offset   (offset),
      .reg_val  (reg_A_value),
      .PC_select(pc_select),
      .pc_4     (pc_4),
      .pc       (pc)
  );
  inst_mem instructions (
      .PC  (pc),
      .inst(inst)
  );
  imm_generator gene_offeset (
      .inst(inst),
      .imm_result(offset)
  );
  control_unit Decode (
      .instruction(inst),
      .zeros(z_flag),
      .flag_ltu(ltu_flag),
      .flag_lt(lt_flag),
      .opcode(alu_opcode),
      .alu_input_1(alu_select_1),
      .alu_input_2(alu_select_2),
      .reg_write(reg_write),
      .mem_read(mem_read),
      .mem_write(mem_write),
      .pc_select(pc_select),
      .write_from(write_from)
  );

  registers reg_file (
      .clock       (clk),
      .write_port  (inst[11:7]),
      .write_data  (write_data),
      .write_enable(reg_write),
      .read_port1  (inst[19:15]),
      .read_port2  (inst[24:20]),
      .read_data1  (reg_A_value),
      .read_data2  (reg_B_value)
  );


  assign A_value = alu_select_1 ? reg_A_value : pc;
  assign B_value = alu_select_2 ? reg_B_value : offset;


  alu Execute (
      .opcode(alu_opcode),
      .A(A_value),
      .B(B_value),
      .result(alu_result),
      .zeros(z_flag),
      .ltu(ltu_flag),
      .lt(lt_flag)
  );

  assign write_data = (write_from == 2'b00) ? alu_result : (write_from == 2'b01) ? mem_data   :  (write_from == 2'b10) ? pc_4 : 32'b0;

  data_mem data_memory (
      .clk       (clk),
      .mem_read  (mem_read),
      .mem_write (mem_write),
      .addr      (alu_result),
      .write_data(reg_B_value),
      .read_data (mem_data)
  );


endmodule
