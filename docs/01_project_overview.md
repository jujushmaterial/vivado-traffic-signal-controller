# 01. Project Overview

## 1. Project Background

디지털논리회로 수업에서 학습한 Traffic Signal Controller를 기반으로, 실제 도로 상황을 조금 더 반영할 수 있도록 기능을 확장한 Verilog 설계 프로젝트입니다.

기존 Traffic Signal Controller는 Main Highway와 Country Road로 구성된 신호등 제어기입니다. 기본 상태에서는 Main Highway가 Green, Country Road가 Red이며, Country Road에 차량이 감지되면 Main Highway가 Green → Yellow → Red 순서로 전환된 뒤 Country Road가 Green이 되는 구조입니다.

기본 구조는 FSM 기반 신호등 제어 흐름을 이해하기에 적합하지만, 실제 상황에서 필요한 예외 처리나 운용 조건을 충분히 반영하지는 못합니다. 따라서 기존 구조에 추가 기능을 적용하여 더 현실적인 신호등 제어기로 개선했습니다.

**Summary:**  
This project extends a basic FSM-based traffic signal controller by adding realistic traffic control features such as emergency handling, green time limitation, and night light-off behavior.

---

## 2. Original Traffic Signal Controller

기존 Traffic Signal Controller의 동작 흐름은 다음과 같습니다.

1. 기본 상태는 Main Highway = Green, Country Road = Red입니다.
2. Country Road에 차량이 감지되면 `car_country = 1`이 됩니다.
3. Main Highway는 Green → Yellow → Red로 순차적으로 변합니다.
4. Main Highway가 Red가 된 뒤 Country Road가 Green이 됩니다.
5. Country Road에 차량이 없으면 Country Road가 Yellow로 바뀐 뒤 Main Highway Green 상태로 복귀합니다.

기존 FSM의 일반적인 흐름은 다음과 같이 정리할 수 있습니다.

```text
S0 → S1 → S2 → S3 → S4 → S0
```

| State | Main Highway | Country Road | Meaning |
|---|---|---|---|
| S0 | Green | Red | 기본 상태 |
| S1 | Yellow | Red | Main Highway Yellow |
| S2 | Red | Red | All Red |
| S3 | Red | Green | Country Road Green |
| S4 | Red | Yellow | Country Road Yellow |

---

## 3. Improvement Direction

기존 Traffic Signal Controller에 다음 세 가지 기능을 추가했습니다.

### 3.1 Emergency Mode

Main Highway에 응급차량이 감지되는 상황을 가정했습니다.

`emergency = 1`이 입력되면 현재 state와 관계없이 Emergency Mode인 `S5`로 이동합니다. 이 상태에서는 Main Highway가 Green, Country Road가 Red로 출력됩니다.

이 기능은 응급차량이 발생했을 때 일반 신호 흐름보다 우선적으로 Main Highway를 통과시키기 위한 목적입니다.

**Summary:**  
Emergency Mode gives priority to an emergency vehicle on Main Highway by forcing the FSM to move to `S5`, where Main Highway is Green and Country Road is Red.

---

### 3.2 Country Road Green Time Limit

기존 구조에서는 Country Road에 차량이 계속 감지되면 Country Road Green 상태가 계속 유지될 수 있습니다.

이를 개선하기 위해 `green_count` counter와 `GREEN_LIMIT` parameter를 추가했습니다. Country Road Green 상태인 `S3`에서만 `green_count`가 증가하고, `green_count`가 `GREEN_LIMIT`에 도달하면 Country Road에 차량이 계속 감지되어도 `S4`로 이동하도록 설계했습니다.

이 기능은 Country Road Green 상태가 무한히 유지되는 것을 방지하고, Main Highway의 교통 흐름도 다시 확보하기 위한 목적입니다.

**Summary:**  
The green time limit prevents Country Road from staying Green indefinitely by using `green_count` and `GREEN_LIMIT`.

---

### 3.3 Night OFF Mode

야간에는 교통량이 상대적으로 적을 수 있으므로, 두 신호등을 모두 OFF 상태로 만드는 Night OFF Mode를 추가했습니다.

이를 위해 `night_mode` 입력을 추가했고, 기존 2-bit 출력에서 사용하지 않던 `2'b11`을 `OFF` 상태로 정의했습니다.

Night Mode인 `S6`에서는 Main Highway와 Country Road가 모두 OFF로 출력됩니다. 단, Night Mode 중에도 `emergency = 1`이 입력되면 Emergency Mode인 `S5`로 이동하도록 설계했습니다.

**Summary:**  
Night OFF Mode turns both traffic lights OFF using the `2'b11` output code, while still allowing emergency input to override the night state.

---

## 4. Project Goal

이 프로젝트의 목표는 단순히 신호등 상태를 추가하는 것이 아니라, FSM 기반 설계에서 다음 내용을 직접 구현하고 검증하는 것입니다.

- 기존 FSM 구조 확장
- 새로운 입력 신호 추가
- 새로운 state 추가
- counter를 이용한 시간 제한 기능 구현
- Verilog design source 작성
- testbench 기반 입력 시나리오 검증
- Vivado behavioral simulation을 통한 waveform 해석

**Summary:**  
The main goal of this project is to practice FSM extension, Verilog-based sequential logic design, counter-based timing control, and testbench-driven verification using Vivado.

---

## 5. Main Concepts Used

| Concept | Usage in this project |
|---|---|
| FSM | 신호등 상태 전이 구조 설계 |
| Moore Machine | 현재 state에 따라 출력 결정 |
| Counter | Country Road Green 유지 시간 제한 |
| Clock | state 변화 기준 |
| Reset | 초기 상태 S0 복귀 |
| Testbench | 입력 시나리오 기반 기능 검증 |
| Behavioral Simulation | waveform을 통한 동작 확인 |
