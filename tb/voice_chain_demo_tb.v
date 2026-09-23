`timescale 1ns/1ps

module voice_chain_demo_tb;

    reg         clk;
    reg         rst_n;
    reg         sample_ce;
    reg  [31:0] phase_inc0;
    reg  [31:0] phase_inc1;
    reg  [31:0] phase_inc2;
    reg  [31:0] phase_inc3;
    reg         gate0;
    reg         gate1;
    reg         gate2;
    reg         gate3;
    wire signed [23:0] mixed_sample;

    integer failures;
    integer release_seen;

    voice_chain_demo dut (
        .clk(clk),
        .rst_n(rst_n),
        .sample_ce(sample_ce),
        .phase_inc0(phase_inc0),
        .phase_inc1(phase_inc1),
        .phase_inc2(phase_inc2),
        .phase_inc3(phase_inc3),
        .gate0(gate0),
        .gate1(gate1),
        .gate2(gate2),
        .gate3(gate3),
        .mixed_sample(mixed_sample)
    );

    always #5 clk = ~clk;

    task tick;
        begin
            sample_ce = 1'b1;
            @(posedge clk);
            #1;
            sample_ce = 1'b0;
            #1;
        end
    endtask

    task check_equal;
        input [8*48-1:0] test_name;
        input signed [31:0] expected;
        input signed [31:0] actual;
        begin
            if (actual !== expected) begin
                failures = failures + 1;
                $display("FAIL: %0s expected=%0d actual=%0d", test_name, expected, actual);
            end else begin
                $display("OK:   %0s value=%0d", test_name, actual);
            end
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        sample_ce = 1'b0;
        phase_inc0 = 32'h1000_0000;
        phase_inc1 = 32'h2000_0000;
        phase_inc2 = 32'h3000_0000;
        phase_inc3 = 32'h4000_0000;
        gate0 = 1'b0;
        gate1 = 1'b0;
        gate2 = 1'b0;
        gate3 = 1'b0;
        failures = 0;
        release_seen = 0;

        #2;
        check_equal("reset phase0", 0, dut.phase0);
        check_equal("reset phase1", 0, dut.phase1);
        check_equal("reset phase2", 0, dut.phase2);
        check_equal("reset phase3", 0, dut.phase3);
        check_equal("reset envelope0", 0, dut.envelope0);
        check_equal("reset envelope1", 0, dut.envelope1);
        check_equal("reset envelope2", 0, dut.envelope2);
        check_equal("reset envelope3", 0, dut.envelope3);
        check_equal("reset mixed sample", 0, mixed_sample);

        rst_n = 1'b1;
        tick;

        // With sample_ce low, all registered state and the combinational output hold.
        begin : hold_check
            reg [31:0] phase0_before;
            reg [31:0] phase1_before;
            reg [31:0] phase2_before;
            reg [31:0] phase3_before;
            reg [15:0] envelope0_before;
            reg [15:0] envelope1_before;
            reg [15:0] envelope2_before;
            reg [15:0] envelope3_before;
            reg signed [23:0] mixed_before;

            phase0_before = dut.phase0;
            phase1_before = dut.phase1;
            phase2_before = dut.phase2;
            phase3_before = dut.phase3;
            envelope0_before = dut.envelope0;
            envelope1_before = dut.envelope1;
            envelope2_before = dut.envelope2;
            envelope3_before = dut.envelope3;
            mixed_before = mixed_sample;

            repeat (2) @(posedge clk);
            #1;

            check_equal("sample_ce hold phase0", phase0_before, dut.phase0);
            check_equal("sample_ce hold phase1", phase1_before, dut.phase1);
            check_equal("sample_ce hold phase2", phase2_before, dut.phase2);
            check_equal("sample_ce hold phase3", phase3_before, dut.phase3);
            check_equal("sample_ce hold envelope0", envelope0_before, dut.envelope0);
            check_equal("sample_ce hold envelope1", envelope1_before, dut.envelope1);
            check_equal("sample_ce hold envelope2", envelope2_before, dut.envelope2);
            check_equal("sample_ce hold envelope3", envelope3_before, dut.envelope3);
            check_equal("sample_ce hold mixed sample", mixed_before, mixed_sample);
        end

        gate0 = 1'b1;
        gate1 = 1'b1;
        gate2 = 1'b1;
        gate3 = 1'b1;

        // First tick changes IDLE to ATTACK; subsequent ticks raise the envelope.
        tick;
        if ((dut.state0 !== 3'd1) || (dut.state1 !== 3'd1) ||
            (dut.state2 !== 3'd1) || (dut.state3 !== 3'd1)) begin
            failures = failures + 1;
            $display("FAIL: gates did not enter ATTACK");
        end else begin
            $display("OK:   all voices entered ATTACK");
        end

        repeat (8) tick;
        if ((dut.envelope0 == 0) || (dut.envelope1 == 0) ||
            (dut.envelope2 == 0) || (dut.envelope3 == 0)) begin
            failures = failures + 1;
            $display("FAIL: one or more envelopes stayed at zero");
        end else begin
            $display("OK:   all envelopes became non-zero");
        end

        if ((dut.voice_sample0 == 0) || (dut.voice_sample1 == 0) ||
            (dut.voice_sample2 == 0) || (dut.voice_sample3 == 0)) begin
            failures = failures + 1;
            $display("FAIL: one or more voices stayed at zero");
        end else begin
            $display("OK:   all four voices are non-zero");
        end

        if ((dut.phase0 == dut.phase1) || (dut.phase1 == dut.phase2) ||
            (dut.phase2 == dut.phase3)) begin
            failures = failures + 1;
            $display("FAIL: phase increments did not produce distinct phases");
        end else begin
            $display("OK:   phase increments produced distinct phases");
        end

        if ((dut.state0 == 3'd2) || (dut.state0 == 3'd3) ||
            (dut.state1 == 3'd2) || (dut.state1 == 3'd3) ||
            (dut.state2 == 3'd2) || (dut.state2 == 3'd3) ||
            (dut.state3 == 3'd2) || (dut.state3 == 3'd3)) begin
            $display("OK:   at least one envelope reached DECAY or SUSTAIN");
        end

        gate0 = 1'b0;
        gate1 = 1'b0;
        gate2 = 1'b0;
        gate3 = 1'b0;
        tick;
        if ((dut.state0 !== 3'd4) || (dut.state1 !== 3'd4) ||
            (dut.state2 !== 3'd4) || (dut.state3 !== 3'd4)) begin
            failures = failures + 1;
            $display("FAIL: gates did not enter RELEASE");
        end else begin
            release_seen = 1;
            $display("OK:   all voices entered RELEASE");
        end

        repeat (140) begin
            tick;
            if ((dut.state0 == 3'd4) || (dut.state1 == 3'd4) ||
                (dut.state2 == 3'd4) || (dut.state3 == 3'd4))
                release_seen = 1;
        end

        if (!release_seen) begin
            failures = failures + 1;
            $display("FAIL: RELEASE state was not observed");
        end

        if ((dut.state0 !== 3'd0) || (dut.state1 !== 3'd0) ||
            (dut.state2 !== 3'd0) || (dut.state3 !== 3'd0) ||
            (dut.envelope0 !== 0) || (dut.envelope1 !== 0) ||
            (dut.envelope2 !== 0) || (dut.envelope3 !== 0) ||
            (mixed_sample !== 0)) begin
            failures = failures + 1;
            $display("FAIL: released voices did not return to zero");
        end else begin
            $display("OK:   all voices released to IDLE and mixed output is zero");
        end

        if (failures == 0)
            $display("PASS: voice_chain_demo integration tests passed");
        else
            $display("FAIL: voice_chain_demo integration tests failed, errors=%0d", failures);

        $finish;
    end

endmodule
