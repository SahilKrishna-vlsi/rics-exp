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
      7'h33 := 35,
      7'h13 := 35,
      7'h3  := 20,
      7'h23 := 20,
      7'h63 := 20,
      7'h67 := 10,
      7'h6f := 10
    };
  }
  // constraint c_opcode {opcode == 7'h33;}

  constraint c_func {
    if (opcode == 7'h33 || opcode == 7'h13) {
      func3 dist {
        0 := 40,
        1 := 40,
        2 := 30,
        3 := 30,
        4 := 20,
        5 := 20,
        6 := 10,
        7 := 10
      };
    }
    if (opcode == 7'h63) {
      func3 dist {
        0 := 10,
        1 := 20,
        4 := 30,
        5 := 40,
        6 := 50,
        7 := 60
      };
    }
  }
  constraint c_func7 {
    if (((func3 == 3'b000 || func3 == 3'b101) && opcode == 7'h33)||(func3==3'b101 && opcode == 7'h13)) {
      func7 dist {
        7'h20 := 100,
        7'h00 := 20
      };
    }
  }
  constraint c_func7_1 {
    if (opcode == 7'h13 && func3 == 001) func7 == 7'h00;
    if (opcode == 7'h13 && func3 == 101) i_imm[10] == func7[6];
  }
  constraint c_imm {
    i_imm inside {[-2048 : 2047]};
    b_imm inside {[-64 : 64]};
    u_imm inside {[-64 : 64]};
  }

  constraint c_imm_1 {
    i_imm % 4 == 0;
    b_imm % 4 == 0;
    u_imm % 4 == 0;
    i_imm != 0;
    u_imm != 0;
    b_imm != 0;
  }

  constraint imm2 {
    i * 4 + i_imm > 0;
    i * 4 + b_imm > 0;
    i * 4 + u_imm > 0;
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
