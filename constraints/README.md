# Constraints

当前目标板卡是 Tang Mega 138K（普通 PG484）+ Tang Mega 138K Dock（NEO Dock 系列底板）。

- `boards/tang-mega-138k-audio-reference.cst`：官方音频例程引脚参考，暂不加入 Gowin 工程；
  待真实顶层端口和板卡版本确认后再启用。
- `src/FPGA_competition.cst`：历史 `mux_2` smoke test 约束，仅用于工程可综合性回归，不能用于音频实物验证。

138K B/C 版本、SOM 封装和 NEO Dock 引脚必须以实物及官方 `.cst` 为准，不能把 60K 约束文件直接迁移过来。
