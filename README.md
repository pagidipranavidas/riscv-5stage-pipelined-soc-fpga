# 5-Stage Pipelined RISC-V Processor and UART Demo

Academic final-year group project focused on a five-stage pipelined RISC-V processor implemented in Verilog HDL, alongside a separate UART demonstration design.

## Project Overview

The supplied source archive contains two design variants:

- **Base pipeline processor:** a five-stage processor RTL design with modules for the ALU, ALU control, control unit, register file, instruction and data memories, immediate generation, forwarding, hazard detection, multiplier, and divider.
- **UART demonstration:** a separate UART transmitter and top-level design. The supplied `arch2.v` identifies this variant as a single-cycle processor, so it is kept separate from the five-stage pipeline sources.

The project report describes a Basys-3 Artix-7 FPGA implementation using AMD/Xilinx Vivado 2023.2 and reports a maximum operating frequency of 65 MHz. These are report-reported results and have not been independently reproduced from this source-only repository.

## Repository Structure

```text
.
├── rtl/
│   ├── base_pipeline/   # Five-stage pipeline processor RTL
│   └── uart_soc/        # Separate UART demonstration RTL
├── testbench/           # Supplied simulation testbenches
├── constraints/         # Basys-3 XDC constraints
├── images/              # Simulation, schematic, area, delay and power images
└── video/               # Supplied FPGA output/demo video
```

## Key Processor Components

The `rtl/base_pipeline/` directory includes source modules for:

- Pipeline processor integration
- ALU and ALU control
- Main control unit
- Register file
- Instruction and data memory
- Immediate generation
- Forwarding and hazard detection
- Multiplier and divider
- Program-counter and adder/multiplexer logic

The exact implemented instruction coverage and behavior should be confirmed from the RTL and testbench before making broader compatibility claims.

## Verification and Demonstration

- `testbench/rv32i_pipeline_tb.v` — supplied pipeline testbench.
- `rtl/uart_soc/tb_top_uart.v` — supplied UART demonstration testbench.
- `images/` — supplied simulation and implementation evidence.
- `video/` — supplied output demonstration video.

The presence of a testbench or screenshot does not by itself establish complete verification. Run the testbenches in the intended simulator and inspect the waveforms when reproducing the design.

## Tools and Hardware

- Verilog HDL
- AMD/Xilinx Vivado Design Suite 2023.2, as described in the project report
- Basys-3 Artix-7 FPGA board, as described in the project report

## Reported Result

The project report states a maximum operating frequency of **65 MHz**. Treat this as the reported result for the original implementation; timing depends on the source revision, FPGA part, constraints, and implementation settings.

## Academic Context

This was a final-year group project at Sri Venkateswara College of Engineering, Tirupati. The repository should acknowledge the complete project team and guide as appropriate. The author acted as team leader.

## Reproducing the Project

1. Open the project in the intended version of Vivado.
2. Add the required RTL files from `rtl/base_pipeline/` for the pipeline processor, or from `rtl/uart_soc/` for the separate UART demo.
3. Add the relevant testbench from `testbench/`.
4. Add the supplied XDC constraints and verify all pin assignments and clock constraints.
5. Run simulation before synthesis and hardware implementation.
6. Review any required initialization files or project settings that may not be included in this repository.

The original Vivado project file and complete setup metadata are not included in this minimal repository, so additional project setup may be required.

## License

No license is specified. Add a license only after confirming that the project team has permission to publish the code under its terms.
