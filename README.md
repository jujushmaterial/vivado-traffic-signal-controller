# Improved Traffic Signal Controller using Verilog

## 1. Project Overview

디지털논리회로 수업에서 진행한 Verilog 기반 Traffic Signal Controller 개선 프로젝트입니다.

기존 Traffic Signal Controller는 Main Highway와 Country Road로 구성된 신호등 제어기이며, Country Road에 차량이 감지되면 Main Highway가 Green → Yellow → Red로 전환된 뒤 Country Road가 Green이 되는 구조입니다.

본 프로젝트에서는 기존 구조에 Emergency Mode, Country Road Green Time Limit, Night OFF Mode를 추가하고, Verilog design source와 testbench를 통해 동작을 검증했습니다.

**Summary:**  
This project implements an improved FSM-based traffic signal controller using Verilog and Vivado, adding Emergency Mode, Country Road Green Time Limit, and Night OFF Mode.

---

## 2. Project Information

| Item | Description |
|---|---|
| Course | Digital Logic Circuit |
| Project | Improved Traffic Signal Controller |
| Tool | Vivado 2025.2 |
| Language | Verilog |
| Design Type | FSM-based sequential logic |
| Verification | Testbench and behavioral simulation |
| Status | Completed |

---

## 3. Added Features

### 3.1 Emergency Mode

`emergency = 1`이 입력되면 현재 state와 관계없이 Emergency Mode인 `S5`로 이동하도록 설계했습니다.

Emergency Mode에서는 Main Highway가 Green, Country Road가 Red로 출력됩니다.

### 3.2 Country Road Green Time Limit

Country Road에 차량이 계속 감지되더라도 Country Road Green 상태가 무한히 유지되지 않도록 `green_count` counter와 `GREEN_LIMIT` parameter를 추가했습니다.

`S3`, 즉 Country Road Green 상태에서만 `green_count`가 증가하며, `GREEN_LIMIT`에 도달하면 `S4`로 이동하도록 설계했습니다.

### 3.3 Night OFF Mode

야간 상태를 표현하기 위해 `night_mode` 입력을 추가했습니다.

기존 2-bit 출력에서 사용하지 않던 `2'b11`을 `OFF` 상태로 정의하고, Night Mode인 `S6`에서는 Main Highway와 Country Road를 모두 OFF로 출력하도록 설계했습니다.

Night Mode 중에도 `emergency = 1`이 입력되면 `S6 → S5`로 이동합니다.

---

## 4. FSM Design

전체 신호등 동작은 FSM(Finite State Machine) 기반으로 설계했습니다.

| State | Encoding | Main Highway | Country Road | Description |
|---|---|---|---|---|
| S0 | 000 | Green | Red | 기본 상태 |
| S1 | 001 | Yellow | Red | Main Highway Yellow |
| S2 | 010 | Red | Red | All Red |
| S3 | 011 | Red | Green | Country Road Green |
| S4 | 100 | Red | Yellow | Country Road Yellow |
| S5 | 101 | Green | Red | Emergency Mode |
| S6 | 110 | OFF | OFF | Night OFF Mode |

본 설계는 Moore FSM 구조를 따르며, 출력은 입력값이 아니라 현재 state에 의해 결정됩니다.

---

## 5. Verilog Source Files

| File | Description |
|---|---|
| [`src/traffic_signal_cntr_improved.v`](./src/traffic_signal_cntr_improved.v) | Improved Traffic Signal Controller design source |
| [`src/tb_traffic_signal_cntr_improved.v`](./src/tb_traffic_signal_cntr_improved.v) | Testbench for functional verification |

---

## 6. Testbench Verification

Testbench에서는 다음 동작을 검증했습니다.

| Test | Verification Target |
|---|---|
| Reset | 초기 상태 `S0` 복귀 확인 |
| Normal Cycle 1 | `green_count`가 `GREEN_LIMIT`에 도달하면 `S3 → S4` 이동 |
| Normal Cycle 2 | `S3`에서 차량이 사라지면 `S4` 이동 |
| Emergency Test | `S0~S4` 어느 상태에서도 `emergency = 1`이면 `S5` 이동 |
| Night Mode | `night_mode = 1`이면 `S6` 이동 및 OFF 출력 |
| Night + Emergency | Night Mode 중 emergency 발생 시 `S6 → S5 → S6` 동작 확인 |

---

## 7. Simulation Result Summary

Behavioral simulation을 통해 다음 기능들이 의도대로 동작하는 것을 확인했습니다.

- Country Road에 차량이 계속 감지되어도 `green_count`가 제한값에 도달하면 `S3 → S4`로 이동
- `S3` 상태에서 차량이 사라지면 제한 시간과 관계없이 `S4`로 이동
- `S0~S4` 어느 상태에서도 emergency 입력이 들어오면 `S5`로 이동
- Night Mode에서는 두 신호등이 모두 `OFF = 2'b11`로 출력
- Night Mode 중 emergency가 발생하면 `S5`로 이동하고, emergency가 종료되면 다시 `S6`로 복귀
- `green_count`는 `S3` 상태에서만 증가하고, 다른 state에서는 0으로 초기화

---

## 8. Repository Structure

```text
vivado-traffic-signal-controller/
│
├── README.md
│
└── src/
    ├── traffic_signal_cntr_improved.v
    └── tb_traffic_signal_cntr_improved.v

====================Progress==================

docs/
├── 01_project_overview.md
├── 02_fsm_design.md
├── 03_verilog_code_explanation.md
├── 04_testbench_design.md
└── 05_simulation_analysis.md

images/
├── state_diagram.png
├── simulation_full.png
├── simulation_cycle1_green_count.png
├── simulation_cycle2_car_removed.png
├── simulation_emergency.png
├── simulation_night_mode.png
└── simulation_night_emergency.png

reports/
└── final_presentation_public.pdf
