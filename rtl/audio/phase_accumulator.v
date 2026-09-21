// Per-voice phase accumulator. The phase wraps naturally at PHASE_WIDTH bits.
module phase_accumulator #(
    parameter integer PHASE_WIDTH = 32
) (
    input  wire                    clk,
    input  wire                    rst_n,
    input  wire                    sample_ce,
    input  wire [PHASE_WIDTH-1:0]  phase_inc,
    output reg  [PHASE_WIDTH-1:0]  phase
);

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            phase <= {PHASE_WIDTH{1'b0}};
        else if (sample_ce)
            phase <= phase + phase_inc;
    end

endmodule
