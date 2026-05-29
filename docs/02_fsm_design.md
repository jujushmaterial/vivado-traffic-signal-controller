# 02. FSM Design

## 1. FSM Design Overview

본 프로젝트의 Traffic Signal Controller는 FSM(Finite State Machine)을 기반으로 설계했습니다.

FSM은 현재 state를 저장하고, 입력 조건에 따라 next state를 결정하며, 각 state에 해당하는 출력을 내보내는 구조입니다. 신호등 제어기는 정해진 상태 순서와 입력 조건에 따라 동작해야 하므로 FSM 구조로 설계하기 적합합니다.

기존 Traffic Signal Controller는 `S0~S4`까지의 상태를 사용했습니다. 본 프로젝트에서는 기능 개선을 위해 Emergency Mode인 `S5`와 Night OFF Mode인 `S6`를 추가하여 총 7개의 state를 사용했습니다.

**Summary:**  
This controller is designed as a finite state machine with seven states. The original traffic signal sequence is extended with Emergency Mode and Night OFF Mode.

---

## 2. State Definition

각 state는 Main Highway와 Country Road의 신호등 출력 조합을 의미합니다.

| State | Encoding | Main Highway | Country Road | Description |
|---|---|---|---|---|
| S0 | `3'b000` | Green | Red | 기본 상태 |
| S1 | `3'b001` | Yellow | Red | Main Highway Yellow |
| S2 | `3'b010` | Red | Red | All Red |
| S3 | `3'b011` | Red | Green | Country Road Green |
| S4 | `3'b100` | Red | Yellow | Country Road Yellow |
| S5 | `3'b101` | Green | Red | Emergency Mode |
| S6 | `3'b110` | OFF | OFF | Night OFF Mode |

상태는 총 7개이므로 3-bit state register를 사용했습니다.  
3-bit는 총 8개의 값을 표현할 수 있으므로, 사용하지 않는 `3'b111` 상태가 발생할 수 있습니다. 이를 대비해 Verilog 코드에서는 `default` 조건에서 `S0`으로 복귀하도록 설계했습니다.

**Summary:**  
Seven states are encoded using a 3-bit state register. Since one 3-bit state remains unused, the default case returns the FSM to `S0` for safer operation.

---

## 3. Output Encoding

신호등 출력은 2-bit 값으로 표현했습니다.

| Light | Encoding |
|---|---|
| RED | `2'b00` |
| YELLOW | `2'b01` |
| GREEN | `2'b10` |
| OFF | `2'b11` |

기존 Traffic Signal Controller에서는 Red, Yellow, Green만 사용했지만, 본 프로젝트에서는 Night OFF Mode를 추가하기 위해 남는 출력값인 `2'b11`을 `OFF`로 정의했습니다.

따라서 `S6`에서는 Main Highway와 Country Road가 모두 `OFF = 2'b11`로 출력됩니다.

**Summary:**  
The unused 2-bit output value `2'b11` is defined as OFF and used for Night OFF Mode.

---

## 4. Moore FSM Structure

본 프로젝트는 Moore FSM 구조를 따릅니다.

Moore FSM에서는 출력이 입력값에 직접 결정되는 것이 아니라, 현재 state에 의해 결정됩니다.  
즉, `car_country`, `emergency`, `night_mode`는 출력값을 직접 만들지 않고, 다음 state를 결정하는 조건으로만 사용됩니다.

예를 들면 다음과 같습니다.

| Current State | Output |
|---|---|
| `S0` | `hwy = GREEN`, `cntry = RED` |
| `S3` | `hwy = RED`, `cntry = GREEN` |
| `S5` | `hwy = GREEN`, `cntry = RED` |
| `S6` | `hwy = OFF`, `cntry = OFF` |

이 구조를 사용하면 입력 변화가 출력에 즉시 반영되는 것이 아니라, state transition을 거쳐 출력이 정해지므로 상태 기반 제어 흐름을 명확하게 만들 수 있습니다.

**Summary:**  
The controller uses a Moore FSM structure, where outputs are determined only by the current state, while inputs are used to determine the next state.

---

## 5. State Transition Rules

### 5.1 S0: Main Highway Green / Country Road Red

`S0`는 기본 상태입니다. Main Highway는 Green이고 Country Road는 Red입니다.

전이 조건은 다음과 같습니다.

| Condition | Next State | Meaning |
|---|---|---|
| `emergency = 1` | `S5` | Emergency Mode 진입 |
| `emergency = 0`, `night_mode = 1` | `S6` | Night OFF Mode 진입 |
| `emergency = 0`, `night_mode = 0`, `car_country = 1` | `S1` | Country Road 차량 감지 |
| 그 외 | `S0` | 기본 상태 유지 |

`S0`에서는 emergency가 가장 높은 우선순위를 가지며, 그 다음으로 night mode, 그 다음으로 Country Road 차량 감지를 확인합니다.

---

### 5.2 S1: Main Highway Yellow / Country Road Red

`S1`은 Main Highway가 Green에서 Red로 바뀌기 전에 Yellow를 출력하는 상태입니다.

| Condition | Next State | Meaning |
|---|---|---|
| `emergency = 1` | `S5` | Emergency Mode 진입 |
| `emergency = 0` | `S2` | All Red 상태로 이동 |

---

### 5.3 S2: Main Highway Red / Country Road Red

`S2`는 Main Highway와 Country Road가 모두 Red인 상태입니다.  
이는 Main Highway에서 Country Road로 통행 우선권이 넘어가기 전의 안정적인 중간 상태로 볼 수 있습니다.

| Condition | Next State | Meaning |
|---|---|---|
| `emergency = 1` | `S5` | Emergency Mode 진입 |
| `emergency = 0` | `S3` | Country Road Green 상태로 이동 |

---

### 5.4 S3: Main Highway Red / Country Road Green

`S3`는 Country Road가 Green인 상태입니다.  
이 상태에서는 `green_count`를 이용하여 Country Road Green 유지 시간을 제한합니다.

| Condition | Next State | Meaning |
|---|---|---|
| `emergency = 1` | `S5` | Emergency Mode 진입 |
| `car_country = 1` and `green_count < GREEN_LIMIT` | `S3` | Country Road Green 유지 |
| `car_country = 0` or `green_count >= GREEN_LIMIT` | `S4` | Country Road Green 종료 |

이 설계를 통해 Country Road에 차량이 계속 감지되어도 Green 상태가 무한히 유지되지 않습니다.  
또한 Country Road 차량이 사라지면 `GREEN_LIMIT`에 도달하지 않았더라도 `S4`로 이동합니다.

---

### 5.5 S4: Main Highway Red / Country Road Yellow

`S4`는 Country Road가 Green에서 Red로 바뀌기 전 Yellow를 출력하는 상태입니다.

| Condition | Next State | Meaning |
|---|---|---|
| `emergency = 1` | `S5` | Emergency Mode 진입 |
| `emergency = 0` | `S0` | 기본 상태로 복귀 |

---

### 5.6 S5: Emergency Mode

`S5`는 Emergency Mode입니다.  
Main Highway는 Green, Country Road는 Red로 출력됩니다.

| Condition | Next State | Meaning |
|---|---|---|
| `emergency = 1` | `S5` | Emergency Mode 유지 |
| `emergency = 0` and `night_mode = 1` | `S6` | Night OFF Mode로 복귀 |
| `emergency = 0` and `night_mode = 0` | `S0` | 기본 상태로 복귀 |

Emergency Mode가 끝난 뒤에는 `night_mode` 상태를 확인합니다.  
야간 상태가 유지 중이면 `S6`로 돌아가고, 야간 상태가 아니면 `S0`으로 복귀합니다.

이 구조를 통해 야간 중 응급차량이 발생한 경우에도, 응급상황 종료 후 다시 Night OFF Mode로 돌아갈 수 있습니다.

---

### 5.7 S6: Night OFF Mode

`S6`는 Night OFF Mode입니다.  
Main Highway와 Country Road가 모두 OFF로 출력됩니다.

| Condition | Next State | Meaning |
|---|---|---|
| `emergency = 1` | `S5` | Emergency Mode 진입 |
| `emergency = 0` and `night_mode = 1` | `S6` | Night OFF Mode 유지 |
| `emergency = 0` and `night_mode = 0` | `S0` | 기본 상태로 복귀 |

`S6`에서는 `car_country` 조건을 사용하지 않습니다.  
따라서 야간 상태에서는 Country Road에 차량이 감지되어도 state 변화에 영향을 주지 않습니다.

**Summary:**  
State transitions prioritize emergency handling, then night mode, and finally normal traffic flow. In Night OFF Mode, `car_country` is ignored, while emergency input can still move the FSM to `S5`.

---

## 6. Priority of Input Conditions

본 설계에서 입력 조건의 우선순위는 다음과 같습니다.

1. `emergency`
2. `night_mode`
3. `car_country`
4. `green_count`

가장 중요한 입력은 `emergency`입니다.  
`S0~S4`, `S6` 어느 상태에 있더라도 `emergency = 1`이 입력되면 Emergency Mode인 `S5`로 이동합니다.

`night_mode`는 기본적으로 `S0`에서 `S6`로 진입하는 조건이며, Emergency Mode 종료 후 복귀 상태를 결정할 때도 사용됩니다.

`car_country`는 일반 신호등 동작에서 Country Road 차량 감지를 표현하는 입력입니다.  
다만 `S6`에서는 `car_country`를 사용하지 않아, Night OFF Mode에서는 차량 감지가 state 변화에 영향을 주지 않도록 설계했습니다.

`green_count`는 `S3`에서 Country Road Green 유지 시간을 제한하기 위한 조건입니다.

**Summary:**  
The highest priority input is `emergency`, followed by `night_mode`, normal vehicle detection, and green time limitation.

---

## 7. FSM Style-1 Structure

수업에서 배운 FSM style-1 구조를 기준으로 코드를 작성했습니다.

FSM style-1은 일반적으로 다음 세 부분으로 나누어 설계합니다.

| Block | Description |
|---|---|
| State Register | 현재 state를 clock에 맞춰 저장 |
| Next State Logic | 현재 state와 입력 조건으로 next state 결정 |
| Output Logic | 현재 state에 따라 출력 결정 |

본 프로젝트에서도 다음과 같이 역할을 분리했습니다.

- `State Register`: `always @(posedge clock)`에서 `state <= next_state`
- `Next State Logic`: `always @(*)`에서 `case(state)`를 이용해 next state 결정
- `Output Logic`: `always @(*)`에서 현재 state에 따라 `hwy`, `cntry` 출력 결정

이 구조는 state 저장, 상태 전이, 출력 결정을 분리하기 때문에 FSM 동작을 해석하고 검증하기 쉽습니다.

**Summary:**  
The Verilog design follows the FSM style-1 structure by separating the state register, next state logic, and output logic.

---

## 8. Design Intention

이 FSM 설계의 핵심 의도는 다음과 같습니다.

- 기존 `S0~S4` 상태를 유지하여 기본 Traffic Signal Controller 흐름을 보존
- `S5`를 추가하여 emergency 입력에 대한 우선 제어 구현
- `S6`를 추가하여 Night OFF Mode 구현
- `OFF = 2'b11`을 정의하여 야간 소등 상태 표현
- `green_count`를 이용해 Country Road Green 유지 시간 제한
- `default` 조건을 통해 사용하지 않는 state 발생 시 `S0`으로 복귀

이를 통해 단순한 신호등 제어기에서 벗어나, 예외 상황과 시간 제한을 포함한 FSM 제어 구조를 구현했습니다.

**Summary:**  
The FSM extends the original traffic controller while preserving its basic flow and adding emergency priority, night mode, green time limitation, and safe default behavior.
