//=============== Test ================
class risc_test extends uvm_test;
  `uvm_component_utils(risc_test)
  risc_envi env;
  risc_sequence seq;

  function new(string name = "risc_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    env = risc_envi::type_id::create("env", this);
    seq = risc_sequence::type_id::create("seq");
  endfunction

  task run_phase(uvm_phase phase);
    phase.raise_objection(this);
    seq.start(env.ag.sqr);
    phase.drop_objection(this);
  endtask
endclass
