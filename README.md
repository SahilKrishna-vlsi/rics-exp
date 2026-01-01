# RISC-V SINGLE-CYCLE

This repository contains the system verilog implementation of RISC-V.

# RV32I Control Unit (SystemVerilog)

SystemVerilog implementation of a single-cycle RISC-V (RV32I) control unit, verified using waveform-based simulation.

    **Features**

        Full RV32I instruction decode

        Clean separation of:

        ALU operation decoding

        Datapath control (PC, memory, register writeback)

        Semantic ALU control using enums

        Purely combinational control logic (no latches)

        Verified with Verilator + GTKWave

    **Supported Instructions**

        R-Type: ADD, SUB, AND, OR, XOR, SLT, SLTU, shifts

        I-Type: ADDI, ANDI, ORI, shifts

        Load / Store: LW, SW

        Branch: BEQ, BNE, BLT, BGE, BLTU, BGEU

        Jump: JAL, JALR

    **Control Signals Generated**

        ALU operation select

        ALU input mux selects (PC / reg / immediate)

        Register write enable

        Memory read/write enable

        PC control (PC+4, PC+offset, rs1+offset)

        Writeback source select (ALU / memory / PC)

will continue working on this to build a complete single-cycle RISC-v
