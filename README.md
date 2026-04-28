# RISC-V Single-Cycle Processor (RV32I)

A complete, synthesizable RTL implementation of a single-cycle RISC-V RV32I processor core, designed and verified using SystemVerilog with clean datapath/control separation.

![Language](https://img.shields.io/badge/Language-SystemVerilog-blue)
![ISA](https://img.shields.io/badge/ISA-RISC--V%20RV32I-green)
![Simulator](https://img.shields.io/badge/Simulator-Verilator-orange)
![Status](https://img.shields.io/badge/Status-Verified-brightgreen)

## Overview

This project implements a single-cycle RV32I processor core where every instruction completes execution in one clock cycle. The design follows a classic 5-stage pipeline structure (Fetch, Decode, Execute, Memory, Writeback) but collapses all stages into a single cycle, making it ideal as a baseline reference architecture for understanding RISC-V hardware design and a foundation for future pipelined extensions.

**Key Design Features:**
- Single-cycle execution with simple, predictable timing
- Modular architecture with separate ALU, Control Unit, Register File, and Memory blocks
- Proper handling of immediate encoding (all RV32I formats)
- Correct branch and jump control flow
- Clean SystemVerilog with enums and packages for type safety

## Supported Instructions

| Format | Instructions |
|--------|-------------|
| **R-Type (Reg-Reg)** | ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU |
| **I-Type (Reg-Imm)** | ADDI, ANDI, ORI, XORI, SLLI, SRLI, SRAI, SLTI, SLTIU, JALR |
| **Load** | LW (32-bit load) |
| **Store** | SW (32-bit store) |
| **Branch** | BEQ, BNE, BLT, BGE, BLTU, BGEU |
| **Jump** | JAL, JALR |

**Total: 32 base instructions**

## Architecture & Design

### High-Level Block Diagram
```
┌─────────────────────────────────────────────────────────┐
│                   RISC-V Single-Cycle Core              │
├─────────────────────────────────────────────────────────┤
│  Fetch Block (PC + Immediate)                           │
│  ├─ PC Register (32-bit)                               │
│  ├─ Adder (PC + 4)                                     │
│  └─ Multiplexer (select next PC)                       │
├─────────────────────────────────────────────────────────┤
│  Instruction Memory (1024 x 32-bit)                     │
├─────────────────────────────────────────────────────────┤
│  Immediate Generator (decode all formats)               │
├─────────────────────────────────────────────────────────┤
│  Control Unit (decoding + control signals)              │
│  ├─ ALU I/O Selection                                  │
│  └─ Output Control (mem_read, mem_write, reg_write)   │
├─────────────────────────────────────────────────────────┤
│  Register File (32x32-bit, x0 hardwired to 0)          │
├─────────────────────────────────────────────────────────┤
│  ALU (16 operations)                                    │
│  ├─ Arithmetic (ADD, SUB)                             │
│  ├─ Logic (AND, OR, XOR)                              │
│  ├─ Shifts (SLL, SRL, SRA)                            │
│  └─ Comparisons (SLT, SLTU, EQ, NE, LT, GE, LTU, GEU)│
├─────────────────────────────────────────────────────────┤
│  Data Memory (1024 x 32-bit, word-aligned access)      │
└─────────────────────────────────────────────────────────┘
```

### Control Flow
1. **Fetch:** Load instruction at PC from instruction memory
2. **Decode:** Extract opcode and funct fields; generate control signals
3. **Execute:** ALU performs operation based on decoded signals
4. **Memory:** Load/store if required by instruction
5. **Writeback:** Write ALU result, memory data, or PC+4 to register file
6. **PC Update:** Select next PC (increment, branch, or jump) at clock edge

## Directory Structure

```
rics-exp/
├── rtl/                      # Synthesizable SystemVerilog modules
│   ├── isa_types_pkg.sv     # Operator enumeration type definition
│   ├── alu.sv               # 16-operation arithmetic/logic unit
│   ├── control_unit.sv      # Instruction decoder + control signal generator
│   ├── fetch_block.sv       # PC management and branch/jump logic
│   ├── imm_generator.sv     # Immediate extraction (all RV32I formats)
│   ├── registers.sv         # 32-entry register file with x0 hardwiring
│   ├── inst_mem.sv          # Instruction memory (synchronous read)
│   ├── data_mem.sv          # Data memory (synchronous write, async read)
│   └── single_core.sv       # Top-level processor instantiation
├── tb/                       # Testbenches
│   ├── alu_tb.sv            # ALU unit tests (all 16 operations)
│   ├── control_tb.sv        # Control signal verification
│   └── test_sc.sv           # Full system integration test
├── sw/                       # Software test programs
│   └── inst_set.hex         # Example instruction sequence (hex format)
├── sim/                      # Generated waveforms (created at runtime)
├── image.png                # Waveform screenshot
└── README.md                # This file
```

## How to Run

### Prerequisites
- **Verilator** (open-source SystemVerilog simulator)
- **GTKWave** (waveform viewer)
- **Bash** shell

**Installation (Ubuntu/Debian):**
```bash
sudo apt-get install verilator gtkwave
```

### Simulation Steps

```bash
# Clone the repository
git clone https://github.com/SahilKrishna-vlsi/rics-exp.git
cd rics-exp

# Create simulation directory
mkdir -p sim

# Compile with Verilator
verilator -Wall --Wno-fatal --trace --binary \
  rtl/isa_types_pkg.sv rtl/single_core.sv rtl/*.sv \
  tb/test_sc.sv

# Run simulation and generate waveforms
./obj_dir/Vtest_sc

# View waveforms
gtkwave sim/SC_wave.vcd
```

### Understanding the Waveform
Once GTKWave opens:
1. Add signals to the viewing area (right-click → Add to window)
2. Key signals to monitor:
   - `clk`, `reset` — timing and reset
   - `SC_dut.inst` — current instruction (32-bit hex)
   - `SC_dut.pc` — program counter
   - `SC_dut.reg_A_value`, `SC_dut.reg_B_value` — register file outputs
   - `SC_dut.alu_result` — ALU output
   - `SC_dut.mem_data` — data from memory
3. Use **View → Zoom → Fit** to see entire simulation

## Verification & Testing

### Test Coverage

| Module | Tests | Status |
|--------|-------|--------|
| **ALU** | 16 operations (ADD, SUB, AND, OR, XOR, SLL, SRL, SRA, SLT, SLTU, EQ, NE, LT, GE, LTU, GEU) | ✅ Pass |
| **Control Unit** | Instruction decoding (R-type, I-type, Load, Store, Branch, JAL, JALR) | ✅ Pass |
| **System** | Full processor with instruction sequence | ✅ Verified |

### Test Program (`inst_set.hex`)
The included hex file contains example RISC-V instructions:
```
00500093  # ADDI x1, x0, 5      -> x1 = 5
00a00113  # ADDI x2, x0, 10     -> x2 = 10
002081b3  # ADD  x3, x1, x2     -> x3 = 15
00302023  # SW   x3, 0(x0)      -> mem[0] = 15
00002203  # LW   x4, 0(x0)      -> x4 = 15
00008463  # BEQ  x0, x0, ...    -> branch taken
008002ef  # JAL  x1, ...        -> jump
00028067  # JALR x0, 0(x1)      -> return
```

## Known Limitations & Future Work

### Current Limitations
- **Single-cycle design:** No pipelining means 1 instruction per clock (low throughput)
- **No forwarding:** Data hazards require explicit pipeline stalls (not applicable in single-cycle)
- **No branch prediction:** All branches incur full latency
- **Fixed memory latency:** Assumes 1-cycle memory access
- **No interrupts/exceptions:** Educational model only

### Future Enhancements
- ✅ **5-stage pipeline** with hazard detection and forwarding
- ✅ **Branch predictor** (simple 1-bit or 2-bit saturation counter)
- ✅ **Cache hierarchy** (I-cache and D-cache with coherency)
- ✅ **MMU support** for Linux kernel compatibility
- ✅ **UVM testbench** for industrial-strength verification
- ✅ **Synthesis to FPGA** (Xilinx/Intel) with timing closure

## Performance Characteristics

### Timing (Verilator Simulation)
- **Clock Period:** 100 ns (configurable)
- **Critical Path:** ALU operation + register writeback
- **Instructions Per Clock:** 1.0 (single-cycle design)

### Resource Usage (Estimated for Synthesis)
| Resource | Estimate |
|----------|----------|
| **Flip-Flops (FF)** | ~500 (PC, registers, mux trees) |
| **LookUp Tables (LUT)** | ~1500 (ALU, control logic) |
| **BRAM** | 2 blocks (1 for inst_mem, 1 for data_mem) |
| **Max Frequency** | ~100 MHz (depends on synthesis tool) |

## Design Decisions & Trade-offs

### Why Single-Cycle?
- **Simplicity:** Easy to understand for learning
- **Correctness:** No pipeline hazards or forwarding complexity
- **Baseline:** Perfect foundation for adding 5-stage pipeline

### Register File Design
- **Write-first semantics:** Updates occur on rising clock edge
- **x0 hardwired to 0:** RISC-V requirement; writes to x0 are ignored
- **Asynchronous read:** Combinational logic enables immediate operand access

### Immediate Encoding
All RV32I immediate formats correctly decoded:
- **I-type:** `inst[31:20]` (12-bit, sign-extended)
- **S-type:** `{inst[31:25], inst[11:7]}` (12-bit, sign-extended)
- **B-type:** `{inst[31], inst[7], inst[30:25], inst[11:8], 1'b0}` (13-bit, sign-extended)
- **U-type:** `inst[31:12]` (20-bit)
- **J-type:** `{inst[31], inst[19:12], inst[20], inst[30:21], 1'b0}` (21-bit, sign-extended)

## Code Quality & Best Practices

- ✅ **Modular design:** Each functional block is a separate module
- ✅ **Type safety:** Uses SystemVerilog enums (`operator_t`) instead of magic numbers
- ✅ **Parameterization:** Memory sizes easily adjustable
- ✅ **Simulation-friendly:** Includes `$dumpvars` for VCD generation
- ✅ **Comments:** All complex logic documented

## References

- [RISC-V ISA Spec](https://riscv.org/technical/specifications/) — Official specification
- [RISC-V Book](https://github.com/riscv/riscv-isa-manual) — Design rationale
- [Digital Design & Computer Architecture](https://www.elsevier.com/books/digital-design-and-computer-architecture-risc-v-edition) — RISC-V processor design patterns

## Author

**Sahil Krishna Mandadapu**
- 📧 Email: mandadapusk@gmail.com
- 🔗 LinkedIn: [linkedin.com/in/sahilkrishna](https://www.linkedin.com/in/sahilkrishna/)
