`timescale 1ns/1ps

module adsr_envelope_tb;
    reg clk;
    reg rst_n;
    reg sample_ce;
    reg gate;
    wire [7:0] envelope;
    wire [2:0] state;

    localparam [2:0] IDLE = 3'd0;
    localparam [2:0] ATTACK = 3'd1;
    localparam [2:0] DECAY = 3'd2;
    localparam [2:0] SUSTAIN = 3'd3;
    localparam [2:0] RELEASE = 3'd4;

    integer failures;

    adsr_envelope #(
        .ENV_WIDTH(8),
        .ATTACK_STEP(64),
        .DECAY_STEP(32),
        .SUSTAIN_LEVEL(128),
        .RELEASE_STEP(64)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .sample_ce(sample_ce),
        .gate(gate),
        .envelope(envelope),
        .state(state)
    );

    always #5 clk = ~clk;

    task expect;
        input [2:0] expected_state;
        input [7:0] expected_envelope;
        begin
            if (state !== expected_state || envelope !== expected_envelope) begin
                $display("FAIL t=%0t state=%0d env=%0d (expected state=%0d env=%0d)",
                         $time, state, envelope, expected_state, expected_envelope);
                failures = failures + 1;
            end
        end
    endtask

    task sample;
        begin
            @(posedge clk);
            #1;
        end
    endtask

    initial begin
        clk = 1'b0;
        rst_n = 1'b0;
        sample_ce = 1'b1;
        gate = 1'b0;
        failures = 0;

        #2;
        expect(IDLE, 8'd0);
        #9;
        rst_n = 1'b1;

        // IDLE -> ATTACK, then hold while sample_ce is stopped.
        gate = 1'b1;
        sample;
        expect(ATTACK, 8'd0);
        sample_ce = 1'b0;
        repeat (3) sample;
        expect(ATTACK, 8'd0);
        sample_ce = 1'b1;

        // ATTACK reaches full scale, then DECAY reaches SUSTAIN.
        sample;
        expect(ATTACK, 8'd64);
        sample;
        expect(ATTACK, 8'd128);
        sample;
        expect(ATTACK, 8'd192);
        sample;
        expect(DECAY, 8'd255);
        sample;
        expect(DECAY, 8'd223);
        sample;
        expect(DECAY, 8'd191);
        sample;
        expect(DECAY, 8'd159);
        sample;
        expect(SUSTAIN, 8'd128);

        // Release reaches zero without underflow and returns to IDLE.
        gate = 1'b0;
        sample;
        expect(RELEASE, 8'd128);
        sample;
        expect(RELEASE, 8'd64);
        sample;
        expect(IDLE, 8'd0);
        sample;
        expect(IDLE, 8'd0);

        // Retrigger from IDLE and from RELEASE.
        gate = 1'b1;
        sample;
        expect(ATTACK, 8'd0);
        sample;
        expect(ATTACK, 8'd64);
        gate = 1'b0;
        sample;
        expect(RELEASE, 8'd64);
        gate = 1'b1;
        sample;
        expect(ATTACK, 8'd64);

        if (failures == 0)
            $display("PASS: ADSR reset, sample_ce hold, attack, decay, sustain, release, and retrigger");
        else
            $display("FAILURES: %0d", failures);
        $finish;
    end
endmodule
