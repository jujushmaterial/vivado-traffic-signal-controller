# 03. Verilog Code Explanation

## 1. Design Source Overview

`traffic_signal_cntr_improved.v`는 개선된 Traffic Signal Controller의 Verilog design source입니다.

기존 Traffic Signal Controller 구조에 `emergency`, `night_mode`, `green_count` 기능을 추가하여 Emergency Mode, Night OFF Mode, Country Road Green Time Limit을 구현했습니다.

전체 코드는 FSM style-1 구조를 기반으로 작성되었습니다.

1. State Register
2. Next State Logic
3. Output Logic

실제 Verilog source code는 아래 파일에 정리되어 있습니다.

- [`src/traffic_signal_cntr_improved.v`](../src/traffic_signal_cntr_improved.v)

**Summary:**  
This document explains the Verilog design source of the improved traffic signal controller, focusing on module I/O, parameters, state register, next state logic, counter behavior, and Moore output logic.

---

## 2. Module Declaration and I/O Structure

```verilog
module traffic_signal_cntr_improved (
    hwy,
    cntry,
    car_country,
    emergency,
    night_mode,
    clock,
    reset
);
```

`traffic_signal_cntr_improved`는 개선된 Traffic Signal Controller의 top module입니다.

입력 신호는 Country Road 차량 감지, 응급차량 감지, 야간 상태, clock, reset으로 구성됩니다. 출력 신호는 Main Highway와 Country Road의 신호등 상태입니다.

| Signal | Direction | Width | Description |
|---|---:|---:|---|
| `car_country` | input | 1-bit | Country Road 차량 감지 |
| `emergency` | input | 1-bit | Main Highway 응급차량 감지 |
| `night_mode` | input | 1-bit | 야간 상태 입력 |
| `clock` | input | 1-bit | state 변화 기준 clock |
| `reset` | input | 1-bit | 초기화 입력 |
| `hwy` | output | 2-bit | Main Highway 신호등 출력 |
| `cntry` | output | 2-bit | Country Road 신호등 출력 |

```verilog
output [1:0] hwy, cntry;
reg    [1:0] hwy, cntry;
```

`hwy`와 `cntry`는 `always` 블록 내부에서 값이 할당되므로 `reg`로 선언했습니다.  
Verilog에서 `reg`는 반드시 실제 register만 의미하는 것이 아니라, procedural block 내부에서 값을 저장하거나 할당받는 신호를 의미합니다.

**Summary:**  
The module receives traffic-related input signals and outputs 2-bit traffic light states for Main Highway and Country Road. Since outputs are assigned inside an `always` block, they are declared as `reg`.

---

## 3. Light Color Parameter

```verilog
parameter RED    = 2'd0;
parameter YELLOW = 2'd1;
parameter GREEN  = 2'd2;
parameter OFF    = 2'd3;
```

신호등 색상은 2-bit parameter로 정의했습니다.

| Light | Decimal | Binary |
|---|---:|---|
| `RED` | 0 | `2'b00` |
| `YELLOW` | 1 | `2'b01` |
| `GREEN` | 2 | `2'b10` |
| `OFF` | 3 | `2'b11` |

기존 Traffic Signal Controller에서는 Red, Yellow, Green만 사용했습니다.  
2-bit 출력은 총 4개의 값을 표현할 수 있으므로, 사용하지 않던 `2'b11`을 `OFF` 상태로 새롭게 정의했습니다.

`OFF`는 Night OFF Mode인 `S6`에서 두 신호등을 모두 소등하기 위해 사용됩니다.

**Summary:**  
The unused 2-bit output value `2'b11` is defined as `OFF` and used to represent the Night OFF Mode.

---

## 4. State Parameter

```verilog
parameter S0 = 3'd0;
parameter S1 = 3'd1;
parameter S2 = 3'd2;
parameter S3 = 3'd3;
parameter S4 = 3'd4;
parameter S5 = 3'd5;
parameter S6 = 3'd6;
```

FSM state는 `S0`부터 `S6`까지 총 7개로 정의했습니다.

| State | Encoding | Main Highway | Country Road | Description |
|---|---|---|---|---|
| `S0` | `3'b000` | Green | Red | 기본 상태 |
| `S1` | `3'b001` | Yellow | Red | Main Highway Yellow |
| `S2` | `3'b010` | Red | Red | All Red |
| `S3` | `3'b011` | Red | Green | Country Road Green |
| `S4` | `3'b100` | Red | Yellow | Country Road Yellow |
| `S5` | `3'b101` | Green | Red | Emergency Mode |
| `S6` | `3'b110` | OFF | OFF | Night OFF Mode |

`S0~S4`는 기존 Traffic Signal Controller의 일반 동작 상태입니다.  
`S5`는 Emergency Mode를 위해 추가한 상태이고, `S6`는 Night OFF Mode를 위해 추가한 상태입니다.

총 7개의 state가 필요하므로 3-bit state register를 사용했습니다.  
3-bit는 총 8개의 값을 표현할 수 있으므로 `3'b111`은 사용하지 않는 상태입니다. 이 예외 상태에 대해서는 `default` 조건에서 `S0`으로 복귀하도록 설계했습니다.

**Summary:**  
Seven FSM states are defined using 3-bit state encoding. `S5` and `S6` are newly added for Emergency Mode and Night OFF Mode.

---

## 5. Internal State Variables

```verilog
reg [2:0] state;
reg [2:0] next_state;
```

`state`는 현재 FSM 상태를 저장하는 변수입니다.  
`next_state`는 다음 clock edge에서 이동할 상태를 저장하는 변수입니다.

FSM style-1 구조에서는 현재 상태 저장과 다음 상태 계산을 분리합니다.

- `state`: 현재 상태 저장
- `next_state`: 조합논리에서 계산된 다음 상태
- clock 상승 edge에서 `state <= next_state` 수행

이렇게 분리하면 state transition을 명확하게 해석할 수 있고, simulation waveform에서도 현재 상태와 다음 상태의 관계를 확인하기 쉽습니다.

**Summary:**  
`state` stores the current FSM state, while `next_state` stores the next state determined by combinational logic.

---

## 6. Green Count and GREEN_LIMIT

```verilog
parameter GREEN_LIMIT = 3'd3;
reg [2:0] green_count;
```

`green_count`는 Country Road Green 상태인 `S3`에 머무른 시간을 세기 위한 counter입니다.

기존 구조에서는 Country Road에 차량이 계속 감지되면 `S3`가 계속 유지될 수 있습니다.  
이를 방지하기 위해 `green_count`와 `GREEN_LIMIT`을 추가했습니다.

동작 원리는 다음과 같습니다.

1. `S3` 상태에서만 `green_count` 증가
2. `green_count < GREEN_LIMIT`이면 `S3` 유지
3. `green_count >= GREEN_LIMIT`이면 `S4`로 이동
4. `S3`가 아닌 상태에서는 `green_count = 0`

`GREEN_LIMIT`은 simulation에서 동작을 쉽게 확인하기 위해 `3`으로 설정했습니다.

**Summary:**  
`green_count` limits the duration of Country Road Green state. It increases only in `S3` and forces transition to `S4` when it reaches `GREEN_LIMIT`.

---

## 7. State Register and Green Counter

```verilog
always @(posedge clock) begin
    if (reset) begin
        state <= S0;
        green_count <= 3'd0;
    end else begin
        state <= next_state;

        if (state == S3) begin
            if (green_count < GREEN_LIMIT)
                green_count <= green_count + 3'd1;
            else
                green_count <= green_count;
        end else begin
            green_count <= 3'd0;
        end
    end
end
```

이 블록은 clock의 상승 edge에서만 실행됩니다.

### 7.1 Reset 동작

```verilog
if (reset) begin
    state <= S0;
    green_count <= 3'd0;
end
```

`reset = 1`이면 FSM은 초기 상태인 `S0`으로 돌아갑니다.  
동시에 `green_count`도 0으로 초기화됩니다.

초기 상태를 명확히 지정해야 simulation 시작 시 예측 가능한 상태에서 동작을 확인할 수 있습니다.

### 7.2 State Update

```verilog
state <= next_state;
```

`reset = 0`이면 현재 state가 `next_state`로 업데이트됩니다.  
이 업데이트는 clock 상승 edge에서만 발생하므로, FSM은 clock에 동기화된 sequential logic으로 동작합니다.

### 7.3 Green Counter 동작

```verilog
if (state == S3) begin
    if (green_count < GREEN_LIMIT)
        green_count <= green_count + 3'd1;
    else
        green_count <= green_count;
end else begin
    green_count <= 3'd0;
end
```

`green_count`는 현재 state가 `S3`일 때만 증가합니다.  
`S3`가 아닌 다른 상태에서는 0으로 초기화됩니다.

이 구조를 통해 `green_count`는 Country Road Green 유지 시간만 측정하는 counter로 동작합니다.

### 7.4 Non-blocking Assignment 해석

이 블록에서는 `<=` non-blocking assignment를 사용했습니다.

Verilog의 non-blocking assignment는 같은 clock edge에서 오른쪽 값을 먼저 평가하고, 이후 왼쪽 변수에 업데이트를 예약합니다.  
따라서 다음 코드에서:

```verilog
state <= next_state;

if (state == S3) begin
    ...
end
```

`if (state == S3)` 조건은 업데이트된 `next_state`가 아니라, clock edge 이전의 기존 `state` 값을 기준으로 판단됩니다.

이 때문에 waveform에서 `green_count`는 `S3`에 진입한 바로 그 순간이 아니라, `S3`에 머무르는 다음 clock부터 증가하는 것처럼 보일 수 있습니다.

**Summary:**  
The state register updates the FSM state on the rising edge of `clock`, while `green_count` increases only when the previous current state is `S3`. This behavior is caused by non-blocking assignment in sequential logic.

---

## 8. Next State Logic

```verilog
always @(*) begin
    next_state = state;

    case (state)
        ...
    endcase
end
```

Next State Logic은 조합논리 블록입니다.

`always @(*)`는 블록 내부에서 사용되는 입력이나 state 값이 바뀔 때마다 next state를 다시 계산한다는 의미입니다.

```verilog
next_state = state;
```

이 구문은 기본값을 현재 state로 유지한다는 의미입니다.  
명시되지 않은 조건에서 latch가 생기는 것을 방지하고, 조건에 해당하지 않을 경우 현재 상태를 유지하도록 만드는 역할을 합니다.

**Summary:**  
The next state logic is written as combinational logic using `always @(*)`. The default assignment `next_state = state` prevents unintended latch behavior.

---

## 9. State-by-State Next State Explanation

### 9.1 S0: Main Highway Green / Country Road Red

```verilog
S0: begin
    if (emergency)
        next_state = S5;
    else if (night_mode)
        next_state = S6;
    else if (car_country)
        next_state = S1;
    else
        next_state = S0;
end
```

`S0`는 기본 상태입니다.

우선순위는 다음과 같습니다.

1. `emergency = 1`이면 `S5`
2. `night_mode = 1`이면 `S6`
3. `car_country = 1`이면 `S1`
4. 그 외에는 `S0` 유지

`emergency`를 가장 먼저 확인하기 때문에, 응급차량 감지는 일반 차량 감지나 야간 모드보다 높은 우선순위를 가집니다.

---

### 9.2 S1: Main Highway Yellow / Country Road Red

```verilog
S1: begin
    if (emergency)
        next_state = S5;
    else
        next_state = S2;
end
```

`S1`은 Main Highway가 Yellow인 상태입니다.

Emergency가 발생하면 `S5`로 이동하고, 그렇지 않으면 일반 흐름에 따라 `S2`로 이동합니다.

---

### 9.3 S2: All Red

```verilog
S2: begin
    if (emergency)
        next_state = S5;
    else
        next_state = S3;
end
```

`S2`는 Main Highway와 Country Road가 모두 Red인 상태입니다.

Emergency가 발생하면 `S5`로 이동하고, 그렇지 않으면 Country Road Green 상태인 `S3`로 이동합니다.

---

### 9.4 S3: Country Road Green

```verilog
S3: begin
    if (emergency)
        next_state = S5;
    else if (car_country && (green_count < GREEN_LIMIT))
        next_state = S3;
    else
        next_state = S4;
end
```

`S3`는 Country Road가 Green인 상태입니다.

동작 조건은 다음과 같습니다.

| Condition | Next State |
|---|---|
| `emergency = 1` | `S5` |
| `car_country = 1` and `green_count < GREEN_LIMIT` | `S3` 유지 |
| `car_country = 0` or `green_count >= GREEN_LIMIT` | `S4` |

이 구문을 통해 Country Road에 차량이 계속 감지되더라도 `green_count`가 제한값에 도달하면 `S4`로 이동합니다.

또한 차량이 사라져 `car_country = 0`이 되면 제한 시간과 관계없이 `S4`로 이동합니다.

---

### 9.5 S4: Country Road Yellow

```verilog
S4: begin
    if (emergency)
        next_state = S5;
    else
        next_state = S0;
end
```

`S4`는 Country Road가 Yellow인 상태입니다.

Emergency가 발생하면 `S5`로 이동하고, 그렇지 않으면 기본 상태인 `S0`으로 복귀합니다.

---

### 9.6 S5: Emergency Mode

```verilog
S5: begin
    if (emergency)
        next_state = S5;
    else if (night_mode)
        next_state = S6;
    else
        next_state = S0;
end
```

`S5`는 Emergency Mode입니다.

Emergency가 계속 유지되면 `S5`에 머무릅니다.  
Emergency가 종료되었을 때 `night_mode = 1`이면 `S6`로 이동하고, `night_mode = 0`이면 `S0`으로 복귀합니다.

이 구조는 야간 중 응급차량이 발생했을 때도 자연스럽게 동작합니다.  
Night Mode 중 `S6 → S5`로 이동한 뒤, emergency가 종료되면 다시 `S6`로 복귀할 수 있습니다.

---

### 9.7 S6: Night OFF Mode

```verilog
S6: begin
    if (emergency)
        next_state = S5;
    else if (night_mode)
        next_state = S6;
    else
        next_state = S0;
end
```

`S6`는 Night OFF Mode입니다.

Emergency가 발생하면 `S5`로 이동합니다.  
Emergency가 없고 night mode가 유지되면 `S6`에 머무릅니다.  
night mode가 종료되면 `S0`으로 복귀합니다.

중요한 점은 `S6`에서 `car_country` 조건을 사용하지 않았다는 것입니다.  
따라서 야간 상태에서는 Country Road 차량 감지가 FSM state 변화에 영향을 주지 않습니다.

---

### 9.8 Default Case

```verilog
default: begin
    next_state = S0;
end
```

3-bit state는 총 8개의 상태를 표현할 수 있지만, 실제 설계에서는 `S0~S6`까지 7개만 사용합니다.

따라서 사용하지 않는 상태인 `3'b111` 등이 발생할 경우를 대비하여 `default` 조건에서 `S0`으로 복귀하도록 설계했습니다.

이는 예외 상태가 발생했을 때 FSM을 안정적인 기본 상태로 되돌리기 위한 설계입니다.

**Summary:**  
The next state logic defines normal operation, emergency priority, green time limitation, Night OFF Mode, and safe recovery from unused states.

---

## 10. Output Logic

```verilog
always @(*) begin
    case (state)
        ...
    endcase
end
```

Output Logic은 Moore FSM 방식으로 작성했습니다.

Moore FSM에서는 출력이 입력값에 직접 의해 결정되지 않고, 현재 state에 의해 결정됩니다.

따라서 `car_country`, `emergency`, `night_mode`는 Output Logic에서 직접 사용되지 않습니다.  
이 입력들은 Next State Logic에서 다음 state를 결정하는 데 사용되고, 최종 출력은 현재 state에 의해 결정됩니다.

| State | hwy | cntry |
|---|---|---|
| `S0` | `GREEN` | `RED` |
| `S1` | `YELLOW` | `RED` |
| `S2` | `RED` | `RED` |
| `S3` | `RED` | `GREEN` |
| `S4` | `RED` | `YELLOW` |
| `S5` | `GREEN` | `RED` |
| `S6` | `OFF` | `OFF` |

`S5`는 Emergency Mode이므로 Main Highway는 Green, Country Road는 Red로 출력됩니다.

`S6`는 Night OFF Mode이므로 두 신호등이 모두 OFF로 출력됩니다.

**Summary:**  
The output logic follows the Moore FSM principle, where outputs depend only on the current state.

---

## 11. Design Summary

이 Verilog design source는 다음 구조를 통해 개선된 Traffic Signal Controller를 구현합니다.

- `parameter`를 이용한 light color 및 state encoding
- `state`, `next_state`를 이용한 FSM 상태 저장 및 전이
- `green_count`를 이용한 Country Road Green 유지 시간 제한
- `emergency` 입력을 가장 높은 우선순위로 처리
- `night_mode` 입력을 이용한 Night OFF Mode 구현
- Moore FSM 방식의 output logic
- `default` 조건을 통한 예외 state 처리

**Summary:**  
The Verilog source implements an improved traffic signal controller by combining FSM-based state control, emergency priority, counter-based green time limitation, night mode behavior, and Moore output logic.
