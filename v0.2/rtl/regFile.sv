`timescale 1ns/1ps

module regFile (
    input   logic           clk,
    input   logic           rst_n,
    input   logic           we3,
    input   logic [4:0]     A1,
    input   logic [4:0]     A2,
    input   logic [4:0]     A3,
    input   logic [31:0]    WD3,
    output  logic [31:0]    RD1,
    output  logic [31:0]    RD2
    );
    logic [31:0] Regs [31:0]; // x0-x31

    always_comb begin
        Regs[0] = 32'b0; // x0 is wired to 0
        RD1 = Regs[A1];
        RD2 = Regs[A2];
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            integer i;
            for (i = 0; i < 32; i = i + 1) begin
                Regs[i] <= 32'b0;
            end
        end else if (we3) begin
            Regs[A3] <= WD3;
        end
    end
endmodule
