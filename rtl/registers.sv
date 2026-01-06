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
  assign register[0] = 32'd0;
  assign read_data1  = register[read_port1];
  assign read_data2  = register[read_port2];
  always_ff @(posedge clock) begin
    if (write_enable) begin
      if (write_port) register[write_port] = write_data;
    end
  end

endmodule
