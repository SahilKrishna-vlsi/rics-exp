class risc_sequence extends uvm_sequence #(risc_pkt);
  `uvm_object_utils(risc_sequence)
  int n = 499;
  int i = 0;
  function new(string name = "risc_sequence");
    super.new(name);
  endfunction

  task body();
    risc_pkt pkt;
    repeat (n) begin
      pkt   = risc_pkt::type_id::create("pkt");
      pkt.i = i;
      start_item(pkt);
      pkt.randomize();
      finish_item(pkt);
      i = i + 1;
    end
  endtask
endclass
