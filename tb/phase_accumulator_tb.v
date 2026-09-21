`timescale 1ns/1ps

module phase_accumulator_tb;
    reg         clk;
    reg         rst_n;
    reg         sample_ce;
    reg  [7:0]  phase_inc;
    wire [7:0]  phase;

    phase_accumulator #(
        .PHASE_WIDTH(8)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .sample_ce(sample_ce),
        .phase_inc(phase_inc),
        .phase(phase)
    );

    always #5 clk = ~clk;

    task expect_phase;
        input [7:0] expected;
        begin
            #1;
            if (phase !== expected) begin
                $display("FAIL: expected phase=%h, got phase=%h at t=%0t", expected, phase, $time);
                $finish;
            end
        end
    endtask

    initial begin
        clk       = 1'b0;
        rst_n     = 1'b0;
        sample_ce = 1'b0;
        phase_inc = 8'd0;

        #12;
        rst_n = 1'b1;
        @(posedge clk);
        expect_phase(8'h00);

        phase_inc = 8'd3;
        sample_ce = 1'b1;
        @(posedge clk);
        expect_phase(8'h03);
        @(posedge clk);
        expect_phase(8'h06);

        sample_ce = 1'b0;
        @(posedge clk);
        expect_phase(8'h06);

        phase_inc = 8'hff;
        sample_ce = 1'b1;
        @(posedge clk);
        expect_phase(8'h05);

        rst_n = 1'b0;
        #1;
        expect_phase(8'h00);

        rst_n     = 1'b1;
        phase_inc = 8'hff;
        @(posedge clk);
        expect_phase(8'hff);
        @(posedge clk);
        expect_phase(8'hfe);

        $display("PASS: phase_accumulator reset, enable, step change, and wraparound");
        $finish;
    end
endmodule
