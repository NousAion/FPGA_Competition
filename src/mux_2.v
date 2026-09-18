module mux_2(
    input wire a,
    input wire b,
    input wire sel,
    output reg out
);

    always@(*)
        if (sel == 1'b1)
            out = a;
        else
            out = b;


endmodule