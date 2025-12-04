`timescale 1ns/1ps

module adder #(parameter WIDTH = 32) (
    input   logic   [WIDTH-1:0]  IN1,
    input   logic   [WIDTH-1:0]  IN2,
    output  logic   [WIDTH-1:0]  OUT
);
    assign OUT = IN1 + IN2;
endmodule
