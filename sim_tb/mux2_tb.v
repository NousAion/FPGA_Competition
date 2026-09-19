`timescale 1ns/1ns

module mux2_tb();

    reg a;
    reg b;
    reg sel;
    wire out;

    mux_2 mux2_inst0(
        .a(a), .b(b), .sel(sel), .out(out)
    );

    initial begin
        a = 1'b0;
        b = 1'b0;
        sel = 1'b0;

        #10 a = 1'b1; b = 1'b0; sel = 1'b0;
        #10 a = 1'b0; b = 1'b1; sel = 1'b0;
        #10 a = 1'b1; b = 1'b0; sel = 1'b1;
        #10 a = 1'b0; b = 1'b1; sel = 1'b1;

        #10 $stop;
    end

endmodule
