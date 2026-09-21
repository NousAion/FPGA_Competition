# 音频模块接口冻结 v0

第一轮三个模块必须严格使用本页接口。端口名、方向、位宽和时序没有负责人确认不得自行修改。

## 统一约定

- 时钟域：所有时序模块使用同一个 `clk`。
- 复位：`rst_n` 为低有效异步复位；`rst_n=0` 时输出进入确定初值。
- 采样使能：`sample_ce` 是 `clk` 域内的单周期脉冲，只有为 1 时才更新音频状态。
- 音频样本：有符号二进制定点，24 位，范围 `-8388608` 到 `8388607`。
- 第一轮不负责音符频率计算、I2S 引脚和真实传感器；这些属于后续集成任务。

## T-001 `phase_accumulator`

文件：`rtl/audio/phase_accumulator.v`

```verilog
module phase_accumulator #(
    parameter integer PHASE_WIDTH = 32
) (
    input  wire                   clk,
    input  wire                   rst_n,
    input  wire                   sample_ce,
    input  wire [PHASE_WIDTH-1:0] phase_inc,
    output reg  [PHASE_WIDTH-1:0] phase
);
```

在 `sample_ce=1` 的上升沿执行 `phase <= phase + phase_inc`；溢出自然回绕。复位值为 0。

## T-002 `adsr_envelope`

文件：`rtl/audio/adsr_envelope.v`

```verilog
module adsr_envelope #(
    parameter integer ENV_WIDTH = 16,
    parameter integer ATTACK_STEP = 1024,
    parameter integer DECAY_STEP = 256,
    parameter integer SUSTAIN_LEVEL = 49152,
    parameter integer RELEASE_STEP = 512
) (
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  sample_ce,
    input  wire                  gate,
    output reg  [ENV_WIDTH-1:0]  envelope,
    output reg  [2:0]             state
);
```

状态编码固定为：`0=IDLE`、`1=ATTACK`、`2=DECAY`、`3=SUSTAIN`、`4=RELEASE`。`gate=1` 表示按下/保持，`gate=0` 表示释放。`envelope` 范围为 0 到全量程；状态只在 `sample_ce=1` 时推进。

## T-003 `mixer_saturator`

文件：`rtl/audio/mixer_saturator.v`

```verilog
module mixer_saturator #(
    parameter integer SAMPLE_WIDTH = 24
) (
    input  wire signed [SAMPLE_WIDTH-1:0] voice0,
    input  wire signed [SAMPLE_WIDTH-1:0] voice1,
    input  wire signed [SAMPLE_WIDTH-1:0] voice2,
    input  wire signed [SAMPLE_WIDTH-1:0] voice3,
    output wire signed [SAMPLE_WIDTH-1:0] mixed_sample
);
```

这是纯组合模块，不带 `clk`、`rst_n` 或 `sample_ce`。内部必须使用更宽保护位相加，然后饱和到 24 位；不能发生二进制截断回绕。上层在 `sample_ce` 时采样 `mixed_sample`。

## 集成顺序

```text
phase -> waveform -> envelope scaling -> voice0..voice3 -> mixer_saturator
```

如果单个模块的实现需要增加端口，先报告接口问题，不要直接改 v0；可以在集成层增加适配逻辑。
