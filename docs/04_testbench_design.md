# 04. Testbench Design

## 1. Testbench Overview

`tb_traffic_signal_cntr_improved.v`는 개선된 Traffic Signal Controller가 의도한 대로 동작하는지 확인하기 위한 Verilog testbench입니다.

Testbench는 실제 하드웨어 회로가 아니라, 설계한 module에 입력 신호를 시간 순서대로 넣어주고 출력과 state 변화를 확인하기 위한 simulation용 코드입니다.

본 프로젝트에서는 다음 기능들을 중심으로 검증했습니다.

- Reset 동작
- 일반 신호등 cycle 동작
- Country Road Green Time Limit
- Country Road 차량이 사라졌을 때의 state transition
- Emergency Mode 우선순위
- Night OFF Mode
- Night Mode 중 Emergency 발생 및 복귀 동작

실제 testbench source code는 아래 파일에 정리되어 있습니다.

- [`src/tb_traffic_signal_cntr_improved.v`](../src/tb_traffic_signal_cntr_improved.v)

**Summary:**  
This document explains the Verilog testbench used to verify reset behavior, normal traffic cycles, green time limitation, emergency priority, Night OFF Mode, and the interaction between Night Mode and Emergency Mode.

---

## 2. Testbench Signal Declaration

```verilog
wire [1:0] main_highway_signal;
wire [1:0] country_signal;

reg car_on_countryroad;
reg emergency;
reg night_mode;
reg reset;
reg clock;
```

Testbench에서는 design source의 출력과 입력을 연결하기 위해 `wire`와 `reg`를 사용했습니다.

| Signal | Type | Role |
|---|---|---|
| `main_highway_signal` | wire | design source의 `hwy` 출력을 받는 신호 |
| `country_signal` | wire | design source의 `cntry` 출력을 받는 신호 |
| `car_on_countryroad` | reg | Country Road 차량 감지 입력 |
| `emergency` | reg | Main Highway 응급차량 감지 입력 |
| `night_mode` | reg | 야간 상태 입력 |
| `reset` | reg | 초기화 입력 |
| `clock` | reg | FSM 동작 기준 clock |

`wire`는 design module에서 나온 출력을 testbench에서 받아오기 위해 사용했습니다.  
반대로 `reg`는 testbench 내부에서 직접 값을 바꿔가며 입력 자극을 주기 위해 사용했습니다.

**Summary:**  
Output signals from the design are connected to `wire`, while input stimulus signals are declared as `reg` so that the testbench can control them over time.

---

## 3. UUT: Unit Under Test

```verilog
traffic_signal_cntr_improved uut (
    .hwy(main_highway_signal),
    .cntry(country_signal),
    .car_country(car_on_countryroad),
    .emergency(emergency),
    .night_mode(night_mode),
    .clock(clock),
    .reset(reset)
);
```

`uut`는 Unit Under Test의 의미로, testbench 안에서 실제로 검증할 design module을 instance화한 것입니다.

여기서는 `traffic_signal_cntr_improved` module을 불러와 testbench의 신호들과 연결했습니다.

| Design Source Port | Testbench Signal |
|---|---|
| `hwy` | `main_highway_signal` |
| `cntry` | `country_signal` |
| `car_country` | `car_on_countryroad` |
| `emergency` | `emergency` |
| `night_mode` | `night_mode` |
| `clock` | `clock` |
| `reset` | `reset` |

이 연결을 통해 testbench에서 입력 신호를 바꾸면 design source가 반응하고, 그 결과가 `main_highway_signal`, `country_signal`로 나타납니다.

**Summary:**  
The UUT instance connects the testbench stimulus signals to the design module and allows the testbench to observe the design outputs.

---

## 4. Clock Generation

```verilog
initial begin
    clock = 1'b0;
    forever #20 clock = ~clock;
end
```

FSM은 `posedge clock`에서 state가 업데이트되도록 설계되어 있습니다.  
따라서 testbench에서는 일정한 주기의 clock을 만들어줘야 합니다.

위 코드에서 `clock`은 20 ns마다 반전됩니다.

```text
20 ns low → 20 ns high → 20 ns low → ...
```

따라서 전체 clock period는 40 ns입니다.

| Item | Value |
|---|---|
| Half period | 20 ns |
| Full period | 40 ns |
| State update timing | `posedge clock` |

이 clock을 기준으로 `state`가 `next_state`로 업데이트되고, `green_count`도 `S3` 상태에서 증가합니다.

**Summary:**  
The testbench generates a 40 ns clock period by toggling `clock` every 20 ns. The FSM state is updated only at the rising edge of this clock.

---

## 5. Input Stimulus Structure

Testbench의 입력 자극은 하나의 `initial` block 안에서 순서대로 구성했습니다.

```verilog
initial begin
    reset = 1'b1;
    car_on_countryroad = 1'b0;
    emergency = 1'b0;
    night_mode = 1'b0;

    ...
end
```

처음에는 모든 입력을 기본값으로 설정합니다.

| Signal | Initial Value | Meaning |
|---|---:|---|
| `reset` | `1` | 초기화 상태 |
| `car_on_countryroad` | `0` | Country Road 차량 없음 |
| `emergency` | `0` | 응급차량 없음 |
| `night_mode` | `0` | 일반 낮 상태 |
| `clock` | `0` | clock 초기값 |

이후 각 test section에서 입력값을 바꿔가며 FSM의 state transition과 output을 확인했습니다.

**Summary:**  
The input stimulus block initializes all input signals and then applies different scenarios to verify each added function.

---

## 6. Why Inputs Are Changed at `negedge clock`

Testbench에서는 많은 입력값을 `@(negedge clock)` 이후에 변경했습니다.

```verilog
@(negedge clock);
car_on_countryroad = 1'b1;
```

FSM state는 `posedge clock`에서 업데이트됩니다.  
따라서 입력값을 `negedge clock`에서 미리 바꿔두면, 다음 `posedge clock`에서 안정된 입력값을 기준으로 state transition이 발생합니다.

이 방식은 simulation에서 입력 변화와 state 변화 시점을 명확하게 구분하기 위한 목적입니다.

예를 들어:

1. `negedge clock`에서 `car_on_countryroad = 1`로 변경
2. 다음 `posedge clock`에서 FSM이 이 값을 읽음
3. `S0 → S1` 전이 발생

즉, 입력을 clock 상승 edge 직전에 미리 준비해두는 구조입니다.

**Summary:**  
Input values are changed at the negative edge so that they are stable before the next positive edge, where the FSM state is updated.

---

## 7. Test 0: Reset

```verilog
// Test 0. Reset
// Expected: state = S0
// hwy = GREEN(10), cntry = RED(00)
```

Reset test는 FSM이 정상적으로 초기 상태로 돌아가는지 확인하기 위한 부분입니다.

`reset = 1`이면 design source의 state register에서:

```verilog
state <= S0;
green_count <= 3'd0;
```

으로 초기화됩니다.

따라서 reset 이후 예상 상태는 다음과 같습니다.

| Signal / State | Expected Value |
|---|---|
| `state` | `S0` |
| `green_count` | `0` |
| `hwy` | `GREEN = 2'b10` |
| `cntry` | `RED = 2'b00` |

Reset은 FSM이 예측 가능한 초기 상태에서 시작하도록 만드는 중요한 입력입니다.

**Summary:**  
The reset test verifies that the FSM returns to `S0` and initializes `green_count` to zero.

---

## 8. Definition of Normal Cycle

본 testbench에서 `Cycle`은 Country Road에 차량이 감지되어 일반 신호등 동작이 한 번 진행되는 흐름을 의미합니다.

즉, `car_country = 1`이 입력된 뒤 다음과 같은 상태 흐름을 거쳐 다시 기본 상태로 돌아오는 과정을 하나의 normal cycle로 보았습니다.

```text
S0 → S1 → S2 → S3 → S4 → S0
```

| State | Meaning |
|---|---|
| `S0` | Main Highway Green / Country Road Red |
| `S1` | Main Highway Yellow / Country Road Red |
| `S2` | Main Highway Red / Country Road Red |
| `S3` | Main Highway Red / Country Road Green |
| `S4` | Main Highway Red / Country Road Yellow |
| `S0` | 기본 상태 복귀 |

이 cycle을 기준으로 Country Road Green Time Limit과 `car_country` 입력의 영향을 각각 확인했습니다.

**Summary:**  
A normal cycle means the FSM moves from `S0` through the normal traffic sequence and returns to `S0`.

---

## 9. Test 1: Normal Cycle 1 - Green Count Limit

```verilog
// Test 1. Normal cycle 1
// car_country remains 1
// Expected:
// S0 -> S1 -> S2 -> S3
// S3 is maintained until green_count reaches GREEN_LIMIT
// Then S3 -> S4 -> S0
```

첫 번째 normal cycle에서는 `car_on_countryroad = 1`을 계속 유지했습니다.

목표는 Country Road에 차량이 계속 감지되는 상황에서도 `S3`, 즉 Country Road Green 상태가 무한히 유지되지 않는지 확인하는 것입니다.

예상 흐름은 다음과 같습니다.

```text
S0 → S1 → S2 → S3 → S3 유지 → S4 → S0
```

`S3` 상태에서는 `green_count`가 증가합니다.  
`green_count < GREEN_LIMIT`이면 `S3`를 유지하고, `green_count >= GREEN_LIMIT`이 되면 `S4`로 이동합니다.

| Condition | Expected State |
|---|---|
| `car_country = 1`, `green_count < GREEN_LIMIT` | `S3` 유지 |
| `car_country = 1`, `green_count >= GREEN_LIMIT` | `S4` 이동 |

이 test는 Country Road에 차량이 계속 있어도 Green 상태가 제한 시간 이후 종료되는지 확인하기 위한 것입니다.

**Summary:**  
Normal Cycle 1 verifies that Country Road Green does not last indefinitely when `car_country` remains high.

---

## 10. Test 2: Normal Cycle 2 - Car Removed at S3

```verilog
// Test 2. Normal cycle 2
// car_country becomes 0 before GREEN_LIMIT
// Expected:
// S0 -> S1 -> S2 -> S3
// In S3, car_country becomes 0
// Then S3 -> S4 -> S0
```

두 번째 normal cycle에서는 처음에는 `car_on_countryroad = 1`로 시작하여 `S3`까지 이동합니다.

이후 `S3` 상태에서 `car_on_countryroad = 0`으로 변경했습니다.

목표는 Country Road 차량이 사라졌을 때, `green_count`가 `GREEN_LIMIT`에 도달하지 않았더라도 `S4`로 이동하는지 확인하는 것입니다.

예상 흐름은 다음과 같습니다.

```text
S0 → S1 → S2 → S3 → S4 → S0
```

`S3`의 next state logic은 다음 조건을 사용합니다.

```verilog
else if (car_country && (green_count < GREEN_LIMIT))
    next_state = S3;
else
    next_state = S4;
```

따라서 `car_country = 0`이 되면 조건식이 false가 되어 `S4`로 이동합니다.

| Condition | Expected State |
|---|---|
| `car_country = 1`, `green_count < GREEN_LIMIT` | `S3` 유지 |
| `car_country = 0` | `S4` 이동 |

이 test는 `car_country` 입력이 `S3`의 next state 결정에 정상적으로 반영되는지 확인합니다.

**Summary:**  
Normal Cycle 2 verifies that the FSM exits `S3` when the Country Road vehicle is no longer detected, even before `GREEN_LIMIT` is reached.

---

## 11. Test 3: Emergency at S0~S4

Emergency test는 `S0~S4` 어느 상태에 있더라도 `emergency = 1`이 입력되면 `S5`로 이동하는지 확인하는 과정입니다.

검증한 경우는 다음과 같습니다.

| Test Case | Expected Transition |
|---|---|
| Emergency at `S0` | `S0 → S5` |
| Emergency at `S1` | `S1 → S5` |
| Emergency at `S2` | `S2 → S5` |
| Emergency at `S3` | `S3 → S5` |
| Emergency at `S4` | `S4 → S5` |

`S5`는 Emergency Mode이며, 출력은 다음과 같습니다.

| Signal | Output |
|---|---|
| `hwy` | `GREEN = 2'b10` |
| `cntry` | `RED = 2'b00` |

Emergency가 종료되어 `emergency = 0`이 되었을 때, `night_mode = 0`이면 `S0`으로 복귀합니다.

이 test는 emergency 입력이 일반 신호등 흐름보다 높은 우선순위를 갖는지 확인하기 위한 것입니다.

**Summary:**  
The emergency tests verify that `emergency` has the highest priority and forces the FSM to move to `S5` from any normal traffic state.

---

## 12. Test 4: Night Mode

```verilog
// Test 4. Night mode check
// Expected:
// S0 -> S6
// hwy = OFF(11), cntry = OFF(11)
// night_mode off -> S0
```

Night Mode test는 `night_mode = 1`일 때 `S6`로 이동하고, 두 신호등이 모두 OFF로 출력되는지 확인하는 과정입니다.

예상 흐름은 다음과 같습니다.

```text
S0 → S6 → S6 유지 → S0
```

`S6`의 출력은 다음과 같습니다.

| Signal | Output |
|---|---|
| `hwy` | `OFF = 2'b11` |
| `cntry` | `OFF = 2'b11` |

또한 `S6` 상태에서 `car_on_countryroad = 1`로 변경해도 state가 변하지 않는지 확인했습니다.

이는 `S6`의 next state logic에서 `car_country` 조건을 사용하지 않았기 때문입니다.

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

따라서 Night Mode에서는 Country Road 차량 감지가 state 변화에 영향을 주지 않습니다.

**Summary:**  
The Night Mode test verifies that the FSM moves to `S6`, turns both lights OFF, and ignores `car_country` while night mode remains active.

---

## 13. Test 5: Night Mode + Emergency

```verilog
// Test 5. Night mode + Emergency
// Expected:
// S0 -> S6
// emergency = 1
// S6 -> S5
// emergency = 0 while night_mode remains 1
// S5 -> S6
// night_mode = 0
// S6 -> S0
```

Night Mode 중 Emergency가 발생하는 복합 상황을 검증했습니다.

예상 흐름은 다음과 같습니다.

```text
S0 → S6 → S5 → S6 → S0
```

동작 순서는 다음과 같습니다.

1. `night_mode = 1`이 되어 `S0 → S6`
2. `S6` 상태에서 `emergency = 1`이 되어 `S6 → S5`
3. `S5`에서 Emergency Mode 출력 발생
4. `emergency = 0`이 되었지만 `night_mode = 1`이 유지되어 `S5 → S6`
5. `night_mode = 0`이 되어 `S6 → S0`

이 test는 야간 상태에서도 emergency 입력이 우선적으로 처리되는지 확인합니다.

또한 emergency가 종료된 뒤에도 야간 상태가 유지 중이면 바로 `S0`으로 돌아가지 않고 `S6`로 복귀하는지 확인합니다.

| Condition | Expected Transition |
|---|---|
| `night_mode = 1` | `S0 → S6` |
| `S6`에서 `emergency = 1` | `S6 → S5` |
| `S5`에서 `emergency = 0`, `night_mode = 1` | `S5 → S6` |
| `S6`에서 `night_mode = 0` | `S6 → S0` |

**Summary:**  
This test verifies that emergency input overrides Night Mode and that the FSM returns to `S6` after the emergency ends if `night_mode` is still active.

---

## 14. `$monitor` Statement

```verilog
$monitor("time=%0t reset=%b car=%b emergency=%b night=%b state=%d green_count=%d hwy=%b cntry=%b",
         $time,
         reset,
         car_on_countryroad,
         emergency,
         night_mode,
         uut.state,
         uut.green_count,
         main_highway_signal,
         country_signal);
```

`$monitor`는 simulation 중 지정한 신호 값이 바뀔 때마다 console에 출력해주는 Verilog system task입니다.

이 프로젝트에서는 다음 신호를 확인하기 위해 사용했습니다.

| Signal | Purpose |
|---|---|
| `$time` | 현재 simulation time 확인 |
| `reset` | reset 입력 확인 |
| `car_on_countryroad` | Country Road 차량 감지 입력 확인 |
| `emergency` | Emergency 입력 확인 |
| `night_mode` | Night Mode 입력 확인 |
| `uut.state` | 내부 FSM state 확인 |
| `uut.green_count` | Country Road Green counter 확인 |
| `main_highway_signal` | Main Highway 출력 확인 |
| `country_signal` | Country Road 출력 확인 |

특히 `uut.state`와 `uut.green_count`를 직접 확인하여, 내부 FSM 상태와 counter 동작이 의도대로 진행되는지 확인할 수 있습니다.

**Summary:**  
The `$monitor` statement prints important input, output, state, and counter values during simulation, making it easier to debug and verify FSM behavior.

---

## 15. Testbench Design Summary

이 testbench는 단순히 입력을 임의로 넣는 것이 아니라, 추가한 기능들이 실제로 동작하는지 단계적으로 검증하도록 구성했습니다.

검증 흐름은 다음과 같습니다.

1. Reset으로 초기 상태 확인
2. Normal Cycle 1로 Green Count Limit 확인
3. Normal Cycle 2로 차량이 사라졌을 때의 state transition 확인
4. `S0~S4` 각 상태에서 Emergency Mode 진입 확인
5. Night OFF Mode 확인
6. Night Mode 중 Emergency 발생 및 복귀 확인
7. `$monitor`를 이용한 내부 state와 counter 확인

이를 통해 design source에서 추가한 기능들이 simulation 상에서 의도대로 동작하는지 확인했습니다.

**Summary:**  
The testbench is organized as a set of targeted verification scenarios, each designed to confirm one specific function of the improved traffic signal controller.
