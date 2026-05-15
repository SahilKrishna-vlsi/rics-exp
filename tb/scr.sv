//================ Scoreboard=============
class risc_scr extends uvm_scoreboard;
  `uvm_component_utils(risc_scr)
  data_pkt rsp[$];
  uvm_analysis_imp #(data_pkt, risc_scr) scr_port;
  data_pkt exp;
  data_pkt iop;
  int pass_count;
  int fail_count;
  int j = 100;
  logic [31:0] ref_mem[0:1023];
  reg [31:0] ref_reg[31:0];

  function new(string name = "risc_scr", uvm_component parent = null);
    super.new(name, parent);
    pass_count = 0;
    fail_count = 0;
    pc = 0;
    foreach (ref_mem[i]) ref_mem[i] = i;
    foreach (ref_reg[i]) ref_reg[i] = 0;
    //cvg = new();
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    scr_port = new("scr_port", this);
  endfunction

  function void print_details(data_pkt t);
    `uvm_info("SB_pri", $sformatf("time = %t", $time), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("pc => %h", t.pc), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("inst %h", t.inst), UVM_LOW)
    `uvm_info("SB_pri", $sformatf(" a value %h", t.A_value), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("b value %h", t.B_value), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("reg a value %h", t.reg_A_value), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("reg b value %h", t.reg_B_value), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("offset %h", t.offset), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("zero flag %h", t.z_flag), UVM_LOW)
    `uvm_info("SB_pri", $sformatf(" less than flag %h", t.lt_flag), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("less than or equal to flag %h", t.ltu_flag), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("alu result %h", t.alu_result), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("pc_4 %h", t.pc_4), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("reg wirte %h", t.reg_write), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("mem_read %h", t.mem_read), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("mem_write %h", t.mem_write), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("alu select 1 %h", t.alu_select_1), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("alu select 2 %h", t.alu_select_2), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("pc select %h", t.pc_select), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("mem data %h", t.mem_data), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("alu opcode %s", t.alu_opcode.name), UVM_LOW)
  endfunction
  function void print_detail_exp();
    `uvm_info("SB_pri", "Expected values", UVM_LOW)
    `uvm_info("SB_pri", $sformatf("pc => %h", exp.pc), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("inst %h", exp.inst), UVM_LOW)
    `uvm_info("SB_pri", $sformatf(" a value %h", exp.A_value), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("b value %h", exp.B_value), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("reg a value %h", exp.reg_A_value), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("reg b value %h", exp.reg_B_value), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("offset %h", exp.offset), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("zero flag %h", exp.z_flag), UVM_LOW)
    `uvm_info("SB_pri", $sformatf(" less than flag %h", exp.lt_flag), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("less than or equal to flag %h", exp.ltu_flag), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("alu result %h", exp.alu_result), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("pc_4 %h", exp.pc_4), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("reg wirte %h", exp.reg_write), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("mem_read %h", exp.mem_read), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("mem_write %h", exp.mem_write), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("alu select 1 %h", exp.alu_select_1), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("alu select 2 %h", exp.alu_select_2), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("pc select %h", exp.pc_select), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("mem data %h", exp.mem_data), UVM_LOW)
    `uvm_info("SB_pri", $sformatf("alu opcode %s", exp.alu_opcode.name), UVM_LOW)
  endfunction

  function void compare(data_pkt t);
    case (t.inst[6:0])
      7'b0110011: begin
        if (exp.alu_opcode.name == SLT || exp.alu_opcode.name == SLTU) begin
          if (exp.lt_flag == t.lt_flag && t.alu_opcode.name == SLT) begin
            pass_count++;
            `uvm_info("SB_PASS", "R-Type Instruction passed", UVM_LOW)
          end else if (exp.ltu_flag == t.ltu_flag && t.alu_opcode.name == SLTU) begin
            pass_count++;
            `uvm_info("SB_PASS", "R-Type Instruction passed", UVM_LOW)
          end else begin
            fail_count++;
            `uvm_info("SB_FAIL", "R-Type Instruction failed", UVM_LOW)
            `uvm_info("SB_pri", $sformatf("exp.lt_flag %h", exp.lt_flag), UVM_LOW)
            `uvm_info("SB_pri", $sformatf("t.lt_flag %h", t.lt_flag), UVM_LOW)
            `uvm_info("SB_pri", $sformatf("exp.ltu_flag %h", exp.ltu_flag), UVM_LOW)
            `uvm_info("SB_pri", $sformatf("t.ltu_flag %h", t.ltu_flag), UVM_LOW)
          end
        end
        else if(exp.alu_result == t.alu_result && exp.alu_opcode == t.alu_opcode && ref_reg[exp.inst[11:7]] == register[t.inst[11:7]]) begin
          pass_count++;
          `uvm_info("SB_PASS", "R-Type Instruction passed", UVM_LOW)
        end else begin
          fail_count++;
          `uvm_info("SB_FAIL", "R-Type Instruction failed", UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.alu_result %h", exp.alu_result), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.alu_result %h", t.alu_result), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.alu_opcode %s", exp.alu_opcode.name), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("alu opcode %s", t.alu_opcode.name), UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "register[t.inst[11:7]:%d] %h", t.inst[11:7], register[t.inst[11:7]]), UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "ref_reg[exp.inst[11:7]:%d] %h", exp.inst[11:7], ref_reg[exp.inst[11:7]]),
                    UVM_LOW)
          print_details(t);
          print_detail_exp();
        end
      end
      7'b0010011: begin
        if (exp.alu_opcode.name == SLT || exp.alu_opcode.name == SLTU) begin
          if (exp.lt_flag == t.lt_flag && t.alu_opcode.name == SLT) begin
            pass_count++;
            `uvm_info("SB_PASS", "I-Type Instruction passed", UVM_LOW)
          end else if (exp.ltu_flag == t.ltu_flag && t.alu_opcode.name == SLTU) begin
            pass_count++;
            `uvm_info("SB_PASS", "I-Type Instruction passed", UVM_LOW)
          end else begin
            fail_count++;
            `uvm_info("SB_FAIL", "I-Type Instruction failed", UVM_LOW)
            `uvm_info("SB_pri", $sformatf("exp.lt_flag %h", exp.lt_flag), UVM_LOW)
            `uvm_info("SB_pri", $sformatf("t.lt_flag %h", t.lt_flag), UVM_LOW)
            `uvm_info("SB_pri", $sformatf("exp.ltu_flag %h", exp.ltu_flag), UVM_LOW)
            `uvm_info("SB_pri", $sformatf("t.ltu_flag %h", t.ltu_flag), UVM_LOW)
          end
        end  
      else if(exp.alu_result == t.alu_result && exp.alu_opcode == t.alu_opcode && ref_reg[exp.inst[11:7]] == register[t.inst[11:7]]) begin
          pass_count++;
          `uvm_info("SB_PASS", "I-Type Instruction passed", UVM_LOW)
        end else begin
          fail_count++;
          `uvm_info("SB_FAIL", "I-Type Instruction failed", UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.alu_result %h", exp.alu_result), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.alu_result %h", t.alu_result), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.alu_opcode %s", exp.alu_opcode.name), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("alu opcode %s", t.alu_opcode.name), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.alu_result %h", exp.alu_result), UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "register[t.inst[11:7]:%h] %h", t.inst[11:7], register[t.inst[11:7]]), UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "ref_reg[exp.inst[11:7]:%d] %h", exp.inst[11:7], ref_reg[exp.inst[11:7]]),
                    UVM_LOW)
          print_details(t);
          print_detail_exp();
        end
      end
      7'b0000011: begin
        if (exp.write_data == t.write_data && exp.alu_opcode == t.alu_opcode && da_mem[t.alu_result]==ref_mem[exp.alu_result]) begin
          pass_count++;
          `uvm_info("SB_PASS", "L-Type Instruction passed", UVM_LOW)
        end else begin
          fail_count++;
          `uvm_info("SB_FAIL", "L-Type Instruction failed", UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.write_data %h", exp.write_data), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.write_data %h", t.write_data), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.alu_result %h", exp.alu_result), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.alu_result %h", t.alu_result), UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "da_mem[t.alu_result:%h] %h", t.alu_result, da_mem[t.alu_result]), UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "ref_mem[exp.alu_result:%h] %h", exp.alu_result, ref_mem[exp.alu_result]),
                    UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.alu_opcode %s", exp.alu_opcode.name), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("alu opcode %s", t.alu_opcode.name), UVM_LOW)
          print_details(t);
          print_detail_exp();
        end
      end
      7'b0100011: begin
        if (exp.write_data == t.write_data && da_mem[t.alu_result[31:2]] == ref_mem[exp.alu_result[31:2]]) begin
          pass_count++;
          `uvm_info("SB_PASS", "S-Type Instruction passed", UVM_LOW)
        end else begin
          fail_count++;
          `uvm_info("SB_FAIL", "S-Type Instruction failed", UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.write_data %h", exp.write_data), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t. %h", t.write_data), UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "da_mem[t.alu_result:%h] %h", t.alu_result, da_mem[t.alu_result[31:2]]),
                    UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "ref_mem[exp.alu_result:%h] %h", exp.alu_result, ref_mem[exp.alu_result[31:2]]),
                    UVM_LOW)
          print_details(t);
          print_detail_exp();
        end
      end
      7'h63: begin
        if (exp.pc_select == t.pc_select && exp.pc_4 == t.pc_4) begin
          pass_count++;
          `uvm_info("SB_PASS", "B-Type instruction Passed", UVM_LOW)
        end else begin
          fail_count++;
          `uvm_info("SB_FAIL", "B-Type Instruction Failed", UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.pc_select %d", t.pc_select), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.pc_select %d", exp.pc_select), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.pc_4 %h", t.pc_4), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.pc_4 %h", exp.pc_4), UVM_LOW)
          print_detail_exp();
          print_details(t);
        end
      end
    endcase
  endfunction

  function void predictor(logic [31:0] inst);
    case (inst[6:0])
      7'b0110011: begin
        exp.reg_write = 1'b1;
        exp.alu_select_1 = 1'b1;
        exp.alu_select_2 = 1'b1;
        exp.pc_select = 2'b01;
        case (inst[14:12])
          3'b000: exp.alu_opcode = (inst[31:25] == 7'b0000000) ? ADD : SUB;
          3'b001: exp.alu_opcode = (inst[31:25] == 7'b0000000) ? SLL : ADD;
          3'b010: exp.alu_opcode = (inst[31:25] == 7'b0000000) ? SLT : ADD;
          3'b011: exp.alu_opcode = (inst[31:25] == 7'b0000000) ? SLTU : ADD;
          3'b100: exp.alu_opcode = (inst[31:25] == 7'b0000000) ? XOR : ADD;
          3'b101: exp.alu_opcode = (inst[31:25] == 7'b0000000) ? SRL : SRA;
          3'b110: exp.alu_opcode = (inst[31:25] == 7'b0000000) ? OR : ADD;
          3'b111: exp.alu_opcode = (inst[31:25] == 7'b0000000) ? AND : ADD;
        endcase
        case (exp.alu_opcode)
          ADD: exp.alu_result = register[inst[19:15]] + register[inst[24:20]];
          SUB: exp.alu_result = register[inst[19:15]] - register[inst[24:20]];
          SLL: exp.alu_result = register[inst[19:15]] << register[inst[24:20]][4:0];
          SLT: begin
            exp.lt_flag = ($signed(register[inst[19:15]]) < $signed(register[inst[24:20]]));
            exp.z_flag = 1'b0;
            exp.ltu_flag = 1'b0;
            exp.alu_result = 32'b0;
          end
          SLTU: begin
            exp.lt_flag = (register[inst[19:15]] < register[inst[24:20]]);
            exp.z_flag = 1'b0;
            exp.ltu_flag = 1'b0;
            exp.alu_result = 32'b0;
          end
          XOR: exp.alu_result = register[inst[19:15]] ^ register[inst[24:20]];
          SRL: exp.alu_result = register[inst[19:15]] >> register[inst[24:20]][4:0];
          OR:  exp.alu_result = register[inst[19:15]] | register[inst[24:20]];
          SRA: exp.alu_result = $signed(register[inst[19:15]]) >>> register[inst[24:20]][4:0];
          AND: exp.alu_result = register[inst[19:15]] & register[inst[24:20]];
        endcase
        if (inst[11:7] != 0) ref_reg[inst[11:7]] = exp.alu_result;
        else ref_reg[0] = 0;
      end
      7'b0010011: begin
        exp.reg_write = 1'b1;
        exp.alu_select_1 = 1'b1;
        exp.alu_select_2 = 1'b0;
        exp.pc_select = 2'b01;
        if (inst[14:12] == 3'b001 || inst[14:12] == 3'b101) exp.offset = {27'b0, inst[24:20]};
        else exp.offset = {{20{inst[31]}}, inst[31:20]};
        case (inst[14:12])
          3'b000: exp.alu_opcode = ADD;
          3'b001: exp.alu_opcode = SLL;
          3'b010: exp.alu_opcode = SLT;
          3'b011: exp.alu_opcode = SLTU;
          3'b100: exp.alu_opcode = XOR;
          3'b101: exp.alu_opcode = (inst[30]) ? SRA : SRL;
          3'b110: exp.alu_opcode = OR;
          3'b111: exp.alu_opcode = AND;
        endcase
        case (exp.alu_opcode)
          ADD: exp.alu_result = register[inst[19:15]] + exp.offset;
          SUB: exp.alu_result = register[inst[19:15]] - exp.offset;
          SLL: exp.alu_result = register[inst[19:15]] << exp.offset[4:0];
          SLT: begin
            exp.lt_flag = ($signed(register[inst[19:15]]) < $signed(register[inst[24:20]]));
            exp.z_flag = 1'b0;
            exp.ltu_flag = 1'b0;
            exp.alu_result = 32'b0;
          end
          SLTU: begin
            exp.lt_flag = (register[inst[19:15]] < register[inst[24:20]]);
            exp.z_flag = 1'b0;
            exp.ltu_flag = 1'b0;
            exp.alu_result = 32'b0;
          end
          XOR: exp.alu_result = register[inst[19:15]] ^ exp.offset;
          SRL: exp.alu_result = register[inst[19:15]] >> exp.offset[4:0];
          OR:  exp.alu_result = register[inst[19:15]] | exp.offset;
          SRA: exp.alu_result = $signed(register[inst[19:15]]) >>> exp.offset[4:0];
          AND: exp.alu_result = register[inst[19:15]] & exp.offset;
        endcase
        if (inst[11:7] != 0) ref_reg[inst[11:7]] = exp.alu_result;
        else ref_reg[0] = 0;
      end
      7'b0000011: begin
        exp.alu_select_1 = 1'b1;
        exp.alu_select_2 = 1'b0;
        exp.alu_opcode = ADD;
        exp.mem_read = 1'b1;
        exp.reg_write = 1'b1;
        exp.write_from = 2'b01;
        exp.pc_select = 2'b01;
        exp.offset[31:12] = {20{inst[31]}};
        exp.offset[11:0] = inst[31:20];
        exp.alu_result = register[inst[19:15]] + exp.offset;
        exp.write_data = ref_mem[exp.alu_result[31:2]];
        if (inst[11:7] != 0) ref_reg[inst[11:7]] = exp.write_data;
        else ref_reg[0] = 0;
        //         ref_reg[inst[11:7]] = exp.write_data;
      end
      7'b0100011: begin
        exp.alu_select_1 = 1'b1;
        exp.alu_select_2 = 1'b0;
        exp.offset[31:12] = {20{inst[31]}};
        exp.offset[11:0] = {inst[31:25], inst[11:7]};
        exp.alu_opcode = ADD;
        exp.pc_select = 2'b01;
        exp.mem_write = 1'b1;
        exp.alu_result = register[inst[19:15]] + exp.offset;
        exp.reg_B_value = register[inst[24:20]];
        exp.write_data = exp.alu_result;
        ref_mem[exp.alu_result[31:2]] = exp.reg_B_value;
      end
      7'h63: begin
        exp.alu_select_1 = 1;
        exp.alu_select_2 = 1;
        exp.offset = {inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
        exp.reg_A_value = ref_reg[exp.inst[19:15]];
        exp.reg_B_value = ref_reg[exp.inst[24:20]];
        // exp.pc_select = 1;
        case (inst[14:12])
          3'b000: begin
            exp.alu_opcode = EQ;
            exp.z_flag = (exp.reg_A_value == exp.reg_B_value) ? 1'b1 : 1'b0;
            // if (exp.z_flag) exp.pc_4 = exp.pc + exp.offset;
            exp.pc_select = exp.z_flag ? 2'b01 : 2'b00;
          end

          3'b001: begin
            exp.alu_opcode = NE;
            exp.z_flag = (exp.reg_A_value != exp.reg_B_value) ? 1'b0 : 1'b1;
            // if (!exp.z_flag) exp.pc_4 = exp.pc + exp.offset;
            exp.pc_select = !exp.z_flag ? 2'b01 : 2'b00;
          end

          3'b100: begin
            exp.alu_opcode = LT;
            exp.lt_flag = ($signed(exp.reg_A_value) < $signed(exp.reg_B_value)) ? 1'b1 : 1'b0;
            // if (exp.lt_flag) exp.pc_4 = exp.pc + exp.offset;
            exp.pc_select = exp.lt_flag ? 2'b01 : 2'b00;
          end

          3'b101: begin
            exp.alu_opcode = GE;
            exp.lt_flag = ($signed(exp.reg_A_value) >= $signed(exp.reg_B_value)) ? 1'b0 : 1'b1;
            // if (!exp.lt_flag) exp.pc_4 = exp.pc + exp.offset;
            exp.pc_select = !exp.lt_flag ? 2'b01 : 2'b00;
          end

          3'b110: begin
            exp.alu_opcode = LTU;
            exp.ltu_flag   = (exp.reg_A_value < exp.reg_B_value) ? 1'b1 : 1'b0;
            // if (exp.ltu_flag) exp.pc_4 = exp.pc + exp.offset;
            exp.pc_select  = exp.ltu_flag ? 2'b01 : 2'b00;
          end

          3'b111: begin
            exp.alu_opcode = GEU;
            exp.ltu_flag   = (exp.reg_A_value >= exp.reg_B_value) ? 1'b0 : 1'b1;
            // if (!exp.ltu_flag) exp.pc_4 = exp.pc + exp.offset;
            exp.pc_select  = !exp.ltu_flag ? 2'b01 : 2'b00;
          end

        endcase
        if (exp.pc_select) exp.pc_4 = exp.pc + exp.offset;
        else exp.pc_4 = exp.pc + 32'd4;
      end
      default: begin
        exp.alu_opcode   = ADD;
        exp.alu_select_1 = 1'b1;
        exp.alu_select_2 = 1'b1;
        exp.alu_result   = register[inst[19:15]] + register[inst[24:20]];
      end
    endcase
  endfunction

  function void write(data_pkt t);
    rsp.push_back(t);
  endfunction

  task run_phase(uvm_phase phase);
    // pc = 0;
    forever begin
      if (j == 0) break;
      wait (rsp.size() > 0) exp = data_pkt::type_id::create("exp");
      iop = data_pkt::type_id::create("iop");
      iop = rsp.pop_front();
      if (!iop.reset) begin
        `uvm_info("cont", "Need to compare reg and PC to zeros here", UVM_LOW)
      end else begin
        exp.pc   = iop.pc;
        exp.inst = mem[iop.pc/4];
        predictor(iop.inst);
        #1 compare(iop);
      end
      j--;
    end
  endtask

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("sb", $sformatf("pass count %d", pass_count), UVM_LOW)
    `uvm_info("sb", $sformatf("fail count %d", fail_count), UVM_LOW)
  endfunction
endclass
