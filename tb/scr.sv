//================ Scoreboard=============
class risc_scr extends uvm_scoreboard;
  `uvm_component_utils(risc_scr)
  data_pkt rsp[$];
  uvm_analysis_imp #(data_pkt, risc_scr) scr_port;
  data_pkt exp;
  data_pkt iop;
  int pass_count;
  int fail_count;
  bit pass_fail;
  int j = 1023;
  logic [31:0] pc;
  logic [31:0] ref_mem[0:1023];
  reg [31:0] ref_reg[31:0];
  int visited[0:1023];

  covergroup riscv_cg with function sample (data_pkt pkt);
    option.per_instance = 1;
    option.name = "riscv";

    opcode_cp: coverpoint pkt.inst[6:0] {
      bins R_TYPE = {7'b0110011};
      bins I_TYPE = {7'b0010011};
      bins LOAD = {7'b0000011};
      bins STORE = {7'b0100011};
      bins BRANCH = {7'b1100011};
      bins JAL = {7'b1101111};
      bins JALR = {7'b1100111};
    }
    funct3_cp: coverpoint pkt.inst[14:12] {
      bins zero = {0};
      bins one = {1};
      bins two = {2};
      bins three = {3};
      bins four = {4};
      bins five = {5};
      bins six = {6};
      bins seven = {7};
    }
    funct7_cp: coverpoint pkt.inst[31:25] {
      bins zero = {0};
      bins other_value = {32};
      bins all_values_low = {1, 31};
      bins all_high = {33, 64};
    }
    alu_opcode_cp: coverpoint pkt.alu_opcode {
      bins add = {ADD};
      bins sub = {SUB};
      bins And = {AND};
      bins Or = {OR};
      bins Xor = {XOR};
      bins sll = {SLL};
      bins srl = {SRL};
      bins sra = {SRA};
      bins slt = {SLT};
      bins sltu = {SLTU};
      bins eq = {EQ};
      bins ne = {NE};
      bins lt = {LT};
      bins ge = {GE};
      bins ltu = {LTU};
      bins geu = {GEU};
    }
  //     rs1_cp: coverpoint pkt.inst[19:15] {bins zero_reg = {0}; bins all_regs[] = {[1 : 31]};}
  //     rs2_cp: coverpoint pkt.inst[24:20] {bins zero_reg = {0}; bins all_regs[] = {[1 : 31]};}
  //     rd_cp: coverpoint pkt.inst[11:7] {bins zero_reg = {0}; bins all_regs[] = {[1 : 31]};}
  //     mem_read_cp: coverpoint pkt.mem_read {bins read = {1};}
  //     reg_write_cp: coverpoint pkt.reg_write {bins read = {0}; bins write = {1};}
  //     mem_write_cp: coverpoint pkt.mem_write {bins write = {1};}
  //     write_from_cp: coverpoint pkt.write_from {
  //       bins alu_wb = {2'b00}; bins mem_wb = {2'b01}; bins pc4_wb = {2'b10};
  //     }
  //     pc_select_cp: coverpoint pkt.pc_select {
  //       bins pc_plus4 = {0}; bins branch_pc = {1}; bins jump_pc = {2};
  //     }
  //     zero_flag_cp: coverpoint pkt.z_flag {bins zero_set = {1}; bins zero_clear = {0};}
  //     lt_flag_cp: coverpoint pkt.lt_flag {bins less = {1}; bins not_less = {0};}
  //     ltu_flag_cp: coverpoint pkt.ltu_flag {bins less_u = {1}; bins not_less_u = {0};}
  //     imm_cp: coverpoint pkt.offset {
  //       bins zero = {0}; bins small_pos = {[1 : 15]}; bins large_pos = {[16 : 2047]};
  //     }
  //     opcode_x_writeback : cross opcode_cp, write_from_cp;
  //     opcode_x_mem : cross opcode_cp, mem_read_cp, mem_write_cp;
  //     opcode_x_reg : cross opcode_cp, reg_write_cp;
  //     opcode_x_pcselect : cross opcode_cp, pc_select_cp;
  //     opcode_x_alu : cross opcode_cp, alu_opcode_cp;
  endgroup

  function new(string name = "risc_scr", uvm_component parent = null);
    super.new(name, parent);
    pass_count = 0;
    fail_count = 0;
    riscv_cg   = new();
    foreach (ref_mem[i]) ref_mem[i] = i;
    foreach (ref_reg[i]) begin
      if (i < 9) ref_reg[i] = register[i];
      else ref_reg[i] = 0;
      //       `uvm_info("cont",$sformatf("i=%0d ref_reg[i]=%0h register[i]=%0h",i,ref_reg[i],register[i]),UVM_LOW)
    end
    foreach (ref_reg[i]) visited[i] = 0;
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    scr_port = new("scr_port", this);
  endfunction

  function void compare(data_pkt t);
    case (t.inst[6:0])
      7'b0110011: begin
        if (exp.alu_opcode.name == SLT || exp.alu_opcode.name == SLTU) begin
          if (exp.lt_flag == t.lt_flag && t.alu_opcode.name == SLT) begin
            pass_count++;
            `uvm_info("SB_PASS", $sformatf("R-Type Instruction passed inst => %h", exp.inst),
                      UVM_LOW)
            pass_fail = 1'b1;
            // //`uvm_info("SB_FAIL", $sformatf("t pc %h", t.pc), UVM_LOW)
            `uvm_info("SB_FAIL", $sformatf("exp pc %h", exp.pc), UVM_LOW)
          end else if (exp.ltu_flag == t.ltu_flag && t.alu_opcode.name == SLTU) begin
            pass_count++;
            `uvm_info("SB_PASS", $sformatf("R-Type Instruction passed inst => %h", exp.inst),
                      UVM_LOW)
            pass_fail = 1'b1;
            // //`uvm_info("SB_FAIL", $sformatf("t pc %h", t.pc), UVM_LOW)
            `uvm_info("SB_FAIL", $sformatf("exp pc %h", exp.pc), UVM_LOW)
          end else begin
            fail_count++;
            `uvm_info("SB_FAIL", "R-Type Instruction failed", UVM_LOW)
            `uvm_info("SB_FAIL", $sformatf("t pc %h", t.pc), UVM_LOW)
            `uvm_info("SB_FAIL", $sformatf("exp pc %h", exp.pc), UVM_LOW)
            `uvm_info("SB_pri", $sformatf("exp.inst %h", exp.inst), UVM_LOW)
            `uvm_info("SB_pri", $sformatf("t.inst %h", t.inst), UVM_LOW)
            `uvm_info("SB_pri", $sformatf("exp.lt_flag %h", exp.lt_flag), UVM_LOW)
            `uvm_info("SB_pri", $sformatf("t.lt_flag %h", t.lt_flag), UVM_LOW)
            `uvm_info("SB_pri", $sformatf("exp.ltu_flag %h", exp.ltu_flag), UVM_LOW)
            `uvm_info("SB_pri", $sformatf("t.ltu_flag %h", t.ltu_flag), UVM_LOW)
          end
        end
        else if(exp.alu_result == t.alu_result && exp.alu_opcode == t.alu_opcode && ref_reg[exp.inst[11:7]] == register[t.inst[11:7]]) begin
          pass_count++;
          `uvm_info("SB_PASS", $sformatf("R-Type Instruction Passed inst => %h", exp.inst), UVM_LOW)
          pass_fail = 1'b1;
        end else begin
          fail_count++;
          `uvm_info("SB_FAIL", "R-Type Instruction failed", UVM_LOW)
          `uvm_info("SB_FAIL", $sformatf("t pc %h", t.pc), UVM_LOW)
          `uvm_info("SB_FAIL", $sformatf("exp pc %h", exp.pc), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.inst %h", exp.inst), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.inst %h", t.inst), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.alu_result %h", exp.alu_result), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.alu_result %h", t.alu_result), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.alu_opcode %s", exp.alu_opcode.name), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("alu opcode %s", t.alu_opcode.name), UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "register[t.inst[11:7]:%d] %h", t.inst[11:7], register[t.inst[11:7]]), UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "ref_reg[exp.inst[11:7]:%d] %h", exp.inst[11:7], ref_reg[exp.inst[11:7]]),
                    UVM_LOW)
        end
      end
      7'b0010011: begin
        if (exp.alu_opcode.name == SLT || exp.alu_opcode.name == SLTU) begin
          if (exp.lt_flag == t.lt_flag && t.alu_opcode.name == SLT) begin
            pass_count++;
            `uvm_info("SB_PASS", $sformatf("I-Type Instruction Passed inst => %h", exp.inst),
                      UVM_LOW)
            pass_fail = 1'b1;
          end else if (exp.ltu_flag == t.ltu_flag && t.alu_opcode.name == SLTU) begin
            pass_count++;
            `uvm_info("SB_PASS", $sformatf("I-Type Instruction Passed inst => %h", exp.inst),
                      UVM_LOW)
            pass_fail = 1'b1;
          end else begin
            fail_count++;
            `uvm_info("SB_FAIL", "I-Type Instruction failed", UVM_LOW)
            `uvm_info("SB_FAIL", $sformatf("t pc %h", t.pc), UVM_LOW)
            `uvm_info("SB_FAIL", $sformatf("exp pc %h", exp.pc), UVM_LOW)
            `uvm_info("SB_pri", $sformatf("exp.inst %h", exp.inst), UVM_LOW)
            `uvm_info("SB_pri", $sformatf("t.inst %h", t.inst), UVM_LOW)
            `uvm_info("SB_pri", $sformatf("exp.lt_flag %h", exp.lt_flag), UVM_LOW)
            `uvm_info("SB_pri", $sformatf("t.lt_flag %h", t.lt_flag), UVM_LOW)
            `uvm_info("SB_pri", $sformatf("exp.ltu_flag %h", exp.ltu_flag), UVM_LOW)
            `uvm_info("SB_pri", $sformatf("t.ltu_flag %h", t.ltu_flag), UVM_LOW)
          end
        end  
      else if(exp.alu_result == t.alu_result && exp.alu_opcode == t.alu_opcode && ref_reg[exp.inst[11:7]] == register[t.inst[11:7]]) begin
          pass_count++;
          `uvm_info("SB_PASS", $sformatf("I-Type Instruction Passed inst => %h", exp.inst), UVM_LOW)
          pass_fail = 1'b1;
        end else begin
          fail_count++;
          `uvm_info("SB_FAIL", "I-Type Instruction failed", UVM_LOW)
          `uvm_info("SB_FAIL", $sformatf("t pc %h", t.pc), UVM_LOW)
          `uvm_info("SB_FAIL", $sformatf("exp pc %h", exp.pc), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.inst %h", exp.inst), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.inst %h", t.inst), UVM_LOW)
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
        end
      end
      7'b0000011: begin
        if (exp.write_data == t.write_data && exp.alu_opcode == t.alu_opcode && da_mem[t.alu_result[31:2]]==ref_mem[exp.alu_result[31:2]]) begin
          pass_count++;
          `uvm_info("SB_PASS", $sformatf("L-Type Instruction Passed inst => %h", exp.inst), UVM_LOW)
          pass_fail = 1'b1;
        end else begin
          fail_count++;
          `uvm_info("SB_FAIL", "L-Type Instruction failed", UVM_LOW)
          `uvm_info("SB_FAIL", $sformatf("t pc %h", t.pc), UVM_LOW)
          `uvm_info("SB_FAIL", $sformatf("exp pc %h", exp.pc), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.inst %h", exp.inst), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.inst %h", t.inst), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.write_data %h", exp.write_data), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.write_data %h", t.write_data), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.alu_result %h", exp.alu_result), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.alu_result %h", t.alu_result), UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "da_mem[t.alu_result:%h] %h", t.alu_result, da_mem[t.alu_result[31:2]]),
                    UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "ref_mem[exp.alu_result:%h] %h", exp.alu_result, ref_mem[exp.alu_result[31:2]]),
                    UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.alu_opcode %s", exp.alu_opcode.name), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("alu opcode %s", t.alu_opcode.name), UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "ref_reg[exp.inst[19:15]:%h] %h", exp.inst[19:15], ref_reg[exp.inst[19:15]]),
                    UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "register[t.inst[19:15]:%h] %h", t.inst[19:15], register[t.inst[19:15]]),
                    UVM_LOW)
        end
      end
      7'b0100011: begin
        if (exp.write_data == t.write_data && da_mem[t.alu_result[31:2]] == ref_mem[exp.alu_result[31:2]]) begin
          pass_count++;
          `uvm_info("SB_PASS", $sformatf("S-Type Instruction Passed inst => %h", exp.inst), UVM_LOW)
          pass_fail = 1'b1;
        end else begin
          fail_count++;
          `uvm_info("SB_FAIL", "S-Type Instruction failed", UVM_LOW)
          `uvm_info("SB_FAIL", $sformatf("t pc %h", t.pc), UVM_LOW)
          `uvm_info("SB_FAIL", $sformatf("exp pc %h", exp.pc), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.inst %h", exp.inst), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.inst %h", t.inst), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.write_data %h", exp.write_data), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t. %h", t.write_data), UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "da_mem[t.alu_result:%h] %h", t.alu_result, da_mem[t.alu_result[31:2]]),
                    UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "ref_mem[exp.alu_result:%h] %h", exp.alu_result, ref_mem[exp.alu_result[31:2]]),
                    UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "ref_reg[exp.reg_A_value:%h] %h", exp.reg_A_value, ref_reg[exp.reg_A_value]),
                    UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "register[t.reg_A_value:%h] %h", t.reg_A_value, register[t.reg_A_value]),
                    UVM_LOW)
        end
      end
      7'h63: begin
        if (exp.pc_select == t.pc_select && exp.pc_next_value == t.pc_next_value) begin
          pass_count++;
          `uvm_info("SB_PASS", $sformatf("B-Type Instruction Passed inst => %h", exp.inst), UVM_LOW)
          pass_fail = 1'b1;
        end else begin
          fail_count++;
          `uvm_info("SB_FAIL", "B-Type Instruction Failed", UVM_LOW)
          `uvm_info("SB_FAIL", $sformatf("t pc %h", t.pc), UVM_LOW)
          `uvm_info("SB_FAIL", $sformatf("exp pc %h", exp.pc), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.inst %h", exp.inst), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.inst %h", t.inst), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.pc_select %d", t.pc_select), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.pc_select %d", exp.pc_select), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.pc_next_value %h", t.pc_next_value), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.pc_next_value %h", exp.pc_next_value), UVM_LOW)
        end
      end
      7'h67: begin
        if (exp.pc_select == t.pc_select && exp.pc_next_value == t.pc_next_value && ref_reg[exp.inst[11:7]]==register[t.inst[11:7]]) begin
          pass_count++;
          `uvm_info("SB_PASS", $sformatf("JARL-Type Instruction Passed inst => %h", exp.inst),
                    UVM_LOW)
          pass_fail = 1'b1;
        end else begin
          fail_count++;
          `uvm_info("SB_FAIL", "JALR-Type Instruction Failed", UVM_LOW)
          `uvm_info("SB_FAIL", $sformatf("t pc %h", t.pc), UVM_LOW)
          `uvm_info("SB_FAIL", $sformatf("exp pc %h", exp.pc), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.inst %h", exp.inst), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.inst %h", t.inst), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.pc_select %d", t.pc_select), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.pc_select %d", exp.pc_select), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.pc_next_value %h", t.pc_next_value), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.pc_next_value %h", exp.pc_next_value), UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "ref_reg[inst[11:7]: %h] %h", exp.inst[11:7], ref_reg[exp.inst[11:7]]), UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "register[inst[11:7]: %h] %h", t.inst[11:7], register[t.inst[11:7]]), UVM_LOW)
        end
      end
      7'h6f: begin
        if (exp.pc_select == t.pc_select && exp.pc_next_value == t.pc_next_value && ref_reg[exp.inst[11:7]]==register[t.inst[11:7]]) begin
          pass_count++;
          `uvm_info("SB_PASS", $sformatf("JAL-Type Instruction Passed inst => %h", exp.inst),
                    UVM_LOW)
          pass_fail = 1'b1;
        end else begin
          fail_count++;
          `uvm_info("SB_FAIL", "JAL-Type Instruction Failed", UVM_LOW)
          `uvm_info("SB_FAIL", $sformatf("t pc %h", t.pc), UVM_LOW)
          `uvm_info("SB_FAIL", $sformatf("exp pc %h", exp.pc), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.inst %h", exp.inst), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.inst %h", t.inst), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.pc_select %d", t.pc_select), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.pc_select %d", exp.pc_select), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("t.pc_next_value %h", t.pc_next_value), UVM_LOW)
          `uvm_info("SB_pri", $sformatf("exp.pc_next_value %h", exp.pc_next_value), UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "ref_reg[inst[11:7]: %h] %h", exp.inst[11:7], ref_reg[exp.inst[11:7]]), UVM_LOW)
          `uvm_info("SB_pri", $sformatf(
                    "register[inst[11:7]: %h] %h", t.inst[11:7], register[t.inst[11:7]]), UVM_LOW)
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
        exp.pc_select = 2'b00;
        case (inst[14:12])
          3'b000: exp.alu_opcode = (inst[30]) ? SUB : ADD;
          3'b001: exp.alu_opcode = SLL;
          3'b010: exp.alu_opcode = SLT;
          3'b011: exp.alu_opcode = SLTU;
          3'b100: exp.alu_opcode = XOR;
          3'b101: exp.alu_opcode = (inst[30]) ? SRA : SRL;
          3'b110: exp.alu_opcode = OR;
          3'b111: exp.alu_opcode = AND;
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
        exp.pc_select = 2'b00;
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
          ADD: exp.alu_result = ref_reg[inst[19:15]] + exp.offset;
          SUB: exp.alu_result = ref_reg[inst[19:15]] - exp.offset;
          SLL: exp.alu_result = ref_reg[inst[19:15]] << exp.offset[4:0];
          SLT: begin
            exp.lt_flag = ($signed(ref_reg[inst[19:15]]) < $signed(ref_reg[inst[24:20]]));
            exp.z_flag = 1'b0;
            exp.ltu_flag = 1'b0;
            exp.alu_result = 32'b0;
          end
          SLTU: begin
            exp.lt_flag = (ref_reg[inst[19:15]] < ref_reg[inst[24:20]]);
            exp.z_flag = 1'b0;
            exp.ltu_flag = 1'b0;
            exp.alu_result = 32'b0;
          end
          XOR: exp.alu_result = ref_reg[inst[19:15]] ^ exp.offset;
          SRL: exp.alu_result = ref_reg[inst[19:15]] >> exp.offset[4:0];
          OR:  exp.alu_result = ref_reg[inst[19:15]] | exp.offset;
          SRA: exp.alu_result = $signed(ref_reg[inst[19:15]]) >>> exp.offset[4:0];
          AND: exp.alu_result = ref_reg[inst[19:15]] & exp.offset;
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
        exp.pc_select = 2'b00;
        exp.offset = {{20{inst[31]}}, inst[31:20]};
        exp.reg_A_value = ref_reg[inst[19:15]];
        exp.alu_result = ref_reg[inst[19:15]] + signed'(exp.offset);
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
        exp.pc_select = 2'b00;
        exp.mem_write = 1'b1;
        exp.reg_A_value = ref_reg[inst[19:15]];
        exp.alu_result = ref_reg[inst[19:15]] + signed'(exp.offset);
        exp.reg_B_value = ref_reg[inst[24:20]];
        exp.write_data = exp.alu_result;
        ref_mem[exp.alu_result[31:2]] = exp.reg_B_value;
      end
      7'h63: begin
        exp.alu_select_1  = 1;
        exp.alu_select_2  = 1;
        exp.offset[31:13] = {19{inst[31]}};
        exp.offset[12:0]  = {inst[31], inst[7], inst[30:25], inst[11:8], 1'b0};
        exp.reg_A_value   = ref_reg[exp.inst[19:15]];
        exp.reg_B_value   = ref_reg[exp.inst[24:20]];
        // exp.pc_select = 1;
        case (inst[14:12])
          3'b000: begin
            exp.alu_opcode = EQ;
            exp.z_flag = (exp.reg_A_value == exp.reg_B_value) ? 1'b1 : 1'b0;
            // if (exp.z_flag) exp.pc_next_value = exp.pc + exp.offset;
            exp.pc_select = exp.z_flag ? 2'b01 : 2'b00;
          end

          3'b001: begin
            exp.alu_opcode = NE;
            exp.z_flag = (exp.reg_A_value != exp.reg_B_value) ? 1'b0 : 1'b1;
            // if (!exp.z_flag) exp.pc_next_value = exp.pc + exp.offset;
            exp.pc_select = !exp.z_flag ? 2'b01 : 2'b00;
          end

          3'b100: begin
            exp.alu_opcode = LT;
            exp.lt_flag = ($signed(exp.reg_A_value) < $signed(exp.reg_B_value)) ? 1'b1 : 1'b0;
            // if (exp.lt_flag) exp.pc_next_value = exp.pc + exp.offset;
            exp.pc_select = exp.lt_flag ? 2'b01 : 2'b00;
          end

          3'b101: begin
            exp.alu_opcode = GE;
            exp.lt_flag = ($signed(exp.reg_A_value) >= $signed(exp.reg_B_value)) ? 1'b0 : 1'b1;
            // if (!exp.lt_flag) exp.pc_next_value = exp.pc + exp.offset;
            exp.pc_select = !exp.lt_flag ? 2'b01 : 2'b00;
          end

          3'b110: begin
            exp.alu_opcode = LTU;
            exp.ltu_flag   = (exp.reg_A_value < exp.reg_B_value) ? 1'b1 : 1'b0;
            exp.pc_select  = exp.ltu_flag ? 2'b01 : 2'b00;
          end

          3'b111: begin
            exp.alu_opcode = GEU;
            exp.ltu_flag   = (exp.reg_A_value >= exp.reg_B_value) ? 1'b0 : 1'b1;
            exp.pc_select  = !exp.ltu_flag ? 2'b01 : 2'b00;
          end

        endcase
        if (exp.pc_select == 2'b01) exp.pc_next_value = exp.pc + signed'(exp.offset);
        else exp.pc_next_value = exp.pc + 32'd4;
      end
      7'h6f: begin
        exp.alu_select_1 = 1'b0;
        exp.alu_select_2 = 1'b0;
        exp.alu_opcode = ADD;
        exp.offset = {{11{inst[31]}}, inst[31], inst[19:12], inst[20], inst[30:21], 1'b0};
        exp.A_value = exp.pc;
        exp.B_value = exp.offset;
        exp.alu_result = exp.A_value + exp.B_value;
        exp.reg_write = 1'b1;
        exp.mem_read = 1'b0;
        exp.write_from = 2'b10;
        exp.pc_select = 2'b01;
        if (exp.pc_select == 2'b01) exp.pc_next_value = exp.pc + exp.offset;
        else exp.pc_next_value = exp.pc + 32'd4;
        if (exp.inst[11:7] != 0) ref_reg[exp.inst[11:7]] = exp.pc + 32'd4;
        else ref_reg[0] = 0;
      end
      7'h67: begin
        exp.alu_select_1 = 1'b0;
        exp.alu_select_2 = 1'b0;
        exp.alu_opcode = ADD;
        exp.offset = {{20{inst[31]}}, inst[31:20]};
        exp.reg_A_value = ref_reg[exp.inst[19:15]];
        exp.mem_read = 1'b0;
        exp.mem_write = 1'b0;
        exp.reg_write = 1'b1;
        exp.pc_select = 2'b10;
        exp.write_from = 2'b10;
        exp.pc_next_value = ($signed(exp.offset) + $signed(exp.reg_A_value)) & ~(32'd1);
        // else exp.pc_next_value = exp.pc + 32'd4;
        if (exp.inst[11:7] != 0) ref_reg[exp.inst[11:7]] = exp.pc + 32'd4;
        else ref_reg[0] = 0;
      end
      default: begin
        exp.alu_opcode   = ADD;
        exp.alu_select_1 = 1'b1;
        exp.alu_select_2 = 1'b1;
        exp.alu_result   = ref_reg[inst[19:15]] + ref_reg[inst[24:20]];
      end
    endcase
  endfunction

  function void write(data_pkt t);
    riscv_cg.sample(t);
    rsp.push_back(t);
  endfunction

  task run_phase(uvm_phase phase);

    phase.raise_objection(this);
    pc = 0;
    repeat (j) begin
      pass_fail = 0;
      wait (rsp.size() > 0) exp = data_pkt::type_id::create("exp");
      iop = data_pkt::type_id::create("iop");
      iop = rsp.pop_front();
      `uvm_info("cont", $sformatf("exp.pc=%0d", pc), UVM_LOW)
      if (!iop.reset) begin
        `uvm_info("cont", "Need to compare reg and PC to zeros here", UVM_LOW)
      end else begin
        exp.pc = pc;
        exp.inst = mem[exp.pc/4];
        visited[pc/4] = visited[pc/4] + 1;
        // `uvm_info("cont", $sformatf(" before predicions exp.inst=%0h t.inst=%0h", exp.inst, iop.inst
        // ), UVM_LOW)
        predictor(exp.inst);
        #1 compare(iop);
        if (pass_fail) begin
          if (exp.pc_select == 2'b01) pc = pc + exp.offset;
          else if (exp.pc_select == 2'b10) pc = exp.reg_A_value + exp.offset;
          else pc = pc + 32'd4;
          if (pass_count + fail_count >= 1023 || pc >= 4092) begin
            `uvm_info("SB_pri", "all instructions are either covered or pc is longer valid",
                      UVM_LOW)
            phase.drop_objection(this);
          end
        end else phase.drop_objection(this);
        if (visited[exp.pc/4] >= 2) begin
          `uvm_info("SB_pri", $sformatf("%h instruction is possiblly in loop", exp.inst), UVM_LOW)
          phase.drop_objection(this);
        end

      end
    end
    phase.raise_objection(this);
  endtask

  function void report_phase(uvm_phase phase);
    super.report_phase(phase);
    `uvm_info("sb", $sformatf("pass count %d", pass_count), UVM_LOW)
    `uvm_info("sb", $sformatf("fail count %d", fail_count), UVM_LOW)
  endfunction
endclass
