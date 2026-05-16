module inst_mem (
    input  logic [31:0] PC,   //pc
    output logic [31:0] inst
);


  //assign inst = mem[PC[31:2]];
  int depth = 1024;
  always_comb begin
    if (PC[31:2] < depth) inst = ins_mem[PC[31:2]];
    //     else begin
    //         $fatal("Instruction memory access out of range");
    //         inst = 32'h00000013;
    //     end
  end

endmodule
