# MIPS Single-Cycle Processor

Verilog implementation of a single-cycle MIPS processor built around a small, testable datapath with dedicated fetch, decode, execute, memory, and write-back units.

## Overview

This project implements a single-cycle MIPS processor in Verilog and validates it through isolated testbenches and waveform-based simulation. The repository includes the core hardware modules, module-level testbenches, a top-level integration bench, and a waveform-oriented bench for inspecting full program execution. The processor is meant to be tested both through terminal-based runs and through GTKWave inspection of the instruction program stored in `programs/instruction.list`.

## What This Project Implements

The processor is organized into the usual single-cycle building blocks:

- Program Counter
- Instruction Memory
- Data Memory
- Register File
- ALU
- ALU Control
- Main Control Unit
- Top-Level Datapath Integration

Together, these units support a subset of MIPS instructions across arithmetic, logical, immediate, memory, branch, and jump behaviors.

## Repository Structure

```text
mips-single-cycle-processor/
|-- src/                    # Verilog source modules
|   |-- pc.v
|   |-- i_mem.v
|   |-- d_mem.v
|   |-- regfile.v
|   |-- ula.v
|   |-- ula_ctrl.v
|   |-- ctrl.v
|   `-- mips_top.v
|-- tb/                     # Testbenches
|   |-- tb_pc.v
|   |-- tb_i_mem.v
|   |-- tb_d_mem.v
|   |-- tb_regfile.v
|   |-- tb_ula.v
|   |-- tb_ula_ctrl.v
|   |-- tb_ctrl.v
|   |-- tb_mips_top.v
|   `-- tb_mips_wave.v
|-- programs/               # Binary program files used by instruction memory
|   |-- instruction.list
|   `-- instruction_test.list
|-- sim/                    # Generated simulation artifacts
|-- .devcontainer/
|   `-- devcontainer.json
|-- Dockerfile
|-- docker-compose.yml
|-- Makefile
|-- run-testbench
`-- README.md
```

## Recommended Environment

The provided scripts are Linux-oriented. Because of that, the recommended environments are:

1. Native Linux
2. WSL
3. DevContainer

Direct PowerShell or Command Prompt usage is possible for manual compilation, but it is not the main workflow used by this repository.

A DevContainer is a preconfigured containerized development environment. In practice, it opens the project with the required tools already installed, which makes setup more reproducible and avoids local dependency differences.

## How to Run the Project

### Linux / WSL (Recommended)

Install the required tools:

```bash
sudo apt update
sudo apt install -y iverilog gtkwave make
```

Clone the repository and enter it:

```bash
git clone <your-repository-url>
cd mips-single-cycle-processor
```

Run an isolated module test:

```bash
./run-testbench ula
```

Run the waveform-oriented top-level simulation:

```bash
make wave
```

### DevContainer (Recommended on Windows)

If you are on Windows, this is one of the safest ways to get a reproducible environment.

1. Install Docker Desktop.
2. Install Visual Studio Code.
3. Install the Dev Containers extension in VS Code.
4. Open the repository folder in VS Code.
5. Choose `Reopen in Container`.
6. Wait for the environment to build.
7. Run the same Linux commands from the integrated terminal.

Example:

```bash
./run-testbench regfile
make wave
```

### Windows Notes

- The repository scripts are Bash scripts.
- Because of that, WSL or the DevContainer is strongly recommended on Windows.
- Running directly from PowerShell or Command Prompt is not the intended path for the provided automation.

## Test and Simulation Commands

### `./run-testbench <module>`

This script compiles and runs one testbench at a time. It exists to make module-level validation fast, repeatable, and easy to use.

Examples:

```bash
./run-testbench pc
./run-testbench regfile
./run-testbench ula
./run-testbench ula_ctrl
./run-testbench ctrl
./run-testbench mips_top
./run-testbench mips_wave
```

Supported module names:

- `pc`
- `i_mem`
- `d_mem`
- `regfile`
- `ula`
- `ula_ctrl`
- `ctrl`
- `mips_top`
- `mips_wave`

### `make`

Runs the lightweight waveform-oriented top-level simulation. This is useful for a quick end-to-end execution using the program loaded by instruction memory.

```bash
make
```

### `make wave`

Runs the waveform bench and opens GTKWave automatically. This is the most practical command for showing processor execution visually.

```bash
make wave
```

### `make clean`

Removes generated simulation files from `sim/`.

```bash
make clean
```

## Quick Demo for Evaluation

If the goal is to validate the project quickly, this is a good minimal sequence:

```bash
./run-testbench ctrl
./run-testbench regfile
./run-testbench mips_top
make wave
```

This gives:

- a control-unit check
- a register-file check
- a top-level integration check
- a waveform-based visual execution of the program

## Implemented Modules

| Module | File | Purpose |
|---|---|---|
| Program Counter | `src/pc.v` | Holds the current instruction address and updates on clock edges |
| Instruction Memory | `src/i_mem.v` | Loads instructions from a binary text file and serves them asynchronously |
| Data Memory | `src/d_mem.v` | Stores and returns data for load/store operations |
| Register File | `src/regfile.v` | Provides two read ports and one write port for the 32 MIPS registers |
| ALU | `src/ula.v` | Executes arithmetic, logical, comparison, and shift operations |
| ALU Control | `src/ula_ctrl.v` | Maps decoded instruction intent into a concrete ALU operation code |
| Main Control Unit | `src/ctrl.v` | Generates high-level control signals from `opcode` and selected instruction fields |
| Top Level | `src/mips_top.v` | Wires the full datapath together and drives fetch, control, execution, memory, and write-back |

## Implemented Testbenches

| Testbench | Target | What it verifies |
|---|---|---|
| `tb/tb_pc.v` | `pc` | Reset behavior and PC updates |
| `tb/tb_i_mem.v` | `i_mem` | Instruction fetch mapping from byte address to word slot |
| `tb/tb_d_mem.v` | `d_mem` | Read/write behavior and high-impedance output when reads are disabled |
| `tb/tb_regfile.v` | `regfile` | Register reads, writes, reset, and `$zero` protection |
| `tb/tb_ula.v` | `ula` | Arithmetic, logical, comparison, shift, and zero-flag behavior |
| `tb/tb_ula_ctrl.v` | `ula_ctrl` | ALU operation decoding from control fields |
| `tb/tb_ctrl.v` | `ctrl` | Main control-signal generation for supported instructions |
| `tb/tb_mips_top.v` | `mips_top` | Top-level instruction fetch and integration behavior |
| `tb/tb_mips_wave.v` | `mips_top` | Full-program execution with waveform dumping for GTKWave |

## Verification Workflow

The most reliable way to validate the project is:

1. Run isolated module testbenches with `./run-testbench <module>`.
2. Run the top-level integration test with `./run-testbench mips_top`.
3. Run the waveform simulation with `make wave` to inspect execution visually.

This sequence gives both unit-level confidence and full-program verification.

## How to Inspect Execution in GTKWave

The `.vcd` file is generated by the waveform testbench during simulation. GTKWave does not simulate the design by itself; it only visualizes the signals that the testbench dumped.

For this project, the most useful signals to inspect are:

- `T9`
- `PC`
- `ULAResult`
- `DataMemoryOut`

The `T9` signal is especially useful because it mirrors register `$t9` and is used as a test marker in the bigger instruction program. In the program, `$t9` is incremented at the beginning of each test block. That means every time `T9` changes value in GTKWave, a new test section has started.

Recommended GTKWave workflow:

1. Run `make wave`.
2. Open the generated waveform.
3. Add `T9`, `PC`, `ULAResult`, and `DataMemoryOut` to the wave window.
4. Use each transition of `T9` as the boundary between tests.
5. Zoom into the interval right after each `T9` change.
6. Compare the waveform with the corresponding instructions in the test program.

This is much clearer than trying to inspect the entire execution as one single block.

## How to Validate `instruction.list`

To validate `programs/instruction.list`, the recommended approach is to inspect it in GTKWave test by test.

The main idea is:

- run the waveform simulation
- use `T9` as the test boundary marker
- compare each block of waveform activity against the corresponding instructions in the program

What to observe in each kind of test:

- Arithmetic and logical tests: focus on `ULAResult`
- Branch and jump tests: focus on `PC`
- Memory tests: focus on `ULAResult` and `DataMemoryOut`
- Return-address behavior: focus on `PC` and, if available, the register/write-back path related to `$ra`

For the presentation or evaluation flow, the simplest strategy is:

1. Show that the program is loaded and the wave simulation runs.
2. Keep `T9`, `PC`, `ULAResult`, and `DataMemoryOut` visible.
3. Navigate from one `T9` transition to the next.
4. For each block, point only to the signals that prove the intended behavior.

This keeps the verification focused and makes it easier to explain why each instruction group is working.

## Instruction Coverage

The current implementation covers instruction families across:

- R-type arithmetic and logical operations
- Shift operations
- Immediate arithmetic and logical operations
- Load and store
- Branch comparison and control flow
- Jump instructions
- Link/return-related control flow

## Methodology

The project was developed incrementally. Each module was implemented as an isolated unit first, then validated with a dedicated testbench, and only after that integrated into the top-level datapath. On top of the unit tests, the full processor behavior is inspected through a program-driven waveform simulation, which makes it possible to verify not just isolated modules but also instruction sequencing, control flow, and memory interaction.

## Known Notes and Limitations

- The automation scripts are Bash-based.
- Linux, WSL, or DevContainer usage is recommended.
- GTKWave only shows the signals that were dumped by the testbench.
- If a program runs past the initialized instruction memory region, undefined values such as `xxxxxxxx` may appear in the waveform.
- Direct Windows terminal usage is not the primary workflow for this repository.
