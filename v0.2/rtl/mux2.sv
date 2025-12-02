`timescale 1ns/1ps

module mux2 #(parameter WIDTH = 32) (
    input  logic [WIDTH-1:0] a,
    input  logic [WIDTH-1:0] b,
    input  logic             sel,
    output logic [WIDTH-1:0] y
);
    assign y = sel ? b : a;
endmodule
