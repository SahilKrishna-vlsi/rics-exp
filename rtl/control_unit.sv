`timescale 1ns / 1ps
typedef enum logic [4:0] {
  ADD,
  SUB,
  AND,
  OR,
  XOR,
  SLL,
  SRL,
  SRA,
  SLT,
  SLTU,
  EQ,
  NE,
  LT,
  GE,
  LTU,
  GEU
} operator_t;

/***
					Instruction type
	7'b0110011 => 	Register type
	7'b0010011 => 	Immediate type
	7'b0000011 => 	Load type
	7'b0100011 => 	Store type
	7'b1100011 => 	Branch type
	7'b1101111 => 	Jump type JAL
	7'b1100111 => 	JUmp type JALR

**/

module alu_io_selections (
    input  logic      [31:0] inst,
    output operator_t        alu_opcode,
    output logic             alu_io_1,
    output logic             alu_io_2
);

  /**
  alu_IO_1 => 1'b1-> reg & 1'b0-> PC
  alu_IO_2 => 1'b1-> reg & 1'b0-> immediate
  **/

  always_comb begin

    alu_opcode = ADD;
    alu_io_1   = 1'b0;
    alu_io_2   = 1'b0;

    case (inst[6:0])
      7'b0110011: begin
        alu_io_1 = 1'b1;
        alu_io_2 = 1'b1;
        case (inst[14:12])
          3'b000: alu_opcode = (inst[31:25] == 7'b0000000) ? ADD : SUB;
          3'b001: alu_opcode = (inst[31:25] == 7'b0000000) ? SLL : ADD;
          3'b010: alu_opcode = (inst[31:25] == 7'b0000000) ? SLT : ADD;
          3'b011: alu_opcode = (inst[31:25] == 7'b0000000) ? SLTU : ADD;
          3'b100: alu_opcode = (inst[31:25] == 7'b0000000) ? XOR : ADD;
          3'b101: alu_opcode = (inst[31:25] == 7'b0000000) ? SRL : SRA;
          3'b110: alu_opcode = (inst[31:25] == 7'b0000000) ? OR : ADD;
          3'b111: alu_opcode = (inst[31:25] == 7'b0000000) ? AND : ADD;
        endcase

      end

      7'b0010011: begin
        alu_opcode = ADD;
        alu_io_1   = 1'b1;
        alu_io_2   = 1'b0;

      end

      7'b0000011: begin
        alu_opcode = ADD;
        alu_io_1   = 1'b1;
        alu_io_2   = 1'b0;
      end

      7'b0100011: begin
        alu_opcode = ADD;
        alu_io_1   = 1'b1;
        alu_io_2   = 1'b0;

      end

      7'b1100011: begin
        alu_io_1 = 1'b1;
        alu_io_2 = 1'b1;
        case (inst[14:12])
          3'b000: alu_opcode = EQ;

          3'b001: alu_opcode = NE;

          3'b100: alu_opcode = LT;

          3'b101: alu_opcode = GE;

          3'b110: alu_opcode = LTU;

          3'b111: alu_opcode = GEU;

          default: alu_opcode = ADD;
        endcase
      end

      7'b1101111: begin
        alu_io_1   = 1'b0;
        alu_io_2   = 1'b0;
        alu_opcode = ADD;
      end

      7'b1100111: begin
        alu_opcode = ADD;
        alu_io_1   = 1'b1;
        alu_io_2   = 1'b0;
      end

      default: begin
        alu_opcode = ADD;
        alu_io_1   = 1'b0;
        alu_io_2   = 1'b0;
      end
    endcase

  end
endmodule

module datapath (
    input  logic [31:0] inst,
    input  logic        zero_flag,
    input  logic        less_than_unsigned_flag,
    input  logic        less_than_flag,
    output logic        mem_read,
    output logic        mem_write,
    output logic        reg_write,
    output logic [ 1:0] pc_select,
    output logic [ 1:0] written_from
);

  /**
	2'b00 -> pc increment & 2'b01 -> pc=pc+offset |2'b10 -> pc rs1+offset
	// 2'b00-> alu | 2'b01->Mem |2'b10->PC
**/
  always_comb begin

    mem_read     = 1'b0;
    mem_write    = 1'b0;
    reg_write    = 1'b0;
    pc_select    = 2'b00;
    written_from = 2'b00;

    case (inst[6:0])
      7'b0110011: begin
        reg_write = 1'b1;
      end

      7'b0010011: begin
        reg_write = 1'b1;
      end

      7'b0000011: begin
        mem_read = 1'b1;
        reg_write = 1'b1;
        written_from = 2'b01;
      end

      7'b0100011: begin
        mem_write = 1'b1;
      end

      7'b1100011: begin
        case (inst[14:12])
          3'b000:  pc_select = zero_flag ? 2'b00 : 2'b01;
          3'b001:  pc_select = !zero_flag ? 2'b00 : 2'b01;
          3'b100:  pc_select = less_than_flag ? 2'b00 : 2'b01;
          3'b101:  pc_select = !less_than_flag ? 2'b00 : 2'b01;
          3'b110:  pc_select = less_than_unsigned_flag ? 2'b00 : 2'b01;
          3'b111:  pc_select = !less_than_unsigned_flag ? 2'b00 : 2'b01;
          default: pc_select = 2'b00;
        endcase
      end

      7'b1101111: begin
        mem_read = 1'b0;
        mem_write = 1'b0;
        reg_write = 1'b1;
        pc_select = 2'b00;
        written_from = 2'b10;
      end

      7'b1100111: begin
        mem_read = 1'b0;
        mem_write = 1'b0;
        reg_write = 1'b1;
        pc_select = 2'b10;
        written_from = 2'b10;
      end

      default: begin
        mem_read     = 1'b0;
        mem_write    = 1'b0;
        reg_write    = 1'b0;
        pc_select    = 2'b00;
        written_from = 2'b00;
      end
    endcase
  end
endmodule

module control_unit (
    input logic [31:0] instruction,
    input logic zeros,
    input logic flag_ltu,
    input logic flag_lt,
    output operator_t opcode,
    output logic alu_input_1,  // 1'b1-> reg & 1'b0-> PC
    output logic alu_input_2,  // 1'b1-> reg & 1'b0-> immediate
    output logic reg_write,
    output logic mem_read,
    output logic mem_write,
    output logic  [1:0] pc_select, // 2'b00 -> pc increment & 2'b01 -> pc=pc+offset |2'b10 -> pc rs1+offset
    output logic [1:0] write_from  // 2'b00-> alu | 2'b01->Mem |2'b10->PC
);

  /**
		With the help of first 6 bits of instruction should be able to tell the type of instruction.
		The upcoming the func3 12-14 and func7 25-31 tells about the operation that should be performed by ALU .
	**/
  alu_io_selections alu_io (
      .inst(instruction),
      .alu_opcode(opcode),
      .alu_io_1(alu_input_1),
      .alu_io_2(alu_input_2)
  );
  datapath data_path (
      .inst(instruction),
      .zero_flag(zeros),
      .less_than_unsigned_flag(flag_ltu),
      .less_than_flag(flag_lt),
      .mem_read(mem_read),
      .mem_write(mem_write),
      .reg_write(reg_write),
      .pc_select(pc_select),
      .written_from(write_from)
  );

endmodule
