//============ Agent ====================
class risc_agent extends uvm_agent;
  `uvm_component_utils(risc_agent)

  risc_sequencer sqr;
  risc_driver    dri;
  risc_monitor   mon;

  function new(string name = "risc_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    sqr = risc_sequencer::type_id::create("sqr", this);
    dri = risc_driver::type_id::create("dri", this);
    mon = risc_monitor::type_id::create("mon", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    dri.seq_item_port.connect(sqr.seq_item_export);
  endfunction
endclass
