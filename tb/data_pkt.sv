//======= data packet===========
class risc_pkt extends uvm_sequence_item;
  //need to add the packet data items
  //`uvm_object_utils(risc_pkt)

  rand logic [6:0] opcode;  //op
  rand logic [4:0] A;  //rs1
  rand logic [4:0] B;  //rs2
  rand logic [4:0] rd;  //rd

  // For Reg type instruction
  rand logic [2:0] func3;  //func3
  rand logic [6:0] func7;  //func7

  // For Immediate/store type instruction
  rand logic signed [11:0] i_imm;

  // For Branch type instruction
  rand logic signed [12:0] b_imm;

  // For Unconditional jump/ Jump type instruction
  rand logic signed [20:0] u_imm;
  rand logic [31:0] base_addr;
  int i;

  /***   Instruction type
	7'b0110011 => 	Register type
	7'b0010011 => 	Immediate type
	7'b0000011 => 	Load type
	7'b0100011 => 	Store type
	7'b1100011 => 	Branch type
	7'b1101111 => 	Jump type JAL
	7'b1100111 => 	Jump type JALR
	**/

  constraint c_opcode {
    opcode dist {
      7'h33 := 70,
      7'h13 := 60,
      7'h3  := 50,
      7'h23 := 40,
      7'h63 := 10,
      7'h67 := 10,
      7'h6f := 10
    };
  }
  // constraint c_opcode {opcode == 7'h33;}

  constraint alu_opcode {
    if (opcode == 7'h33 || opcode == 7'h13) {
      if (func3 == 3'b000 && opcode == 7'h33) func7 == 7'b0100000;
      if (func3 == 3'b101)
      func7 dist {
        7'b0100000 := 60,
        7'b0 := 20
      };
    } else {
      if (opcode == 7'h63) {
        func3 dist {
          0 := 10,
          1 := 10,
          4 := 10,
          5 := 10,
          6 := 10,
          7 := 10
        };
      }
    }
  }

  constraint c_imm {

    // general immediate ranges
    i_imm inside {[-64 : 64]};
    b_imm == 4;
    u_imm == 4;
  }


  constraint c_align {

    // branch/jump alignment only
    b_imm % 4 == 0;
    u_imm % 4 == 0;
    i_imm % 4 == 0;

    i_imm != 0;
    b_imm != 0;
    u_imm != 0;
  }


  constraint c_shift {

    // shift-immediate instructions
    if (opcode == 7'h13 && (func3 == 3'b001 || func3 == 3'b101)) i_imm inside {[0 : 31]};
  }


  constraint c_mem {

    // load/store effective address
    A != 0;
    rd != 0;
    B != 0;
    base_addr >= 0;
    base_addr < 4092;
    if (base_addr == 0) {
      i_imm >= 0;
      i_imm <= 11'd64;
    }

    if (opcode == 7'h03 || opcode == 7'h23) {
      base_addr % 4 == 0;
      A inside {[1 : 8]};
      B inside {[9 : 31]};
      rd inside {[9 : 31]};
      //       A != B;
      B != rd;
      //       rd != A;

      signed'(base_addr) + i_imm > 0;
      signed'(base_addr) + i_imm < 4092;
    } else {
      A inside {[9 : 31]};
      B inside {[9 : 31]};
      rd inside {[9 : 31]};
      A != B;
      B != rd;
      rd != A;
    }
  }


  constraint c_branch_jump {

    // branch target
    // b_imm inside {}
    // u_imm == 20'b100;
    if (opcode == 7'h67) {A inside {[1 : 8]};}
    // if (opcode == 7'h63) {
    //   i * 4 + b_imm >= 0;
    //   i * 4 + b_imm <= 4092;
    // }

    // // JAL/JALR target

    if (opcode == 7'h6f || opcode == 7'h67) {
      i * 4 + u_imm >= 0;
      i * 4 + u_imm <= 4092;
    }
  }

  `uvm_object_utils_begin(risc_pkt)
    `uvm_field_int(opcode, UVM_ALL_ON)
    `uvm_field_int(A, UVM_ALL_ON)
    `uvm_field_int(B, UVM_ALL_ON)
    `uvm_field_int(rd, UVM_ALL_ON)
    `uvm_field_int(func3, UVM_ALL_ON)
    `uvm_field_int(func7, UVM_ALL_ON)
    `uvm_field_int(i_imm, UVM_ALL_ON)
    `uvm_field_int(u_imm, UVM_ALL_ON)
    `uvm_field_int(base_addr, UVM_ALL_ON)
  `uvm_object_utils_end


  function new(string name = "risc_pkt");
    super.new(name);
  endfunction
endclass


class data_pkt extends uvm_sequence_item;
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
  logic reset;
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
    `uvm_field_int(reset, UVM_ALL_ON)
    `uvm_field_enum(operator_t, alu_opcode, UVM_ALL_ON)
  `uvm_object_utils_end

  function new(string name = "data_pkt");
    super.new(name);
  endfunction

endclass
