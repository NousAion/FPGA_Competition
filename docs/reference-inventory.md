# Tang Mega 138K 例程清单

## 扫描结论

已扫描以下目录：

- `D:/qqdownload/FPFG_COMPETITION`
- `D:/FPGA_Projects/FPGA_competition`

竞赛资料目录中没有可直接打开的 `.v`、`.sv`、`.gprj`、`.cst` 或 `.sdc` 例程文件，主要内容是 PDF、DOCX 和文本资料。当前项目仓库原本也只有 `mux_2` smoke test，没有音频例程。

此前从官方仓库下载到本机缓存的参考工程：

- 官方仓库：[sipeed/TangMega-138K-example](https://github.com/sipeed/TangMega-138K-example)
- 当前核对提交：`06e7d8b`
- 关键目录：`audio_i2s/`

## `audio_i2s` 内容

官方音频例程包含：

| 文件 | 作用 |
|---|---|
| `top.v` | 时钟、复位、波表和音频驱动的最小顶层 |
| `audio_drive.v` | 16 bit 双声道 I2S 串行发送器，提供 `req` 数据请求 |
| `rom_wave_sine.v` | 256 点波形 ROM 示例 |
| `gowin_osc/gowin_osc.v` | Gowin 内部振荡器 IP 封装 |
| `gowin_pll/gowin_pll.v` | 内部振荡器到音频位时钟的 PLL 封装 |
| `gowin_clkdiv/gowin_clkdiv.v` | 时钟分频 IP 封装 |
| `audio.cst` | 音频引脚约束示例 |

例程说明是输出固定测试波形，适合验证耳机口/功放和 I2S 时序；它不是多声部合成器，也没有交互、声部管理、ADSR 或效果器。

## 不能直接复制的部分

1. 例程工程写的是旧的 `GW5AST-LV138PG484AC2/I1` / `gw5ast138b-010`；当前本机 Gowin IDE 可用的普通 PG484 器件是 `GW5AST-LV138PG484AC1/I0`，B/C 对应 ID 也不同。
2. 例程的 `.gprj` 引用了 `src/gowin_rpll/gowin_rpll.v`，但下载内容中没有该文件，说明它不是当前工程的完整、可复现基线。
3. 例程中的 PLL/OSC/CLKDIV 是器件相关生成物。实际 SOM 已确认是 C 版，应在当前 IDE 中针对 C 版重新生成，不能把旧 IP 当作通用 Verilog 使用。
4. 例程使用历史音频示例复位脚 `rst=F4`；当前项目参考的是 138K Dock 的 `sys_rst_n=AA13`。两者不能同时接入正式顶层。
5. `PA_EN` 为低有效：`0` 开功放，`1` 关闭/静音。

## 参考价值排序

现在最值得复用的是 `audio_drive.v` 的 I2S 帧时序和音频引脚对应关系；波表 ROM 可作为结构参考。时钟 IP、器件头信息和约束必须按本项目实际器件重新生成/确认。

仓库中还有 `pmod_led`、`ws2812`、`ddr_memory`、`hdmi_colorbar`、`sd_card` 等 138K 外设例程，但它们不应进入第一阶段音频关键路径。
