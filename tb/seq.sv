class risc_sequence extends uvm_sequence #(risc_pkt);
  `uvm_object_utils(risc_sequence)
  int n = 100;
  int i = 0;
  function new(string name = "risc_sequence");
    super.new(name);
  endfunction

  task body();
    risc_pkt pkt;
    repeat (n) begin
      pkt = risc_pkt::type_id::create("pkt");
      start_item(pkt);
      pkt.randomize();  // {opcode inside {7'h3,7'h13,7'h23,7'h33};}
      finish_item(pkt);
    end
  endtask
endclass
