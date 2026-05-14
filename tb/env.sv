//=============== Envi ===================
class risc_envi extends uvm_env;
  `uvm_component_utils(risc_envi)

  risc_scr   scr;
  risc_agent ag;

  function new(string name = "risc_envi", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    ag  = risc_agent::type_id::create("ag", this);
    scr = risc_scr::type_id::create("scr", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);
    ag.mon.mon_port.connect(scr.scr_port);
  endfunction
endclass
