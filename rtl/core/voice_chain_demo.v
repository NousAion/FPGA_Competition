// Four-voice audio chain used for interface and data-path simulation.
module voice_chain_demo (
    input  wire                  clk,
    input  wire                  rst_n,
    input  wire                  sample_ce,
    input  wire [31:0]           phase_inc0,
    input  wire [31:0]           phase_inc1,
    input  wire [31:0]           phase_inc2,
    input  wire [31:0]           phase_inc3,
    input  wire                  gate0,
    input  wire                  gate1,
    input  wire                  gate2,
    input  wire                  gate3,
    output wire signed [23:0]    mixed_sample
);

    localparam integer ENV_WIDTH = 16;

    // Keep four full-scale voices below the mixer limit during this demo.
    localparam signed [23:0] VOICE_AMPLITUDE = 24'sd2097151;

    wire [31:0] phase0;
    wire [31:0] phase1;
    wire [31:0] phase2;
    wire [31:0] phase3;

    wire [ENV_WIDTH-1:0] envelope0;
    wire [ENV_WIDTH-1:0] envelope1;
    wire [ENV_WIDTH-1:0] envelope2;
    wire [ENV_WIDTH-1:0] envelope3;

    wire [2:0] state0;
    wire [2:0] state1;
    wire [2:0] state2;
    wire [2:0] state3;

    wire signed [23:0] square0;
    wire signed [23:0] square1;
    wire signed [23:0] square2;
    wire signed [23:0] square3;

    // 40 bits are sufficient for a signed 24-bit sample times a 16-bit envelope.
    wire signed [39:0] square0_ext;
    wire signed [39:0] square1_ext;
    wire signed [39:0] square2_ext;
    wire signed [39:0] square3_ext;
    wire signed [39:0] envelope0_ext;
    wire signed [39:0] envelope1_ext;
    wire signed [39:0] envelope2_ext;
    wire signed [39:0] envelope3_ext;
    wire signed [39:0] product0;
    wire signed [39:0] product1;
    wire signed [39:0] product2;
    wire signed [39:0] product3;

    wire signed [23:0] voice_sample0;
    wire signed [23:0] voice_sample1;
    wire signed [23:0] voice_sample2;
    wire signed [23:0] voice_sample3;

    phase_accumulator u_phase0 (
        .clk(clk), .rst_n(rst_n), .sample_ce(sample_ce),
        .phase_inc(phase_inc0), .phase(phase0)
    );

    phase_accumulator u_phase1 (
        .clk(clk), .rst_n(rst_n), .sample_ce(sample_ce),
        .phase_inc(phase_inc1), .phase(phase1)
    );

    phase_accumulator u_phase2 (
        .clk(clk), .rst_n(rst_n), .sample_ce(sample_ce),
        .phase_inc(phase_inc2), .phase(phase2)
    );

    phase_accumulator u_phase3 (
        .clk(clk), .rst_n(rst_n), .sample_ce(sample_ce),
        .phase_inc(phase_inc3), .phase(phase3)
    );

    adsr_envelope u_envelope0 (
        .clk(clk), .rst_n(rst_n), .sample_ce(sample_ce), .gate(gate0),
        .envelope(envelope0), .state(state0)
    );

    adsr_envelope u_envelope1 (
        .clk(clk), .rst_n(rst_n), .sample_ce(sample_ce), .gate(gate1),
        .envelope(envelope1), .state(state1)
    );

    adsr_envelope u_envelope2 (
        .clk(clk), .rst_n(rst_n), .sample_ce(sample_ce), .gate(gate2),
        .envelope(envelope2), .state(state2)
    );

    adsr_envelope u_envelope3 (
        .clk(clk), .rst_n(rst_n), .sample_ce(sample_ce), .gate(gate3),
        .envelope(envelope3), .state(state3)
    );

    // The phase MSB selects the positive or negative half of a square wave.
    assign square0 = phase0[31] ? -VOICE_AMPLITUDE : VOICE_AMPLITUDE;
    assign square1 = phase1[31] ? -VOICE_AMPLITUDE : VOICE_AMPLITUDE;
    assign square2 = phase2[31] ? -VOICE_AMPLITUDE : VOICE_AMPLITUDE;
    assign square3 = phase3[31] ? -VOICE_AMPLITUDE : VOICE_AMPLITUDE;

    assign square0_ext = {{16{square0[23]}}, square0};
    assign square1_ext = {{16{square1[23]}}, square1};
    assign square2_ext = {{16{square2[23]}}, square2};
    assign square3_ext = {{16{square3[23]}}, square3};

    assign envelope0_ext = {{24{1'b0}}, envelope0};
    assign envelope1_ext = {{24{1'b0}}, envelope1};
    assign envelope2_ext = {{24{1'b0}}, envelope2};
    assign envelope3_ext = {{24{1'b0}}, envelope3};

    assign product0 = square0_ext * envelope0_ext;
    assign product1 = square1_ext * envelope1_ext;
    assign product2 = square2_ext * envelope2_ext;
    assign product3 = square3_ext * envelope3_ext;

    // The envelope is Q0.16, so divide the product by 2^16.
    assign voice_sample0 = product0 >>> ENV_WIDTH;
    assign voice_sample1 = product1 >>> ENV_WIDTH;
    assign voice_sample2 = product2 >>> ENV_WIDTH;
    assign voice_sample3 = product3 >>> ENV_WIDTH;

    mixer_saturator #(
        .SAMPLE_WIDTH(24)
    ) u_mixer (
        .voice0(voice_sample0),
        .voice1(voice_sample1),
        .voice2(voice_sample2),
        .voice3(voice_sample3),
        .mixed_sample(mixed_sample)
    );

endmodule
