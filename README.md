# RISC-V Single-Cycle Processor (RV32I)

A concise, synthesizable SystemVerilog implementation of a single-cycle RV32I core with a clean datapath/control separation and an accompanying UVM-based testbench for verification.

![Language](https://img.shields.io/badge/Language-SystemVerilog-blue)
![ISA](https://img.shields.io/badge/ISA-RISC--V%20RV32I-green)
![Status](https://img.shields.io/badge/Status-Verified-brightgreen)

## Overview

This repository contains a single-cycle RV32I processor implementation and testbench. The design is organized into small, testable modules (fetch/PC, immediate generator, control, ALU, register file, memories) and a `single_core.sv` top-level that wires them together. Verification is provided by a UVM-based TB (driver, monitor, scoreboard) plus a simple non-UVM harness for quick runs.

**Highlights:**
- Modular RTL suitable for learning and incremental extension
- Immediate generation for RV32I formats (I, S, B, U, J)
- ALU with comparison flags used by the control logic
- UVM environment with constrained-random instruction generation and a scoreboard

## Supported Instructions

The implementation supports a practical subset of the RV32I base ISA used by the testbench (R-type, I-type, loads/stores, branches, JAL/JALR). For exact encodings and the mapping to ALU operations, see [rtl/control_unit.sv](rtl/control_unit.sv) and [rtl/isa_types_pkg.sv](rtl/isa_types_pkg.sv).

## Architecture & Design

### High-Level Block Diagram
```
┌─────────────────────────────────────────────────────────┐
│                   RISC-V Single-Cycle Core              │
├─────────────────────────────────────────────────────────┤
│  Fetch Block (PC + Immediate)                           │
│  ├─ PC Register (32-bit)                                │
│  ├─ Adder (PC + 4)                                      │
│  └─ Multiplexer (select next PC)                        │
├─────────────────────────────────────────────────────────┤
│  Instruction Memory (1024 x 32-bit)                     │
├─────────────────────────────────────────────────────────┤
│  Immediate Generator (decode all formats)               │
├─────────────────────────────────────────────────────────┤
│  Control Unit (decoding + control signals)              │
│  ├─ ALU I/O Selection                                   │
│  └─ Output Control (mem_read, mem_write, reg_write)     │
├─────────────────────────────────────────────────────────┤
│  Register File (32x32-bit, x0 hardwired to 0)           │
├─────────────────────────────────────────────────────────┤
│  ALU (arithmetic, logic, shifts, comparisons)           │
├─────────────────────────────────────────────────────────┤
│  Data Memory (1024 x 32-bit, word-aligned access)       │
└─────────────────────────────────────────────────────────┘
```

### Execution Flow
1. Fetch instruction from `ins_mem` using `pc`
2. Generate immediate with `imm_generator`
3. Decode control signals in `control_unit`
4. Read operands from the register file
5. Execute in `alu`, set flags (zero/lt/ltu)
6. Memory access (if any) and writeback (ALU/mem/PC+4)
7. Update PC via `fetch_block` mux

## Directory Structure

```
rics-exp/
├── rtl/                      # Synthesizable SystemVerilog modules
│   ├── isa_types_pkg.sv      # Operator enum types
│   ├── alu.sv                # ALU and comparison logic
│   ├── control_unit.sv      # Decoder and control outputs
│   ├── fetch_block.sv       # PC logic and muxing
│   ├── imm_generator.sv     # Immediate extraction
│   ├── registers.sv         # Register file (x0 hardwired)
│   ├── inst_mem.sv          # Instruction memory (ins_mem)
│   ├── data_mem.sv          # Data memory (da_mem)
│   └── single_core.sv       # Top-level core instantiation
├── tb/                      # Testbench (UVM + helpers)
│   ├── ag.sv                # Agent
│   ├── driver.sv            # Driver that loads instructions
│   ├── mon.sv               # Monitor that samples DUT signals
│   ├── scr.sv               # Scoreboard + covergroups
│   ├── seq.sv               # Constrained-random sequence
│   ├── seqr.sv              # Sequencer
│   ├── test.sv              # UVM test
│   ├── tb.sv                # UVM top wrapper
│   └── test_sc.sv           # Simple non-UVM single-core test
├── sw/                      # Software/test programs
│   └── inst_set.hex         # Example instruction sequence
├── sim/                     # Generated waveforms
├── dump.vcd                 # Example VCD produced during runs
├── coverage.txt             # Example coverage output
└── README.md                # This file
```

## How to Run (examples)

- Quick non-UVM run using the simple harness (`test_sc.sv`): compile `rtl/*.sv` and `tb/test_sc.sv`, load `sw/inst_set.hex` as the file shows, then run to produce `sim/SC_wave.vcd`.

- Full UVM run (used during verification): the project has been exercised with Questa/Modelsim. See `tb/log.txt` for the exact `qrun` invocation used in our runs.

Example Questa command (see `tb/log.txt` for full options):

qrun -batch -access=rw+/. -uvmhome uvm-1.2 -timescale 1ns/1ns -mfcu design.sv testbench.sv -voptargs+acc

Notes:
- Waveforms are written by the TB to `dump.vcd` / `sim/*.vcd` depending on which test is run.
- Ensure a UVM installation (uvm-1.2) is available on the simulator compile path for UVM runs.

## Verification & Testing

- Unit tests: `tb/alu_tb.sv` and `tb/control_tb.sv` exercise ALU and control logic.
- UVM test: `risc_test` (in `tb/test.sv`) runs constrained-random instruction sequences and uses the scoreboard in `tb/scr.sv` for golden comparisons and coverage collection.
- Coverage: basic covergroups live in `tb/scr.sv`; example output is `coverage.txt`.

## Known Limitations & Future Work

- Single-cycle core: simple but low throughput compared to pipelined designs
- No MMU, caches, or interrupts
- Limited instruction set coverage (extend via `control_unit.sv` and `isa_types_pkg.sv`)

Planned enhancements: add pipelining, forwarding, branch prediction, caches, and synthesis scripts.

## Immediate Encoding

All RV32I immediate formats implemented in `rtl/imm_generator.sv` (I, S, B, U, J) — see that file for bitfield mappings.

## Files of Interest
- [rtl/single_core.sv](rtl/single_core.sv)
- [rtl/alu.sv](rtl/alu.sv)
- [rtl/control_unit.sv](rtl/control_unit.sv)
- [tb/tb.sv](tb/tb.sv)
- [tb/test.sv](tb/test.sv)
- [tb/test_sc.sv](tb/test_sc.sv)