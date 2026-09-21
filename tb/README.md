# Testbench

新模块测试放在此目录；`sim_tb/` 保留原始 mux 例程以便回归对照。

## 当前第一轮

如果使用 ModelSim/Questa，在仓库根目录执行：

```tcl
vlog rtl/audio/phase_accumulator.v tb/phase_accumulator_tb.v
vsim phase_accumulator_tb
run -all
```

预期最后一行包含：`PASS: phase_accumulator reset, enable, step change, and wraparound`。
