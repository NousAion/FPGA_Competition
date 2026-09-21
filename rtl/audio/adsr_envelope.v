`timescale 1ns/1ps

module adsr_envelope #(
    parameter integer ENV_WIDTH     = 16,
    parameter integer ATTACK_STEP   = 1024,
    parameter integer DECAY_STEP    = 256,
    parameter integer SUSTAIN_LEVEL = 49152,
    parameter integer RELEASE_STEP  = 512
) (
    input  wire                 clk,
    input  wire                 rst_n,
    input  wire                 sample_ce,
    input  wire                 gate,
    output reg  [ENV_WIDTH-1:0] envelope,
    output reg  [2:0]           state
);

    localparam [2:0] IDLE    = 3'd0;
    localparam [2:0] ATTACK  = 3'd1;
    localparam [2:0] DECAY   = 3'd2;
    localparam [2:0] SUSTAIN = 3'd3;
    localparam [2:0] RELEASE = 3'd4;

    // The extra bit makes every threshold comparison safe before truncation.
    localparam [ENV_WIDTH:0] MAX_EXT = {1'b0, {ENV_WIDTH{1'b1}}};
    localparam [ENV_WIDTH:0] ATTACK_STEP_EXT  = ATTACK_STEP;
    localparam [ENV_WIDTH:0] DECAY_STEP_EXT   = DECAY_STEP;
    localparam [ENV_WIDTH:0] RELEASE_STEP_EXT = RELEASE_STEP;
    localparam [ENV_WIDTH:0] SUSTAIN_PARAM_EXT = SUSTAIN_LEVEL;
    localparam [ENV_WIDTH:0] SUSTAIN_EXT =
        (SUSTAIN_PARAM_EXT > MAX_EXT) ? MAX_EXT : SUSTAIN_PARAM_EXT;

    reg [ENV_WIDTH-1:0] envelope_next;
    reg [2:0]           state_next;
    reg [ENV_WIDTH:0]   level_ext;
    reg [ENV_WIDTH:0]   sum_ext;

    always @* begin
        envelope_next = envelope;
        state_next    = state;
        level_ext     = {1'b0, envelope};
        sum_ext       = level_ext;

        if (sample_ce === 1'b1) begin
            case (state)
                IDLE: begin
                    envelope_next = {ENV_WIDTH{1'b0}};
                    if (gate === 1'b1)
                        state_next = ATTACK;
                end

                ATTACK: begin
                    if (gate !== 1'b1) begin
                        state_next = (envelope == {ENV_WIDTH{1'b0}}) ? IDLE : RELEASE;
                    end else begin
                        sum_ext = level_ext + ATTACK_STEP_EXT;
                        if (sum_ext >= MAX_EXT) begin
                            envelope_next = {ENV_WIDTH{1'b1}};
                            state_next = DECAY;
                        end else begin
                            envelope_next = sum_ext[ENV_WIDTH-1:0];
                        end
                    end
                end

                DECAY: begin
                    if (gate !== 1'b1) begin
                        state_next = (envelope == {ENV_WIDTH{1'b0}}) ? IDLE : RELEASE;
                    end else if (level_ext <= SUSTAIN_EXT) begin
                        envelope_next = SUSTAIN_EXT[ENV_WIDTH-1:0];
                        state_next = SUSTAIN;
                    end else begin
                        if ((DECAY_STEP_EXT >= level_ext) ||
                            (level_ext - DECAY_STEP_EXT <= SUSTAIN_EXT)) begin
                            envelope_next = SUSTAIN_EXT[ENV_WIDTH-1:0];
                            state_next = SUSTAIN;
                        end else begin
                            envelope_next = level_ext - DECAY_STEP_EXT;
                        end
                    end
                end

                SUSTAIN: begin
                    if (gate !== 1'b1) begin
                        state_next = (envelope == {ENV_WIDTH{1'b0}}) ? IDLE : RELEASE;
                    end else begin
                        envelope_next = SUSTAIN_EXT[ENV_WIDTH-1:0];
                    end
                end

                RELEASE: begin
                    if (gate === 1'b1) begin
                        state_next = ATTACK;
                    end else if (level_ext <= RELEASE_STEP_EXT) begin
                        envelope_next = {ENV_WIDTH{1'b0}};
                        state_next = IDLE;
                    end else begin
                        envelope_next = level_ext - RELEASE_STEP_EXT;
                    end
                end

                default: begin
                    envelope_next = {ENV_WIDTH{1'b0}};
                    state_next = IDLE;
                end
            endcase
        end
    end

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            envelope <= {ENV_WIDTH{1'b0}};
            state    <= IDLE;
        end else begin
            envelope <= envelope_next;
            state    <= state_next;
        end
    end

endmodule
