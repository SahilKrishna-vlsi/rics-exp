//========= sequencer ============
class risc_sequencer extends uvm_sequencer #(risc_pkt);
  `uvm_component_utils(risc_sequencer)
  function new(string name = "risc_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction
endclass
