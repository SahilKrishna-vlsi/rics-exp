module imm_generator (
    input  logic [31:0] inst,
    output logic [31:0] imm_result
);
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
  always_comb begin
    imm_result = 32'b0;
    case (inst[6:0])

      7'b0010011: begin  //Immediate type
        if (inst[14:12] == 3'b001 || inst[14:12] == 3'b101) imm_result = {27'b0, inst[24:20]};
        else imm_result = {{20{inst[31]}}, inst[31:20]};
      end

      7'b0000011: begin
        imm_result[31:12] = {20{inst[31]}};
        imm_result[11:0]  = inst[31:20];
      end

      7'b0100011: begin  //strore
        imm_result[31:12] = {20{inst[31]}};
        imm_result[11:0]  = {inst[31:25], inst[11:7]};
      end

      7'b1100011: begin
        imm_result[31:13] = {19{inst[31]}};
        imm_result[12:0]  = {inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
      end

      7'b1101111: begin
        imm_result[31:21] = {11{inst[31]}};
        imm_result[20:0]  = {inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
      end

      7'b1100111: begin
        imm_result[31:12] = {20{inst[31]}};
        imm_result[11:0]  = inst[31:20];

      end
      default begin
        imm_result = 32'b0;
      end
    endcase

  end

endmodule
