---
layout: default
title: Simulation Results
---

# Simulation Results

Vivado behavioral simulation에서 확인한 기능별 결과입니다.

## 전체 파형

![Full behavioral simulation](../images/simulation_full.png)

전체 testbench 구간에서 reset, normal cycle, green_count, emergency, night_mode와 두 신호등 출력을 함께 확인했습니다.

## Green Time Limit

![Green count limit](../images/simulation_cycle1_green_count.png)

Country Road Green 상태인 S3에서만 `green_count`가 증가하고, `GREEN_LIMIT`에 도달하면 차량 감지가 유지되어도 S4로 이동했습니다.

## Vehicle Removed Before Limit

![Vehicle removed](../images/simulation_cycle2_car_removed.png)

S3에서 `car_country = 0`이 되면 제한값에 도달하지 않았더라도 S4로 이동했습니다.

## Emergency Priority

![Emergency simulation](../images/simulation_emergency.png)

일반 상태 S0–S4에서 emergency 입력이 들어오면 다음 clock edge에서 S5로 이동했습니다.

## Night OFF Mode

![Night mode simulation](../images/simulation_night_mode.png)

`night_mode = 1`일 때 S6로 이동하고 Main Highway와 Country Road가 모두 `OFF = 2'b11`로 출력되었습니다.

## Night Mode with Emergency

![Night emergency simulation](../images/simulation_night_emergency.png)

Night Mode 중 emergency 입력에 따라 S6 → S5로 이동하고, emergency가 종료된 뒤 night_mode가 유지되면 S5 → S6로 복귀했습니다.

## Verification Summary

| Function | Expected Behavior | Result |
|---|---|---|
| Reset | S0 and default outputs | Pass |
| Normal Cycle | S0 → S1 → S2 → S3 → S4 → S0 | Pass |
| Green Limit | S3 exits at GREEN_LIMIT | Pass |
| Car Removed | S3 exits before limit | Pass |
| Emergency | Any normal state → S5 | Pass |
| Night OFF | S6 outputs OFF/OFF | Pass |
| Night + Emergency | S6 → S5 → S6 | Pass |

[Detailed waveform analysis](../docs/05_simulation_analysis.html)
