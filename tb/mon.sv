//=========== monitor ================
class risc_monitor extends uvm_monitor;
  `uvm_component_utils(risc_monitor)
  virtual risc_intf rc_inf;

  uvm_analysis_port #(data_pkt) mon_port;

  function new(string name = "risc_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    mon_port = new("mon_port", this);
    if (!uvm_config_db#(virtual risc_intf)::get(this, "", "rc_inf", rc_inf))
      `uvm_fatal("MON", "No Virtual Interface is  present [Monitor]")
  endfunction

  task run_phase(uvm_phase phase);
    data_pkt pkt;
    forever
      @(posedge rc_inf.clk) begin
        pkt = data_pkt::type_id::create("pkt");
        pkt.pc = rc_inf.pc;
        pkt.inst = rc_inf.inst;
        pkt.A_value = rc_inf.A_value;
        pkt.B_value = rc_inf.B_value;
        pkt.reg_A_value = rc_inf.reg_A_value;
        pkt.reg_B_value = rc_inf.reg_B_value;
        pkt.offset = rc_inf.offset;
        pkt.z_flag = rc_inf.z_flag;
        pkt.lt_flag = rc_inf.lt_flag;
        pkt.ltu_flag = rc_inf.ltu_flag;
        pkt.alu_result = rc_inf.alu_result;
        pkt.pc_4 = rc_inf.pc_4;
        pkt.reg_write = rc_inf.reg_write;
        pkt.mem_read = rc_inf.mem_read;
        pkt.mem_write = rc_inf.mem_write;
        pkt.alu_select_1 = rc_inf.alu_select_1;
        pkt.alu_select_2 = rc_inf.alu_select_2;
        pkt.pc_select = rc_inf.pc_select;
        pkt.write_from = rc_inf.write_from;
        pkt.write_data = rc_inf.write_data;
        pkt.mem_data = rc_inf.mem_data;
        pkt.alu_opcode = rc_inf.alu_opcode;
        pkt.reset = rc_inf.reset;
        mon_port.write(pkt);
      end
  endtask
endclass
