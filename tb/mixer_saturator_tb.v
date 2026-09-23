`timescale 1ns/1ps

module mixer_saturator_tb;

    localparam integer SAMPLE_WIDTH = 24;
    localparam signed [SAMPLE_WIDTH-1:0] SAMPLE_MAX = {1'b0, {(SAMPLE_WIDTH-1){1'b1}}};
    localparam signed [SAMPLE_WIDTH-1:0] SAMPLE_MIN = {1'b1, {(SAMPLE_WIDTH-1){1'b0}}};

    reg signed [SAMPLE_WIDTH-1:0] voice0;
    reg signed [SAMPLE_WIDTH-1:0] voice1;
    reg signed [SAMPLE_WIDTH-1:0] voice2;
    reg signed [SAMPLE_WIDTH-1:0] voice3;
    wire signed [SAMPLE_WIDTH-1:0] mixed_sample;

    integer failures;

    mixer_saturator #(
        .SAMPLE_WIDTH(SAMPLE_WIDTH)
    ) dut (
        .voice0(voice0),
        .voice1(voice1),
        .voice2(voice2),
        .voice3(voice3),
        .mixed_sample(mixed_sample)
    );

    task check_output;
        input [8*32-1:0] test_name;
        input signed [SAMPLE_WIDTH-1:0] expected;
        begin
            #1;
            if (mixed_sample !== expected) begin
                failures = failures + 1;
                $display("FAIL: %0s expected=%0d actual=%0d", test_name, expected, mixed_sample);
            end else begin
                $display("OK:   %0s output=%0d", test_name, mixed_sample);
            end
        end
    endtask

    initial begin
        failures = 0;
        voice0 = 0;
        voice1 = 0;
        voice2 = 0;
        voice3 = 0;
        check_output("zero input", 0);

        voice0 = 24'sd123456;
        check_output("single positive voice", 24'sd123456);

        voice0 = -24'sd234567;
        check_output("single negative voice", -24'sd234567);

        voice0 = 24'sd1000000;
        voice1 = -24'sd250000;
        voice2 = 24'sd500000;
        voice3 = 24'sd125000;
        check_output("four voice sum", 24'sd1375000);

        voice0 = 24'sd5000000;
        voice1 = 24'sd4000000;
        voice2 = 24'sd3000000;
        voice3 = 24'sd2000000;
        check_output("positive saturation", SAMPLE_MAX);

        voice0 = -24'sd5000000;
        voice1 = -24'sd4000000;
        voice2 = -24'sd3000000;
        voice3 = -24'sd2000000;
        check_output("negative saturation", SAMPLE_MIN);

        if (failures == 0)
            $display("PASS");
        else
            $display("FAIL: %0d test(s) failed", failures);

        $finish;
    end

endmodule
