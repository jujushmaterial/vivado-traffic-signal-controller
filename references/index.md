---
layout: default
title: References
---

# References

이 페이지는 프로젝트를 이해하고 재현하는 데 필요한 내부 문서와 기술 배경을 정리합니다.

## 프로젝트 내부 자료

- [설계 상세보기](../study/)
- [FSM Design](../docs/02_fsm_design.html)
- [Verilog Code Explanation](../docs/03_verilog_code_explanation.html)
- [Testbench Design](../docs/04_testbench_design.html)
- [Simulation Analysis](../docs/05_simulation_analysis.html)
- [Design Source](../src/traffic_signal_cntr_improved.v)
- [Testbench Source](../src/tb_traffic_signal_cntr_improved.v)

## 기술 배경

- Verilog HDL module, parameter, reg/wire, procedural block
- Moore finite-state machine structure
- State register, next-state combinational logic, output logic separation
- Non-blocking assignment in clocked always blocks
- Counter-based timing limitation
- Testbench stimulus and behavioral simulation
- Vivado waveform-based functional verification

## 프로젝트에서의 역할

| Reference Area | Project Role |
|---|---|
| Basic traffic-light FSM | S0–S4 normal cycle baseline |
| Moore FSM | Current-state-based traffic-light output |
| Counter logic | Country Road Green time limitation |
| Priority logic | Emergency and night-mode ordering |
| Testbench | Functional scenario verification |
| Vivado simulation | State, counter, input and output waveform analysis |

이 저장소는 수업 프로젝트의 설계 코드와 simulation 결과를 중심으로 정리하며, 외부 저작물을 재배포하지 않습니다.
