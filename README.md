# Improved Traffic Signal Controller using Verilog

Verilog와 Vivado를 이용하여 FSM 기반 Traffic Signal Controller를 개선한 디지털논리회로 기말 프로젝트입니다.

기존 Traffic Signal Controller 구조에 다음 세 가지 기능을 추가했습니다.

- Emergency Mode
- Country Road Green Time Limit
- Night OFF Mode

설계한 Verilog design source와 testbench를 통해 일반 동작, 시간 제한, emergency 우선 처리, night mode, night mode 중 emergency 동작을 behavioral simulation으로 검증했습니다.

**Summary:**  
This project implements an improved FSM-based traffic signal controller using Verilog and Vivado. It adds Emergency Mode, Country Road Green Time Limit, and Night OFF Mode, and verifies the design through a Verilog testbench and behavioral simulation.

---

## Project Information

| Item | Description |
|---|---|
| Period | 2026.05 |
| Course | Digital Logic Circuit |
| Tool | Vivado 2025.2 |
| Language | Verilog |
| Design Type | FSM-based sequential logic |
| Verification | Testbench and behavioral simulation |
| Status | Complete |

---

## Project Page

[View Project Page](https://jujushmaterial.github.io/vivado-traffic-signal-controller/)

## Source Code

| File | Description |
|---|---|
| [`src/traffic_signal_cntr_improved.v`](./src/traffic_signal_cntr_improved.v) | Improved Traffic Signal Controller design source |
| [`src/tb_traffic_signal_cntr_improved.v`](./src/tb_traffic_signal_cntr_improved.v) | Testbench for functional verification |

## Repository Structure

```text
vivado-traffic-signal-controller/
│
├── README.md
├── index.md
│
├── src/
│   ├── traffic_signal_cntr_improved.v
│   └── tb_traffic_signal_cntr_improved.v
│
├── docs/
│   ├── 01_project_overview.md
│   ├── 02_fsm_design.md
│   ├── 03_verilog_code_explanation.md
│   ├── 04_testbench_design.md
│   └── 05_simulation_analysis.md
│
└── images/
    ├── state_diagram.png
    ├── state_output_table.png
    ├── simulation_full.png
    ├── simulation_full_check.png
    ├── simulation_cycle1_green_count.png
    ├── simulation_cycle2_car_removed.png
    ├── simulation_emergency.png
    ├── simulation_night_mode.png
    ├── simulation_night_emergency.png
    └── simulation_green_count_detail.png
```
