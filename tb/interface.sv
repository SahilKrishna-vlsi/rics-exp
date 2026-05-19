interface risc_intf (
    input bit clk,
    reset
);
  logic [31:0] pc;
  logic [31:0] inst;
  logic signed [31:0] A_value;
  logic signed [31:0] B_value;
  logic signed [31:0] reg_A_value;
  logic signed [31:0] reg_B_value;
  logic signed [31:0] offset;
  logic z_flag, lt_flag, ltu_flag;
  logic signed [31:0] alu_result;
  logic [31:0] pc_next_value;
  logic reg_write, mem_read, mem_write, alu_select_1, alu_select_2;
  logic [1:0] pc_select, write_from;
  logic signed [31:0] write_data, mem_data;
  operator_t alu_opcode;
  task load_instruction(int i, bit signed [31:0] data);
    ins_mem[i] = data;
  endtask
endinterface
