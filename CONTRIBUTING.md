# 协作提交说明

1. 从 `main` 创建功能分支，例如 `feat/i2s-tx`。
2. 一个功能模块至少包含 RTL、testbench 和接口/参数说明。
3. 提交前运行 `git diff --check`，确认不会提交 `impl/`、`sim_work/`、`transcript` 或 `*.gprj.user`。
4. Pull Request 写明采样率、时钟域、定点位宽、资源/时序影响和仿真结论。

模块接口有不兼容调整时，应先更新 `docs/project-analysis.md` 中的数据格式或时序约定。
