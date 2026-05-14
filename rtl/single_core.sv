import isa_types_pkg::*;
`include "/tb/interface.sv"
logic [31:0] ins_mem[0:1023];  // 4 KB = 1024 words
logic [31:0] da_mem[0:1023];  // 4 KB
reg [31:0] register[31:0];  //   assign register[0] = 32'h0;
module single_core (
    risc_intf rc
);
  fetch_block Fetch (
      .clock    (rc.clk),
      .reset    (rc.reset),
      .offset   (rc.offset),
      .reg_val  (rc.reg_A_value),
      .PC_select(rc.pc_select),
      .pc_4     (rc.pc_4),
      .pc       (rc.pc)
  );
  inst_mem instructions (
      .PC  (rc.pc),
      .inst(rc.inst)
  );
  imm_generator gene_offeset (
      .inst(rc.inst),
      .imm_result(rc.offset)
  );
  control_unit Decode (
      .instruction(rc.inst),
      .zeros(rc.z_flag),
      .flag_ltu(rc.ltu_flag),
      .flag_lt(rc.lt_flag),
      .opcode(rc.alu_opcode),
      .alu_input_1(rc.alu_select_1),
      .alu_input_2(rc.alu_select_2),
      .reg_write(rc.reg_write),
      .mem_read(rc.mem_read),
      .mem_write(rc.mem_write),
      .pc_select(rc.pc_select),
      .write_from(rc.write_from)
  );

  registers reg_file (
      .clock       (rc.clk),
      .reset       (rc.reset),
      .write_port  (rc.inst[11:7]),
      .write_data  (rc.write_data),
      .write_enable(rc.reg_write),
      .read_port1  (rc.inst[19:15]),
      .read_port2  (rc.inst[24:20]),
      .read_data1  (rc.reg_A_value),
      .read_data2  (rc.reg_B_value)
  );


  assign rc.A_value = rc.alu_select_1 ? rc.reg_A_value : rc.pc;
  assign rc.B_value = rc.alu_select_2 ? rc.reg_B_value : rc.offset;


  alu Execute (
      .opcode(rc.alu_opcode),
      .A(rc.A_value),
      .B(rc.B_value),
      .result(rc.alu_result),
      .zeros(rc.z_flag),
      .ltu(rc.ltu_flag),
      .lt(rc.lt_flag)
  );

  assign rc.write_data = (rc.write_from == 2'b00) ? rc.alu_result : (rc.write_from == 2'b01) ? rc.mem_data   :  (rc.write_from == 2'b10) ? rc.pc_4 : 32'b0;

  data_mem data_memory (
      .clk       (rc.clk),
      .mem_read  (rc.mem_read),
      .mem_write (rc.mem_write),
      .addr      (rc.alu_result),
      .write_data(rc.reg_B_value),
      .read_data (rc.mem_data)
  );


endmodule
