module register_PC (
    input  logic        clock,
    input  logic        reset,
    input  logic [31:0] pc_next,
    output logic [31:0] pc
);
  always_ff @(posedge clock or negedge reset) begin
    if (!reset) begin
      pc <= 32'd0;
    end else begin
      pc <= pc_next;
    end
  end
endmodule

module mux41_pc (
    input  logic [31:0] i1,
    input  logic [31:0] i2,
    input  logic [31:0] i3,
    input  logic [ 1:0] PC_select,
    output logic [31:0] o1
);

  always_comb begin
    case (PC_select)
      2'b00:   o1 = i1;
      2'b01:   o1 = i2;
      2'b10:   o1 = i3;
      default: o1 = i1;
    endcase
  end

endmodule

module fetch_block (
    input  logic        clock,
    input  logic        reset,
    input  logic [31:0] offset,
    input  logic [31:0] reg_val,
    input  logic [ 1:0] PC_select,
    output logic [31:0] pc_4,
    output logic [31:0] pc
);
  logic [31:0] pc__4;
  assign pc__4 = pc + 32'd4;
  assign pc_4  = pc__4;
  logic [31:0] pc_imm;
  assign pc_imm = pc + offset;
  logic [31:0] pc_reg1;
  assign pc_reg1 = (offset + reg_val) & 32'b1111_1111_1111_1111_1111_1111_1111_1110;
  logic [31:0] pc_value;

  mux41_pc mux (
      .i1(pc__4),
      .i2(pc_imm),
      .i3(pc_reg1),
      .PC_select(PC_select),
      .o1(pc_value)
  );

  register_PC PC (
      .clock  (clock),
      .reset  (reset),
      .pc_next(pc_value),
      .pc     (pc)
  );

endmodule
