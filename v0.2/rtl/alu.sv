`timescale 1ns/1ps

module alu (
    input  logic [31:0] A,
    input  logic [31:0] B,
    input  logic [3:0]  alu_ctrl,
    output logic [31:0] RESULT,
    output logic        ZERO
);
    localparam ADD  = 4'b0000;
    localparam SUB  = 4'b0001;
    localparam AND  = 4'b0010;
    localparam OR   = 4'b0011;
    localparam XOR  = 4'b0100;
    localparam SLL  = 4'b0101;
    localparam SRL  = 4'b0110;
    localparam SRA  = 4'b0111;
    localparam SLT  = 4'b1000;
    localparam SLTU = 4'b1001;

    always_comb begin
        case (alu_ctrl)
            ADD:  RESULT = A + B;
            SUB:  RESULT = A - B;
            AND:  RESULT = A & B;
            OR:   RESULT = A | B;
            XOR:  RESULT = A ^ B;
            SLL:  RESULT = A << B[4:0];
            SRL:  RESULT = A >> B[4:0];
            SRA:  RESULT = $signed(A) >>> B[4:0];
            SLT:  RESULT = {31'b0, ($signed(A) < $signed(B))};
            SLTU: RESULT = {31'b0, (A < B)};
            default: RESULT = 32'b0;
        endcase
        ZERO = (RESULT == 32'b0);
    end
endmodule