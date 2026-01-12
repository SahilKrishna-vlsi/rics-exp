module data_mem (
    input  logic        clk,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);
  logic [31:0] mem[0:1023];  // 4 KB

  always_ff @(posedge clk) begin
    if (mem_write) mem[addr[31:2]] <= write_data;
  end

  always_comb begin
    if (mem_read) read_data = mem[addr[31:2]];
    else read_data = 32'b0;
  end
endmodule
