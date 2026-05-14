//========= driver==============
class risc_driver extends uvm_driver #(risc_pkt);
  `uvm_component_utils(risc_driver)
  virtual risc_intf rc_inf;
  int i = 0;

  function new(string name = "risc_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual risc_intf)::get(this, "", "rc_inf", rc_inf))
      `uvm_fatal("DRI", "No Virtual Interface is present [Driver]")
  endfunction

  task run_phase(uvm_phase phase);
    risc_pkt data_pkt;

    forever begin
      seq_item_port.get_next_item(data_pkt);
      drive(data_pkt);
      seq_item_port.item_done();
    end

  endtask

  task drive(risc_pkt pkt);
    //         `uvm_info("dri",$sformatf("opcode: %h,%h,%h,%h,%h,%h",pkt.func7,pkt.B,pkt.A,pkt.func3,pkt.rd,pkt.opcode),UVM_LOW)
    if (pkt != null) begin
      //             `uvm_info("dri","inside the if",UVM_LOW)
      case (pkt.opcode)
        7'h3: mem[i] = {pkt.i_imm, pkt.A, pkt.func3, pkt.rd, pkt.opcode};  //load
        7'h13: mem[i] = {pkt.i_imm, pkt.A, pkt.func3, pkt.rd, pkt.opcode};  //immediate
        7'h23:
        mem[i] = {pkt.i_imm[11:5], pkt.B, pkt.A, pkt.func3, pkt.i_imm[4:0], pkt.opcode};  //store
        7'h33: mem[i] = {pkt.func7, pkt.B, pkt.A, pkt.func3, pkt.rd, pkt.opcode};  //register
        // 			8'h63	: mem [i] = {pkt.i_imm[1],pkt.i_imm[10:5],pkt.B,pkt.A,pkt.func3,pkt.i_imm[4:1],pkt.i_imm[11],pkt.opcode}; //branch
        // 			8'h6F	: mem [i] = {pkt.u_imm[20],pkt.u_imm[10:1],pkt.u_imm[11],pkt.u_imm[19:12],pkt.rd,pkt.opcode}; //jal								
        // 			8'h67	: mem [i] = {pkt.i_imm,pkt.A,pkt.func3,pkt.rd,pkt.opcode}; //jalr					
      endcase
      //               `uvm_info("dri",$sformatf("mem %d = %h",i,mem[i]),UVM_LOW)
      rc_inf.load_instruction(i, mem[i]);
      i = i + 1;

    end
  endtask
endclass
