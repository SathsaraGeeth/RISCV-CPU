`timescale 1ns/1ps

module mux3 #(parameter WIDTH = 32) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic [WIDTH-1:0] c,
    input  logic [1:0]        sel,
    output logic [WIDTH-1:0] y
);
    always_comb begin
        case(sel)
            2'b00: y = a;
            2'b01: y = b;
            2'b10: y = c;
            default: y = '0;
        endcase
    end
endmodule
