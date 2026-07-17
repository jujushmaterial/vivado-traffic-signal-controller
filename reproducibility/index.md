---
layout: default
title: Reproducibility
---

# Reproducibility

Vivado에서 프로젝트를 다시 구성하고 behavioral simulation을 실행하는 절차입니다.

## Requirements

| Item | Value |
|---|---|
| Tool | Vivado 2025.2 |
| HDL | Verilog |
| Design Source | `src/traffic_signal_cntr_improved.v` |
| Testbench | `src/tb_traffic_signal_cntr_improved.v` |
| Verification | Behavioral Simulation |

## 1. Project Creation

1. Vivado에서 새 RTL Project를 생성합니다.
2. FPGA part 또는 board는 simulation만 확인할 경우 임의의 지원 장치를 선택할 수 있습니다.
3. Design Source에 `traffic_signal_cntr_improved.v`를 추가합니다.
4. Simulation Source에 `tb_traffic_signal_cntr_improved.v`를 추가합니다.
5. testbench를 simulation top으로 지정합니다.

## 2. Source Configuration

Design source는 다음 입력과 출력을 사용합니다.

| Signal | Direction | Width |
|---|---:|---:|
| `car_country` | input | 1 |
| `emergency` | input | 1 |
| `night_mode` | input | 1 |
| `clock` | input | 1 |
| `reset` | input | 1 |
| `hwy` | output | 2 |
| `cntry` | output | 2 |

## 3. Simulation

1. **Run Simulation → Run Behavioral Simulation**을 선택합니다.
2. waveform에 다음 신호를 표시합니다.
   - `main_highway_signal`
   - `country_signal`
   - `car_on_countryroad`
   - `emergency`
   - `night_mode`
   - `uut.state`
   - `uut.green_count`
   - `reset`
   - `clock`
3. testbench 전체가 끝날 때까지 simulation을 실행합니다.

## 4. Expected Checks

```text
Reset               → state S0
Normal cycle        → S0→S1→S2→S3→S4→S0
Green limit         → S3 exits after GREEN_LIMIT
Car removed         → S3 exits before GREEN_LIMIT
Emergency           → normal state → S5
Night mode          → S6, both outputs OFF
Night + emergency   → S6→S5→S6
```

## 5. Source Code

<div class="code-action-grid">
  <button class="code-open-button" type="button" data-code-file="src/traffic_signal_cntr_improved.v" data-code-title="Traffic Signal Controller Design Source">
    <strong>Design Source</strong>
    <span>FSM implementation</span>
  </button>
  <button class="code-open-button" type="button" data-code-file="src/tb_traffic_signal_cntr_improved.v" data-code-title="Traffic Signal Controller Testbench">
    <strong>Testbench</strong>
    <span>Simulation input scenarios</span>
  </button>
</div>

## Scope

이 저장소의 검증 범위는 behavioral simulation입니다. FPGA board implementation을 진행하려면 clock divider, XDC pin constraints, physical I/O와 synthesis/implementation 검토가 추가로 필요합니다.
