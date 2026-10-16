# MIPS32 Processor - Single-Cycle & 5-Stage Pipeline (VHDL)

Implemented a 32-bit MIPS processor, written in VHDL and targeting Xilinx FPGAs. The project implements the classic MIPS datapath in two versions: a **single cycle** design and a **5 stage pipelined** design (IF · ID · EX · MEM · WB)
built around the same instruction set and control unit logic. It was developed and tested on a **Nexys A7** board.


## Architecture

The datapath is split into independent, composable VHDL entities:

| Module | Description |
|---|---|
| `IFetch` | Program counter, instruction memory interface, and next-PC selection logic (sequential / branch / jump targets) |
| `ID` | Register file and instruction field decoding |
| `UC` | Control unit — decodes the 6-bit opcode into datapath control signals (`RegDst`, `ExtOp`, `ALUSrc`, `Branch`, `Jump`, `ALUOp`, `MemWrite`, `MemToReg`, `RegWrite`) |
| `EX` | ALU and ALU-control logic, sign/zero extension handling, and branch-target address computation |
| `MEM` | Data memory read/write interface |
| `MPG` | Monopulse generator / pushbutton debouncer, used for manual single-step clocking and reset |
| `SSD` | Seven-segment display driver used for on-board signal visualization |

# MIPS32 Single Cycle version
<img width="1001" height="556" alt="Image" src="https://github.com/user-attachments/assets/4b27b158-375d-412a-8a96-f0b1df47b9bd" />

- Each instruction executes in exactly **one clock cycle**
- Cycle length is fixed to the slowest instruction (`lw`)
- Simple to design and verify, but wastes time on fast instructions
- No hazards to handle (no overlapping instructions)

# MIPS32 Pipelined version
<img width="998" height="553" alt="Image" src="https://github.com/user-attachments/assets/dfdc4732-0a71-4dd0-8e59-da3cc013178f" />

- Each instruction still takes **5 cycles**, but a new one starts every cycle
- Cycle length only needs to cover the slowest single stage 
- Needs pipeline registers between stages (IF/ID, ID/EX, EX/MEM, MEM/WB)
- Higher throughput overall (~5x ideal speedup)
- Introduces hazards (data, control, structural) that need forwarding/stalling to resolve


## Instruction Set Support

Every instruction is decoded from a 32-bit word laid out in one of three MIPS formats:

- **R-type**: `opcode[31:26] | rs[25:21] | rt[20:16] | rd[15:11] | sa[10:6] | funct[5:0]`
- **I-type**: `opcode[31:26] | rs[25:21] | rt[20:16] | immediate[15:0]`
- **J-type**: `opcode[31:26] | address[25:0]`

### R-type (`opcode = 000000`)

| Instruction | rs | rt | rd | sa | funct | Operation |
|---|---|---|---|---|---|---|
| `add $rd, $rs, $rt` | xxx | xxx | xxx | x | 100000 | RF[rd] ← RF[rs] + RF[rt] |
| `sub $rd, $rs, $rt` | xxx | xxx | xxx | x | 100010 | RF[rd] ← RF[rs] − RF[rt] |
| `slt $rd, $rs, $rt` | xxx | xxx | xxx | x | 101010 | RF[rd] ← (RF[rs] < RF[rt]) ? 1 : 0 |
| `and $rd, $rs, $rt` | xxx | xxx | xxx | x | 100100 | RF[rd] ← RF[rs] and RF[rt] |
| `or $rd, $rs, $rt` | xxx | xxx | xxx | x | 100101 | RF[rd] ← RF[rs] or RF[rt] |
| `sll $rd, $rt, sa` | 00000 | xxx | xxx | xxx | 000000 | RF[rd] ← RF[rt] << sa |
| `srl $rd, $rt, sa` | 00000 | xxx | xxx | xxx | 000010 | RF[rd] ← RF[rt] >> sa |

### I-type

| Instruction | opcode | rs | rt | immediate | Operation |
|---|---|---|---|---|---|
| `addi $rt, $rs, imm` | 001000 | xxx | xxx | xxxx | RF[rt] ← RF[rs] + SignExt(imm) |
| `slti $rt, $rs, imm` | 001010 | xxx | xxx | xxxx | RF[rt] ← (RF[rs] < SignExt(imm)) ? 1 : 0 |
| `andi $rt, $rs, imm` | 001100 | xxx | xxx | xxxx | RF[rt] ← RF[rs] and ZeroExt(imm) |
| `ori $rt, $rs, imm` | 001101 | xxx | xxx | xxxx | RF[rt] ← RF[rs] or ZeroExt(imm) |
| `lw $rt, imm($rs)` | 100011 | xxx | xxx | xxxx | RF[rt] ← MEM[RF[rs] + SignExt(imm)] |
| `sw $rt, imm($rs)` | 101011 | xxx | xxx | xxxx | MEM[RF[rs] + SignExt(imm)] ← RF[rt] |
| `beq $rs, $rt, imm` | 000100 | xxx | xxx | xxxx | if (RF[rs] = RF[rt]) PC ← PC+4 + (SignExt(imm) << 2) |
| `bne $rs, $rt, imm` | 000101 | xxx | xxx | xxxx | if (RF[rs] ≠ RF[rt]) PC ← PC+4 + (SignExt(imm) << 2) |

### J-type

| Instruction | opcode | address | Operation |
|---|---|---|---|
| `j target` | 000010 | xxxxxxx | PC ← {PC+4[31:28], address, 00} |

### Control Unit Table
<img width="764" height="300" alt="Image" src="https://github.com/user-attachments/assets/bfb58045-efab-455f-92b3-4fbc899cd26d" />


## Demo Program

- Sum of all odd numbers that are 3 or greater from a list of 5 numbers in memory.
<img width="505" height="346" alt="image" src="https://github.com/user-attachments/assets/8b29b026-72ed-472d-8305-77950e106e0f" />

- Memory initialization
<img width="605" height="167" alt="image" src="https://github.com/user-attachments/assets/c2ebd420-1f62-49ed-a784-b32b04866d37" />

-I initialize the memory with a list of: [5, 2, 9, 1]. The output is 14 for this input.

- Traversal of the program (for the input I initialized the memory with)
<img width="1353" height="694" alt="trasareAC" src="https://github.com/user-attachments/assets/884f98ef-29a8-496a-bbbe-13f8cfbd5772" />

## Pipeline Registers

- The field layout for the four pipeline registers in the pipelined MIPS design. Each one sits between two stages and holds the values that stage produced, so the next stage can use them on the following clock cycle.
<img width="506" height="595" alt="image" src="https://github.com/user-attachments/assets/6e252529-bb09-404e-9c52-d639d72e41ea" />

## Hazards

- (With) Hazards program version
<img width="1919" height="343" alt="image" src="https://github.com/user-attachments/assets/20f137af-85f4-40b3-9f39-54ffc33a1ee5" />

- (Without) Hazards program version (Solved with NOOPs and forwarding)
<img width="1853" height="712" alt="image" src="https://github.com/user-attachments/assets/e8b66584-fbc5-4f7f-abaf-9367cb5ada4d" />





## Running the program

1. Create a project in **Xilinx Vivado** (version matching the target Nexys A7 toolchain).
2. Add all `.vhd` sources and the `NexysA7_test_env.xdc` constraints file.
3. Set `test_env` as the top-level entity.
4. Run synthesis, implementation, and generate the bitstream (or program the board directly with the included `test_env.bit`).
5. Use the buttons and switches in order to run the program as shown below:
   
**Switches**

| Switches | Function |
|---|---|
| `sw[2:0]` | Enable memory writing on `01` |
| `sw[7:5] = 000` | 7-segment display shows **instruction** |
| `sw[7:5] = 001` | 7-segment display shows **next PC** |
| `sw[7:5] = 010` | 7-segment display shows **ALU result** |
| `sw[7:5] = 011` | 7-segment display shows **ALU output** |
| `sw[7:5] = 100` | 7-segment display shows **extended immediate** |
| `sw[7:5] = 101` | 7-segment display shows **branch address** |
| `sw[7:5] = 110` | 7-segment display shows **registers** |
| `sw[7:5] = 111` | 7-segment display shows **memory** |

**Buttons**

| Button | Position | Function | Recommended switch setting |
|---|---|---|---|
| `btn[0]` | Middle | Step through instructions | `sw[7:5] = 000` (view instructions) |
| `btn[1]` | Upper | Reset to first instruction | `sw[7:5] = 000` (view instructions) |
| `btn[2]` | Left | Navigate data memory | `sw[7:5] = 111` (view memory content) |
| `btn[3]` | Right | Navigate Register File | `sw[7:5] = 110` (view register content) |

## License

This project is licensed under the [MIT License](LICENSE).
