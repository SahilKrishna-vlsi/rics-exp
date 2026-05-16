module data_mem (
    input  logic        clk,
    input  logic        mem_read,
    input  logic        mem_write,
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    output logic [31:0] read_data
);
  always_ff @(posedge clk) begin
    if (mem_write) da_mem[addr[31:2]] <= write_data;
  end

  always_comb begin
    if (mem_read) read_data = da_mem[addr[31:2]];
    else read_data = 32'b0;
  end
endmodule
