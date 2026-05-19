module registers (
    input logic clock,
    input logic reset,
    input logic [4:0] write_port,
    input logic signed [31:0] write_data,
    input logic write_enable,
    input logic [4:0] read_port1,
    input logic [4:0] read_port2,
    output logic signed [31:0] read_data1,
    output logic signed [31:0] read_data2
);

  always_comb begin
    read_data1 = register[read_port1];
    read_data2 = register[read_port2];
    if (read_port1 == 5'b0) read_data1 = 32'b0;
    if (read_port2 == 5'b0) read_data2 = 32'b0;
  end
  always_ff @(posedge clock or negedge reset) begin
    if (~reset) begin
      for (int i = 0; i < 32; i++) begin
        register[i] <= 32'b0;
      end
    end
    if (write_enable && write_port != 5'b0) begin
      if (write_port) register[write_port] <= write_data;
    end
  end
endmodule
