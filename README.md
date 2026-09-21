# FPGA Competition — 高云选题二

基于 FPGA 的实时多音色合成电子乐器引擎。

当前目标平台为 **Tang Mega 138K（普通 PG484 SOM）+ Tang Mega 138K Dock（NEO Dock 系列底板）**。已确认 SOM 为 C 版，
工程器件固定为 `GW5AST-138C / GW5AST-LV138PG484AC1/I0`；138K Pro（FPG676A）不属于当前目标。

项目目标分层如下：

- 必须完成：选题二全部基础要求；
- 主线扩展：扩展 1（≥32 个独立复音/合成分量）和扩展 2（≥3 维表情、≥2 种音色、FPGA 内效果器）；
- 冲刺扩展：扩展 3（≤5 ms 确定性延迟与实时视听反馈）；
- 风险兜底：若进度受限，至少保证扩展 1 或扩展 2 中一项完整、可现场验证。

项目分析、链路和模块规划见 [docs/project-analysis.md](docs/project-analysis.md)，目标验收矩阵见
[docs/requirements-traceability.md](docs/requirements-traceability.md)。三人协作总控规则见
[docs/collaboration-master.md](docs/collaboration-master.md)。

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

音频主链路必须由 FPGA HDL 逐样本实时生成；禁止把 AE350、软核、MCU 或上位机作为音频合成核心。
所有时钟域、定点位宽、采样率和延迟预算以 `docs/project-analysis.md` 为单一设计锚点。
