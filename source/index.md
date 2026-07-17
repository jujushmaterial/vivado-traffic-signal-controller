---
layout: default
title: Verilog Source Code
---

# Verilog Source Code

아래 버튼을 누르면 페이지 이동 없이 VS Code형 창에서 전체 Verilog 파일을 확인할 수 있습니다.

## Design Source

<div class="code-action-grid">
  <button class="code-open-button" type="button" data-code-file="src/traffic_signal_cntr_improved.v" data-code-title="Traffic Signal Controller Design Source">
    <strong>traffic_signal_cntr_improved.v</strong>
    <span>7-state Moore FSM, green_count, next-state and output logic</span>
  </button>
</div>

## Testbench

<div class="code-action-grid">
  <button class="code-open-button" type="button" data-code-file="src/tb_traffic_signal_cntr_improved.v" data-code-title="Traffic Signal Controller Testbench">
    <strong>tb_traffic_signal_cntr_improved.v</strong>
    <span>Reset, normal cycle, emergency, night mode, night emergency scenarios</span>
  </button>
</div>

## Code Flow

```text
Clock and reset
→ State register
→ Next-state combinational logic
→ Moore output logic
→ Testbench stimulus
→ Vivado behavioral simulation
```

## Related Documents

- [FSM Design](../docs/02_fsm_design.html)
- [Verilog Code Explanation](../docs/03_verilog_code_explanation.html)
- [Testbench Design](../docs/04_testbench_design.html)
- [Simulation Analysis](../docs/05_simulation_analysis.html)
