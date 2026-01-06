module alu_tb ();
  logic [31:0] A;
  logic [31:0] B;
  operator_t op;


  logic [31:0] result;
  logic ltu;
  logic lt;
  logic z;

  alu dut (
      .A(A),
      .B(B),
      .opcode(op),
      .result(result),
      .ltu(ltu),
      .lt(lt),
      .zeros(z)
  );

  initial begin
    #0;
    $dumpfile("sim/alu_wave.vcd");
    $dumpvars(0, alu_tb);
    A  = 32'd10;
    B  = 32'd20;
    op = ADD;
    #1;
    $display("%d - result; %d - zeros; %d - lt; %d - ltu;  %t -$time", result, z, lt, ltu, $time);
    #10;
    A  = 32'd20;
    B  = 32'd10;
    op = SUB;
    #1;
    $display("%d - result; %d - zeros; %d - lt; %d - ltu;  %t -$time", result, z, lt, ltu, $time);
    #10;
    A  = 32'hA5A5_A5A5;
    B  = 32'h0F0F_0F0F;
    op = XOR;
    #1;
    $display("%d - result; %d - zeros; %d - lt; %d - ltu;  %t -$time", result, z, lt, ltu, $time);
    #10;
    A  = 32'hA5A5_A5A5;
    B  = 32'h0F0F_0F0F;
    op = OR;
    #1;
    $display("%d - result; %d - zeros; %d - lt; %d - ltu;  %t -$time", result, z, lt, ltu, $time);
    #10;
    A  = 32'hA5A5_A5A5;
    B  = 32'h0F0F_0F0F;
    op = AND;
    #1;
    $display("%d - result; %d - zeros; %d - lt; %d - ltu;  %t -$time", result, z, lt, ltu, $time);
    #10;
    A  = 32'h0000_0001;
    B  = 32'd4;
    op = SLL;
    #1;
    $display("%d - result; %d - zeros; %d - lt; %d - ltu;  %t -$time", result, z, lt, ltu, $time);
    #10;
    A  = 32'h8000_0000;
    B  = 32'd1;
    op = SRL;
    #1;
    $display("%d - result; %d - zeros; %d - lt; %d - ltu;  %t -$time", result, z, lt, ltu, $time);
    #10;
    A  = 32'hFFFF_FFF8;  // -8
    B  = 32'd2;
    op = SRA;
    #1;
    $display("%d - result; %d - zeros; %d - lt; %d - ltu;  %t -$time", result, z, lt, ltu, $time);
    #10;
    A  = 32'hFFFF_FFFF;
    B  = 32'h0000_0001;
    op = SLT;
    #1;
    $display("%d - result; %d - zeros; %d - lt; %d - ltu;  %t -$time", result, z, lt, ltu, $time);
    #10;
    A  = 32'hFFFF_FFFF;
    B  = 32'h0000_0001;
    op = SLTU;
    #1;
    $display("%d - result; %d - zeros; %d - lt; %d - ltu;  %t -$time", result, z, lt, ltu, $time);
    #10;
    A  = 32'd1;
    B  = 32'd1;
    op = EQ;
    #1;
    $display("%d - result; %d - zeros; %d - lt; %d - ltu;  %t -$time", result, z, lt, ltu, $time);
    #10;
    A  = 32'd1;
    B  = 32'd2;
    op = NE;
    #1;
    $display("%d - result; %d - zeros; %d - lt; %d - ltu;  %t -$time", result, z, lt, ltu, $time);
    #10;
    A  = 32'hFFFF_FFFD;
    B  = 32'd2;
    op = LT;
    #1;
    $display("%d - result; %d - zeros; %d - lt; %d - ltu;  %t -$time", result, z, lt, ltu, $time);
    #10;
    A  = 32'd1;
    B  = 32'd2;
    op = LTU;
    #1;
    $display("%d - result; %d - zeros; %d - lt; %d - ltu;  %t -$time", result, z, lt, ltu, $time);
    #10;
    A  = 32'd2;
    B  = 32'hFFFF_FFFD;
    op = GE;
    #1;
    $display("%d - result; %d - zeros; %d - lt; %d - ltu;  %t -$time", result, z, lt, ltu, $time);
    #10;
    A  = 32'd2;
    B  = 32'hFFFF_FFFD;
    op = GEU;
    #1;
    $display("%d - result; %d - zeros; %d - lt; %d - ltu;  %t -$time", result, z, lt, ltu, $time);
    #10;
    A  = 32'd2;
    B  = 32'hFFFF_FFFD;
    op = ADD;
    #1;
    $display("%d - result; %d - zeros; %d - lt; %d - ltu;  %t -$time", result, z, lt, ltu, $time);
    #10;
    $finish;
  end


endmodule
