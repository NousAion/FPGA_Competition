# 当前任务板

目标：在 Tang Mega 138K C 版到货前，完成可仿真的音频积木；到货后先验证固定测试音，再逐步接入交互。

## 第一轮任务

每项任务只能修改自己列出的文件。提交必须包含 RTL、testbench 和仿真结论。负责人可以轮换，不按“主开发/杂务”分层。

| 任务 | 允许修改 | 完成条件 | 依赖 |
|---|---|---|---|
| T-001 相位累加器 | `rtl/audio/phase_accumulator.v`、`tb/phase_accumulator_tb.v` | 复位、sample enable、步长变化、自然回绕均通过仿真 | 无 |
| T-002 ADSR 包络 | `rtl/audio/adsr_envelope.v`、`tb/adsr_envelope_tb.v` | attack/decay/sustain/release 状态可观察且可重复 | 无 |
| T-003 混音限幅 | `rtl/audio/mixer_saturator.v`、`tb/mixer_saturator_tb.v` | 普通相加、正溢出、负溢出通过仿真 | 无 |

三项完成后才做集成，集成任务另开提交，避免三个人同时修改顶层。

## 明天板到后的顺序

1. 核对 C 版丝印、Gowin Programmer 识别和 138K 官方约束。
2. 用独立固定测试音验证 I2S、耳机口和扬声器；`PA_EN=0` 才开启功放。
3. 将 T-001 接入简单波形，确认单声部输出。
4. 再接 T-002、T-003，形成 4 声部基础链路。

## 协作规则

- 每个人一次只认领一个任务；任务完成后交换 review。
- 不要让 AI 修改任务表之外的文件；发现接口问题先记录，不自行扩大范围。
- `main` 只合并通过仿真或综合的提交；生成物不提交。
