module registers (
    input logic clock,
    input logic [4:0] write_port,
    input logic [31:0] write_data,
    input logic write_enable,
    input logic [4:0] read_port1,
    input logic [4:0] read_port2,
    output logic [31:0] read_data1,
    output logic [31:0] read_data2
);
  reg [31:0] register[31:0];
  // assign register[0] = 32'd0;
  always_comb begin
    read_data1 = register[read_port1];
    read_data2 = register[read_port2];
    if (read_port1 == 5'b0) read_data1 = 32'b0;
    if (read_port2 == 5'b0) read_data2 = 32'b0;
  end
  // assign read_data1 = register[read_port1];
  // assign read_data2 = register[read_port2];
  always_ff @(posedge clock) begin
    if (write_enable) begin
      if (write_port) register[write_port] <= write_data;
      // if (write_port == 5'b0) register[write_port] <= 32'b0;
    end
  end

endmodule
