# Pipelined ALU Datapath

A synthesizable SystemVerilog project implementing a parameterized 32-bit, 3-stage pipelined ALU datapath.

## Features
- ADD, SUB, AND, OR, XOR, SLL, SRL, SRA and signed comparison
- Carry, overflow, zero and negative flags
- Valid-bit pipeline
- Parameterized data width
- Clean `always_ff` / `always_comb` RTL
- Self-checking testbench

## Pipeline
```text
Inputs -> Execute -> REG -> Flag/Result -> REG -> Output
```

The design demonstrates datapath/control separation, pipeline registers, nonblocking assignments, arithmetic flags and throughput-oriented RTL.

## Run
With Icarus Verilog:
```bash
iverilog -g2012 -o sim src/pipelined_alu.s tb/tb_pipelined_alu.s
vvp sim
```
