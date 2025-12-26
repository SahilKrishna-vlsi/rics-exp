typedef enum logic [4:0]{
	ADD,SUB,
	AND,OR,XOR,
	SLL,SRL,SRA,SLT,SLTU,
	EQ,NE,LT,GE,LTU,GEU
}operator_t;
module control_unit(
	input logic [31:0] inst;

	input  logic       zeros                   ;
	input  logic       flag_ltu                ;
	input  logic       flag_lt                 ;
	output             operator_t alu_op_select;
	output logic       alu_scr_sel_1           ; // 1'b1-> reg & 1'b0-> PC
	output logic       alu_scr_sel_2           ; // 1'b1-> reg & 1'b0-> immediate
	output logic       reg_write               ;
	output logic       mem_read                ;
	output logic       mem_write               ;
	output logic [1:0] PC_select               ; // 2'b00 -> pc increment & 2'b01 -> pc=pc+offset |2'b10 -> pc rs1+offset
	output logic [1:0] write_from              ; // 2'b00-> alu | 2'b01->Mem |2'b10->PC
);
  logic [6:0] opcode;
	assign opcode = inst[6:0];
	//isa ISA_type[1:0];
  logic  [2:0] func3;
  logic  [6:0] func7;
  logic [11:0] imm  ;
	/*
		With the help of first 6 bits of instruction should be able to tell the type of instruction.
		The upcoming the func3 12-14 and func7 25-31 tells about the operation that should be performed by ALU .
	**/

	always_comb begin

		alu_op_select = ADD  ;
		alu_scr_sel_1 = 1'b0 ;
		alu_scr_sel_2 = 1'b0 ;
		reg_write     = 1'b0 ;
		mem_read      = 1'b0 ;
		mem_write     = 1'b0 ;
		PC_select     = 2'b00;
		write_from    = 2'b00;
		
	  case(opcode)
	    7'b0110011: begin
	      // ISA_type=r;
	      alu_scr_sel_1 = 1'b1       ;
	      alu_scr_sel_2 = 1'b1       ;
	      func3         = inst[14:12];
	      func7         = inst[31:25];
	      write_from    = 2'b00      ;
	      reg_write     = 1'b1       ;
	      PC_select     = 2'b00      ;
	      case(func3)
	        3'b000:	begin
	          if(func7==7'b0000000) begin
	            alu_op_select = ADD;
	          end else if(func7==7'b0100000) begin
	            alu_op_select = SUB;
	          end else begin
	            alu_op_select = ADD;
	          end
	        end
	        3'b001:	begin
	          if(func7==7'b0000000) begin
	            alu_op_select = SLL;
	          end
	        end
	        3'b010:	begin
	          if(func7==7'b0000000) begin
	            alu_op_select = SLT;
	          end
	        end
	        3'b011:	begin
	          if(func7==7'b0000000) begin
	            alu_op_select = SLTU;
	          end
	        end
	        3'b100:	begin
	          if(func7==7'b0000000) begin
	            alu_op_select = XOR;
	          end
	        end
	        3'b101:	begin
	          if(func7==7'b0000000) begin
	            alu_op_select = SRL;
	          end
	          if(func7==7'b0100000) begin
	            alu_op_select = SRA;
	          end
	        end
	        3'b110:	begin
	          if(func7==7'b0000000) begin
	            alu_op_select = OR;
	          end
	        end
	        3'b111:	begin
	          if(func7==7'b0000000) begin
	            alu_op_select = AND;
	          end
	        end

	        default: begin
	          alu_op_select = ADD;
	        end
	      endcase
	    end
	    7'b0010011:begin
	      // ISA_type=i;
	      // rd=inst[11:7];
	      // rs1=inst[19:14];
	      alu_scr_sel_1 = 1'b1       ;
	      alu_scr_sel_2 = 1'b0       ;
	      reg_write     = 1'b1       ;
	      mem_read      = 1'b0       ;
	      mem_write     = 1'b0       ;
	      func3         = inst[14:12];
	      imm           = inst[31:20];
	      write_from    = 2'b00      ;
	      PC_select     = 2'b00      ;
	      case(func3)
	        3'b000:	begin
	          alu_op_select = ADD;
	        end
	        3'b001:	begin
	          if(imm[11:5]==7'b0000000) begin
	            alu_op_select = SLL;
	          end
	        end
	        3'b010:	begin
	          alu_op_select = SLT;
	        end
	        3'b011:	begin
	          alu_op_select = SLTU;
	        end
	        3'b100:	begin
	          alu_op_select = XOR;
	        end
	        3'b101:	begin
	          if(imm[11:5]==7'b0000000) begin
	            alu_op_select = SRL;
	          end
	          if(imm[11:5]==7'b0100000) begin
	            alu_op_select = SRA;
	          end
	        end
	        3'b110:	begin
	          alu_op_select = OR;
	        end
	        3'b111:	begin
	          alu_op_select = AND;
	        end
	        default: alu_op_select = ADD;
	      endcase
	    end
	    7'b0000011: begin
	      //ISA_type => Load
	      alu_op_select = ADD  ;
	      alu_scr_sel_1 = 1'b1 ;
	      alu_scr_sel_2 = 1'b0 ;
	      mem_read      = 1'b1 ;
	      mem_write     = 1'b0 ;
	      reg_write     = 1'b1 ;
	      write_from    = 2'b01;
	      PC_select     = 2'b00;
	    end
	    7'b0100011: begin
	      // ISA_type=s;
	      func3         = inst[14:12];
	      // rs1=inst[19:15];
	      // rs2=inst[24:20]
	      imm[4:0]      = inst[11:7] ;
	      imm[11:5]     = inst[31:25];
	      alu_op_select = ADD        ;
	      PC_select     = 2'b00      ;
	      write_from    = 2'b00      ;
	      reg_write     = 1'b0       ;
	      mem_write     = 1'b1       ;
				
	    end
	      // 7'b0110111:ISA_type=u;
	      // 7'b0010111:ISA_type=u;
	    7'b1100011:begin
	      // ISA_type=Branch;
	      func3         = inst[14:12];
	      // rs1=inst[19:15];
	      // rs2=inst[24:20];
	      alu_scr_sel_1 = 1'b1       ;
	      alu_scr_sel_2 = 1'b1       ;
	      mem_read      = 1'b0       ;
	      mem_write     = 1'b0       ;
	      reg_write     = 1'b0       ;
	      imm[4:0]      = inst[11:7] ; // here 7 bit is not considered.
	      imm[11:5]     = inst[31:25]; // here 31 bit is not considered.
	      case (func3)
	        3'b000: begin
	          alu_op_select = EQ;
	          if(zeros==1'b0) begin
	            PC_select = 2'b00;
	          end
	          if(zeros==1'b1) begin
	            PC_select = 2'b01;
	          end
	        end
	        3'b001: begin alu_op_select = NE                   ;
	          PC_select                   = !zeros ? 2'b00: 2'b01;
	        end
	        3'b100: begin	alu_op_select = LT                    ;
	          PC_select                   = flag_lt ? 2'b00: 2'b01;
	        end
	        3'b101: begin alu_op_select = GE                     ;
	          PC_select                   = !flag_lt ? 2'b00: 2'b01;
	        end
	        3'b110: begin alu_op_select = LTU                    ;
	          PC_select                   = flag_ltu ? 2'b00: 2'b01;
	        end
	        3'b111: begin	alu_op_select = GEU                     ;
	          PC_select                   = !flag_ltu ? 2'b00: 2'b01;
	        end
	        default:begin alu_op_select = ADD  ;
	          PC_select                   = 2'b00;
	        end
	      endcase

	    end
	    7'b1101111:begin
	      // rd=inst[11:7];
	      alu_scr_sel_1 = 1'b0 ;
	      alu_scr_sel_2 = 1'b0 ;
	      mem_read      = 1'b0 ;
	      mem_write     = 1'b0 ;
	      reg_write     = 1'b1 ;
	      alu_op_select = ADD  ;
	      PC_select     = 2'b00;
	      write_from    = 2'b10;
	      //for JAL
	    end
	    7'b1100111:begin
	      // FOr JALR
	      alu_op_select = ADD  ;
	      alu_scr_sel_1 = 1'b1 ;
	      alu_scr_sel_2 = 1'b0 ;
	      mem_read      = 1'b0 ;
	      mem_write     = 1'b0 ;
	      reg_write     = 1'b1 ;
	      PC_select     = 2'b10;
	      write_from    = 2'b10;
	    end
	    default:begin
	      alu_op_select = ADD  ;
	      alu_scr_sel_1 = 1'b0 ;
	      alu_scr_sel_2 = 1'b0 ;
	      mem_read      = 1'b0 ;
	      mem_write     = 1'b0 ;
	      reg_write     = 1'b0 ;
	      PC_select     = 2'b00;
	      write_from    = 2'b00;
	    end
	  endcase
	end
endmodule
