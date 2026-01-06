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
module alu (
    input operator_t opcode,
    input logic [31:0] A,
    input logic [31:0] B,

    output logic [31:0] result,
    output logic zeros,
    output logic ltu,
    output logic lt
);

  // logic [31:0] temp;
  // logic [31:0] mask;
  // logic mag;
  //   assign result = 31'bx;
  //   assign zeros = 1'b0;
  //   assign ltu = 1'b0;
  //   assign lt = 1'b0;
  always_comb begin
    case (opcode)
      ADD: begin  //addition
        result = A + B;
        zeros = 1'b0;
        ltu = 1'b0;
        lt = 1'b0;
      end
      SUB: begin  //subtraction
        result = A - B;
        zeros = 1'b0;
        ltu = 1'b0;
        lt = 1'b0;
      end
      AND: begin
        result = A & B;
        zeros = 1'b0;
        ltu = 1'b0;
        lt = 1'b0;
      end
      OR: begin
        result = A | B;
        zeros = 1'b0;
        ltu = 1'b0;
        lt = 1'b0;
      end
      XOR: begin
        result = A ^ B;
        zeros = 1'b0;
        ltu = 1'b0;
        lt = 1'b0;
      end
      SLL: begin  //signed left shit
        result = A << B[4:0];
        zeros = 1'b0;
        ltu = 1'b0;
        lt = 1'b0;
      end
      SRL: begin  //signed right shit
        result = A >> B[4:0];
        zeros = 1'b0;
        ltu = 1'b0;
        lt = 1'b0;
      end
      SRA: begin  //signed right shift athrimetic
        result = $signed(A) >>> B[4:0];
        zeros = 1'b0;
        ltu = 1'b0;
        lt = 1'b0;
      end
      SLT: begin  // set less than flag
        lt = 1'b0;
        zeros = 1'b0;
        ltu = 1'b0;
        result = {31'b0, ($signed(A) < $signed(B))};
      end
      SLTU: begin  //set unsigned less than flag
        ltu = 1'b0;
        zeros = 1'b0;
        result = (A < B) ? 32'b1 : 32'b0;
        lt = 1'b0;
      end
      EQ: begin  //equals
        zeros = (A == B) ? 1'b1 : 1'b0;
        result = 32'b0;
        ltu = 1'b0;
        lt = 1'b0;
      end
      NE: begin  //not equals
        zeros = (A != B) ? 1'b1 : 1'b0;
        result = 32'b0;
        ltu = 1'b0;
        lt = 1'b0;
      end
      LT: begin  //less than signed
        lt = ($signed(A) < $signed(B));
        zeros = 1'b0;
        ltu = 1'b0;
        result = 32'b0;
      end
      GE: begin  //greater than equals signed
        lt = ~($signed(A) < $signed(B));
        zeros = 1'b0;
        ltu = 1'b0;
        result = 32'b0;
      end
      LTU: begin  //less than unsigned
        ltu = (A < B) ? 1'b1 : 1'b0;
        zeros = 1'b0;
        lt = 1'b0;
        result = 32'b0;
      end
      GEU: begin  //greater than equals unsigned
        ltu = (A >= B) ? 1'b0 : 1'b1;
        zeros = 1'b0;
        result = 32'b0;
        lt = 1'b0;
      end
      default begin
        result = A + B;
        zeros = 1'b0;
        ltu = 1'b0;
        lt = 1'b0;
      end
    endcase
  end

endmodule
