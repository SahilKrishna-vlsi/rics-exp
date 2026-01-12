module inst_mem (
    input  logic [31:0] PC,   //pc
    output logic [31:0] inst
);
  logic [31:0] mem[0:1023];  // 4 KB = 1024 words

  assign inst = mem[PC[31:2]];

endmodule
