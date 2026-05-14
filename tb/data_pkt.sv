//======= data packet===========
class risc_pkt extends uvm_sequence_item;
  //need to add the packet data items
  //`uvm_object_utils(risc_pkt)

  rand logic [ 6:0] opcode;  //op
  rand logic [ 4:0] A;  //rs1
  rand logic [ 4:0] B;  //rs2
  rand logic [ 4:0] rd;  //rd

  // For Reg type instruction
  rand logic [ 2:0] func3;  //func3
  rand logic [ 6:0] func7;  //func7

  // For Immediate/Store type instruction
  rand logic [11:0] i_imm;

  // For Unconditional jump/ Jump type instruction
  rand logic [20:0] u_imm;

  /***   Instruction type
	7'b0110011 => 	Register type
	7'b0010011 => 	Immediate type
	7'b0000011 => 	Load type
	7'b0100011 => 	Store type
	7'b1100011 => 	Branch type
	7'b1101111 => 	Jump type JAL
	7'b1100111 => 	JUmp type JALR
	**/
  constraint c_opcode {opcode inside {7'h33, 7'h13, 7'h3, 7'h23};}
  constraint c_i_mm {i_imm < 100;}

  `uvm_object_utils_begin(risc_pkt)
    `uvm_field_int(opcode, UVM_ALL_ON)
    `uvm_field_int(A, UVM_ALL_ON)
    `uvm_field_int(B, UVM_ALL_ON)
    `uvm_field_int(rd, UVM_ALL_ON)
    `uvm_field_int(func3, UVM_ALL_ON)
    `uvm_field_int(func7, UVM_ALL_ON)
    `uvm_field_int(i_imm, UVM_ALL_ON)
    `uvm_field_int(u_imm, UVM_ALL_ON)
  `uvm_object_utils_end


  function new(string name = "risc_pkt");
    super.new(name);
  endfunction
endclass


class data_pkt extends uvm_sequence_item;
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

  `uvm_object_utils_begin(data_pkt)
    `uvm_field_int(pc, UVM_ALL_ON)
    `uvm_field_int(inst, UVM_ALL_ON)
    `uvm_field_int(A_value, UVM_ALL_ON)
    `uvm_field_int(B_value, UVM_ALL_ON)
    `uvm_field_int(reg_A_value, UVM_ALL_ON)
    `uvm_field_int(reg_B_value, UVM_ALL_ON)
    `uvm_field_int(offset, UVM_ALL_ON)
    `uvm_field_int(z_flag, UVM_ALL_ON)
    `uvm_field_int(lt_flag, UVM_ALL_ON)
    `uvm_field_int(ltu_flag, UVM_ALL_ON)
    `uvm_field_int(alu_result, UVM_ALL_ON)
    `uvm_field_int(reg_write, UVM_ALL_ON)
    `uvm_field_int(mem_read, UVM_ALL_ON)
    `uvm_field_int(mem_write, UVM_ALL_ON)
    `uvm_field_int(alu_select_1, UVM_ALL_ON)
    `uvm_field_int(alu_select_2, UVM_ALL_ON)
    `uvm_field_int(pc_select, UVM_ALL_ON)
    `uvm_field_int(write_from, UVM_ALL_ON)
    `uvm_field_int(write_data, UVM_ALL_ON)
    `uvm_field_int(mem_data, UVM_ALL_ON)
    `uvm_field_enum(operator_t, alu_opcode, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "data_pkt");
    super.new(name);
  endfunction

endclass
