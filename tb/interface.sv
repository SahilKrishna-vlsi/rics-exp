logic [31:0] mem[0:1023];
// logic [31:0] data_mem[0:1023];
//======= interface ===============
interface risc_intf (
    input bit clk,
    reset
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
  task load_instruction(int i, bit [31:0] data);
    ins_mem[i] = data;
  endtask
endinterface


