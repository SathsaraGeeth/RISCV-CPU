`timescale 1ns/1ps

module dMem (
    input  logic            clk,
    input  logic            we,
    input  logic   [31:0]   A,
    input  logic   [31:0]   WD,
    output logic   [31:0]   RD
);

logic [31:0] RAM[63:0];

initial begin
    for (int i = 0; i < 64; i = i + 1) begin
        RAM[i] = 32'b0;
    end
end

assign RD = RAM[A[31:2]]; // word aligned
    
always_ff @(posedge clk)
    if (we) begin
        RAM[A[31:2]] <= WD;
    end
endmodule