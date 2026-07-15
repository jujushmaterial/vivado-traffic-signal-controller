# Improved Traffic Signal Controller using Verilog

## 1. Project Overview

디지털논리회로 수업에서 진행한 Verilog 기반 Traffic Signal Controller 개선 프로젝트입니다.

기존 Traffic Signal Controller는 Main Highway와 Country Road로 구성된 신호등 제어기이며, Country Road에 차량이 감지되면 Main Highway가 Green → Yellow → Red로 전환된 뒤 Country Road가 Green이 되는 구조입니다.

본 프로젝트에서는 기존 구조에 Emergency Mode, Country Road Green Time Limit, Night OFF Mode를 추가하고, Verilog design source와 testbench를 통해 동작을 검증했습니다.

> 설계 과정, 코드 해석, testbench 구성, simulation 결과 분석을 자세히 보고 싶다면 [9. Detailed Documents](#9-detailed-documents)에서 바로 확인할 수 있습니다.

**Summary:**  
This project implements an improved FSM-based traffic signal controller using Verilog and Vivado. It adds Emergency Mode, Country Road Green Time Limit, and Night OFF Mode, and verifies the design through a Verilog testbench and behavioral simulation.

---

## 2. Project Information

| Item | Description |
|---|---|
| Course | Digital Logic Circuit |
| Project | Improved Traffic Signal Controller |
| Period | 2026.05 |
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

**Summary:**  
Emergency Mode gives the highest priority to the emergency input and forces the controller to move to `S5`, where Main Highway is Green and Country Road is Red.

---

### 3.2 Country Road Green Time Limit

Country Road에 차량이 계속 감지되더라도 Country Road Green 상태가 무한히 유지되지 않도록 `green_count` counter와 `GREEN_LIMIT` parameter를 추가했습니다.

`S3`, 즉 Country Road Green 상태에서만 `green_count`가 증가하며, `GREEN_LIMIT`에 도달하면 `S4`로 이동하도록 설계했습니다.

**Summary:**  
The `green_count` counter limits how long Country Road can stay Green. Even if a vehicle remains detected, the controller moves from `S3` to `S4` when `GREEN_LIMIT` is reached.

---

### 3.3 Night OFF Mode

야간 상태를 표현하기 위해 `night_mode` 입력을 추가했습니다.

기존 2-bit 출력에서 사용하지 않던 `2'b11`을 `OFF` 상태로 정의하고, Night Mode인 `S6`에서는 Main Highway와 Country Road를 모두 OFF로 출력하도록 설계했습니다.

Night Mode 중에도 `emergency = 1`이 입력되면 `S6 → S5`로 이동합니다.

**Summary:**  
Night OFF Mode uses `2'b11` as the OFF output state. When `night_mode = 1`, both traffic lights turn OFF, but emergency input can still move the FSM to Emergency Mode.

---

## 4. FSM Design

전체 신호등 동작은 FSM(Finite State Machine) 기반으로 설계했습니다.

FSM은 현재 state를 저장하고, 입력 조건에 따라 next state를 결정하며, 각 state에 맞는 출력을 내보내는 구조입니다.

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

**Summary:**  
The controller is designed as a Moore FSM with seven states. Outputs are determined by the current state, while inputs such as `car_country`, `emergency`, and `night_mode` are used to determine the next state.

---

## 5. Verilog Source Files

| File | Description |
|---|---|
| [`src/traffic_signal_cntr_improved.v`](./src/traffic_signal_cntr_improved.v) | Improved Traffic Signal Controller design source |
| [`src/tb_traffic_signal_cntr_improved.v`](./src/tb_traffic_signal_cntr_improved.v) | Testbench for functional verification |

---

## 6. Design Source Structure

### 6.1 Module I/O

`traffic_signal_cntr_improved`는 개선된 Traffic Signal Controller 모듈입니다.

| Signal | Direction | Description |
|---|---|---|
| `car_country` | input | Country Road 차량 감지 |
| `emergency` | input | Main Highway 응급차량 감지 |
| `night_mode` | input | 야간 상태 입력 |
| `clock` | input | state 변화 기준 clock |
| `reset` | input | 초기화 |
| `hwy[1:0]` | output | Main Highway 신호등 출력 |
| `cntry[1:0]` | output | Country Road 신호등 출력 |

---

### 6.2 Light Output Encoding

| Light | Encoding |
|---|---|
| RED | `2'b00` |
| YELLOW | `2'b01` |
| GREEN | `2'b10` |
| OFF | `2'b11` |

`OFF = 2'b11`은 Night OFF Mode에서 두 신호등을 소등하기 위해 추가한 출력 상태입니다.

---

### 6.3 State Register, Next State Logic, Output Logic

수업에서 배운 FSM style-1 구조를 기준으로 설계했습니다.

| Block | Role |
|---|---|
| State Register | clock 상승 edge에서 현재 state를 next_state로 업데이트 |
| Next State Logic | 현재 state와 입력 조건을 보고 다음 state 결정 |
| Output Logic | 현재 state에 따라 `hwy`, `cntry` 출력 결정 |

`State Register`는 `posedge clock`에서만 state를 업데이트합니다.  
`Next State Logic`은 현재 state와 입력 조건을 기준으로 다음 state를 결정합니다.  
`Output Logic`은 Moore FSM 방식으로 현재 state에 따라 출력만 결정합니다.

**Summary:**  
The design follows the FSM style-1 structure: state register, next state logic, and output logic. This separation makes the FSM behavior clear and easier to verify.

---

## 7. Testbench Verification

Testbench는 다음과 같은 구성으로 설계하였습니다.

여기서 `Cycle`은 Country Road에 차량이 감지되어 일반 신호등 동작이 한 번 진행되는 흐름을 의미합니다.  
즉, `car_country = 1`이 입력된 뒤 `S0 → S1 → S2 → S3 → S4 → S0`으로 돌아오는 과정을 하나의 normal cycle로 보았습니다.

| Test | Verification Target |
|---|---|
| Reset | 초기 상태 `S0` 복귀 확인 |
| Normal Cycle 1 | `car_country = 1`이 유지될 때 `green_count`가 `GREEN_LIMIT`에 도달하면 `S3 → S4`로 이동하는지 확인 |
| Normal Cycle 2 | `S3`에서 차량이 사라져 `car_country = 0`이 되면 제한 시간과 관계없이 `S4`로 이동하는지 확인 |
| Emergency Test | `S0~S4` 어느 상태에서도 `emergency = 1`이면 `S5`로 이동하는지 확인 |
| Night Mode | `night_mode = 1`이면 `S6`으로 이동하고 두 신호등이 OFF로 출력되는지 확인 |
| Night + Emergency | Night Mode 중 emergency 발생 시 `S6 → S5 → S6` 동작이 정상적으로 수행되는지 확인 |

**Summary:**  
The testbench verifies one normal traffic cycle from `S0` back to `S0`, green time limitation, emergency priority, Night OFF Mode, and the interaction between Night Mode and Emergency Mode.

---

## 8. Simulation Result Summary

Behavioral simulation을 통해 다음 기능들이 의도대로 동작하는 것을 확인했습니다.

- Country Road에 차량이 계속 감지되어도 `green_count`가 제한값에 도달하면 `S3 → S4`로 이동
- `S3` 상태에서 차량이 사라지면 제한 시간과 관계없이 `S4`로 이동
- `S0~S4` 어느 상태에서도 emergency 입력이 들어오면 `S5`로 이동
- Night Mode에서는 두 신호등이 모두 `OFF = 2'b11`로 출력
- Night Mode 중 emergency가 발생하면 `S5`로 이동하고, emergency가 종료되면 다시 `S6`로 복귀
- `green_count`는 `S3` 상태에서만 증가하고, 다른 state에서는 0으로 초기화

**Summary:**  
Simulation results confirm that the FSM correctly handles normal traffic flow, green time limitation, emergency priority, Night OFF Mode, and emergency behavior during Night Mode.

---

## 9. Detailed Documents

프로젝트의 설계 과정, 코드 해석, testbench 구성, simulation 결과 분석은 아래 문서에 정리했습니다.

| Document | Description |
|---|---|
| [01. Project Overview](./docs/01_project_overview.md) | 프로젝트 배경, 기존 Traffic Signal Controller 구조, 개선 방향 정리 |
| [02. FSM Design](./docs/02_fsm_design.md) | FSM state, state transition, Moore FSM 구조, state diagram 설명 |
| [03. Verilog Code Explanation](./docs/03_verilog_code_explanation.md) | Verilog design source의 module, parameter, counter, next state logic, output logic 해석 |
| [04. Testbench Design](./docs/04_testbench_design.md) | testbench 구조, clock generation, reset, normal cycle, emergency, night mode 검증 시나리오 설명 |
| [05. Simulation Analysis](./docs/05_simulation_analysis.md) | Vivado simulation waveform을 기반으로 기능별 동작 결과 분석 |

**Summary:**  
Detailed documents are organized separately to explain the project background, FSM design, Verilog source code, testbench strategy, and simulation results.

---

## 10. Repository Structure

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

---

## 11. What I Learned

- Verilog module, input/output, reg/wire 구조
- parameter를 이용한 state 및 output encoding
- Moore FSM 기반 설계 방식
- State Register, Next State Logic, Output Logic 분리
- counter를 이용한 시간 제한 기능 구현
- testbench를 이용한 입력 시나리오 검증
- Vivado waveform을 이용한 FSM 동작 해석
- clock과 reset을 기준으로 한 sequential logic 동작 이해

**Summary:**  
Through this project, I practiced basic Verilog HDL design, FSM-based sequential logic, testbench construction, and waveform-based verification using Vivado.

---

## 12. Conclusion

기존 Traffic Signal Controller에 Emergency Mode, Country Road Green Time Limit, Night OFF Mode를 추가했습니다.

FSM 구조를 확장하여 `S5`와 `S6` 상태를 추가했고, Moore FSM 방식으로 현재 state에 따라 출력이 결정되도록 설계했습니다.

Testbench와 behavioral simulation을 통해 일반 동작, 시간 제한, emergency 우선 처리, night mode, night mode 중 emergency 상황이 모두 의도대로 동작함을 확인했습니다.

**Summary:**  
The final design successfully extends the original traffic signal controller with emergency handling, green time limitation, and night light-off behavior. The simulation results verify that all added functions operate as intended.
