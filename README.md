# FPGA Competition — 高云选题二

基于 FPGA 的实时多音色合成电子乐器引擎。

当前工程器件为 Gowin GW5AT-60B。项目分析、链路和模块规划见 [docs/project-analysis.md](docs/project-analysis.md)。

## 目录

- `src/`：现有 Gowin 工程入口与旧例程
- `rtl/`：按功能划分的可复用 RTL
- `tb/`：新模块仿真测试
- `sim_tb/`：历史例程仿真，暂保留
- `constraints/`：按具体开发板维护的约束
- `docs/`：设计、接口、测试和报告
- `scripts/`：构建、仿真和报告脚本
- `ip/`：明确登记版本的 Gowin IP

## 开发原则

音频主链路必须由 FPGA HDL 逐样本实时生成；禁止把软核、MCU 或上位机作为音频合成核心。所有时钟域、定点位宽、采样率和延迟预算以 `docs/project-analysis.md` 为单一设计锚点。
