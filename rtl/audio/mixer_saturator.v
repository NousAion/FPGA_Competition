module mixer_saturator #(
    parameter integer SAMPLE_WIDTH = 24
) (
    input  wire signed [SAMPLE_WIDTH-1:0] voice0,
    input  wire signed [SAMPLE_WIDTH-1:0] voice1,
    input  wire signed [SAMPLE_WIDTH-1:0] voice2,
    input  wire signed [SAMPLE_WIDTH-1:0] voice3,
    output wire signed [SAMPLE_WIDTH-1:0] mixed_sample
);

    localparam integer ACC_WIDTH = SAMPLE_WIDTH + 2;

    wire signed [ACC_WIDTH-1:0] sum;
    wire signed [ACC_WIDTH-1:0] sample_max;
    wire signed [ACC_WIDTH-1:0] sample_min;

    assign sum = {{2{voice0[SAMPLE_WIDTH-1]}}, voice0}
               + {{2{voice1[SAMPLE_WIDTH-1]}}, voice1}
               + {{2{voice2[SAMPLE_WIDTH-1]}}, voice2}
               + {{2{voice3[SAMPLE_WIDTH-1]}}, voice3};

    assign sample_max = {{2{1'b0}}, 1'b0, {(SAMPLE_WIDTH-1){1'b1}}};
    assign sample_min = {{2{1'b1}}, 1'b1, {(SAMPLE_WIDTH-1){1'b0}}};

    assign mixed_sample = (sum > sample_max) ? {1'b0, {(SAMPLE_WIDTH-1){1'b1}}} :
                          (sum < sample_min) ? {1'b1, {(SAMPLE_WIDTH-1){1'b0}}} :
                                               sum[SAMPLE_WIDTH-1:0];

endmodule
