// typedef enum logic [1:0]{
// 	r, //7'b0110011
// 	i, //7'b0000011 or 0000011  
// 	s, //7'b0100011
// 	u, //7'b0110111 or 0010111
// 	b, //7'b1100011
// 	j  //7'b1101111 or 1100111
// }isa;
typedef enum logic []{
	ADD,
	SUB,
}operator;
module control_unit(
	input inst[31:0];
	input clock;
	output operator alu_op_select;
);
	reg opcode[6:0];
	assign opcode = instruction[6:0];
	//isa ISA_type[1:0];
	reg rd[5:0];
	reg rs1[5:0];
	reg rs2[5:0];
	reg func3[2:0];
	reg func7[6:0];
	reg func[9:0];
	/*
		With the help of first 6 bits of instruction should be able to tell the type of instruction.
		The upcoming the func3 12-14 and func7 25-31 tells about the operation that should be performed by ALU .
	**/  
	always@(posedge clock) begin
		case(opcode)
			7'b0110011: begin
				// ISA_type=r;
				rd<=inst[11:7];
				rs1<=inst[19:14];
				rs2<=inst[24:20];
				func3<=inst[14:12];
				func7<=inst[31:25];
				case(func3)
					3'b000:	begin
						if(func7==7'b0000000)
							alu_op_select<=ADD;
						else if(func7==7'b0000000)
							alu_op_select<=SUB;
						else
							alu_op_select;
					end
					3'b001:	begin
						if(func7==7'b0000000)
							alu_op_select<=SLL;
					end
					3'b010:	begin
						if(func7==7'b0000000)
							alu_op_select<=SLT;
					end
					3'b011:	begin
						if(func7==7'b0000000)
							alu_op_select<=SLTU;
					end
					3'b100:	begin
						if(func7==7'b0000000)
							alu_op_select<=XOR;
					end
					3'b101:	begin
						if(func7==7'b0000000)
							alu_op_select<=SRL;
						if(func7==7'b0100000)
							alu_op_select<=SRA;
					end
					3'b110:	begin
						if(func7==7'b0000000)
							alu_op_select<=OR;
					end
					3'b111:	begin
						if(func7==7'b0000000)
							alu_op_select<=AND;
					end
				endcase
			end
			7'b0010011:begin
				// ISA_type=i;
				rd<=inst[11:7];
				rs1<=inst[19:14];
				func3<=inst[14:12];
				imm<=inst[31:20];
				case(func3)
					3'b000:	begin
						alu_op_select<=ADDI;
					end
					3'b001:	begin
						if(imm[11:5]==7'b0000000)
							alu_op_select<=SLLI;
					end
					3'b010:	begin
							alu_op_select<=SLTI;
					end
					3'b011:	begin
							alu_op_select<=SLTIU;
					end
					3'b100:	begin
							alu_op_select<=XORI;
					end
					3'b101:	begin						
						if(imm[11:5]==7'b0000000)
							alu_op_select<=SRLI;
						if(imm[11:5]==7'b0100000)
							alu_op_select<=SRAI;
					end
					3'b110:	begin
							alu_op_select<=ORI;
					end
					3'b111:	begin
							alu_op_select<=ANDI;
					end
				endcase
			end
			7'b0000011: begin //ISA_type => Load

				case (func3)
					3'b000:
					3'b001:
					3'b010:
					3'b100:
					3'b101:					
					default: begin
						default_case
					end
				endcase
			end
			7'b0100011: begin
				// ISA_type=s;
				func3<=[14:12];
				rs1<=inst[19:15];
				rs2<=inst[24:20]
				imm[4:0]<=inst[11:7];
				imm[11:5]<=inst[31:25];
				case (func3)
					3'b000: alu_op_select<=SB;
					3'b001: alu_op_select<=SH;
					3'b010:	alu_op_select<=SW;
					default: begin
						default_case
					end
				endcase

			end
			// 7'b0110111:ISA_type=u;
			// 7'b0010111:ISA_type=u;
			7'b1100011:begin
				// ISA_type=Branch;
				func3<=[14:12];
				rs1<=inst[19:15];
				rs2<=inst[24:20]
				imm[4:0]<=inst[11:7]; // here 7 bit is not considered.
				imm[11:5]<=inst[31:25]; // here 31 bit is not considered.
				case (func3)
					3'b000: alu_op_select<=BEQ;
					3'b001: alu_op_select<=BNQ;
					3'b100:	alu_op_select<=BLT;
					3'b101: alu_op_select<=BGE;
					3'b110: alu_op_select<=BLTU;
					3'b111:	alu_op_select<=BGEU;
					default: begin
						default_case
					end
				endcase

			end
			7'b1101111:begin
				rd<=inst[11:7];

				//for JAL
			end
			7'b1100111:begin
				// FOr JALR
			end
			default: ;
		endcase
	end
endmodule
