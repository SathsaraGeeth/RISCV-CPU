`timescale 1ns/1ps

module singleCycleCPU (
    input logic clk,
    input logic rst_n
);

logic [31:0] PCPlus4;
logic [31:0] PCTarget;
logic PCSrc;

mux2 #(32) Mux_PCSource (
    .a(PCPlus4),
    .b(PCTarget),
    .sel(PCSrc),
    .y(PCNext)
);

logic [31:0] PCNext;
logic [31:0] PC;

register #(32) PCReg (
    .clk(clk),
    .rst_n(rst_n),
    .we(1'b1),
    .D(PCNext),
    .Q(PC)
);

logic [31:0] Instr;

iMem IMem (
    .A(PC),
    .RD(Instr)
);



adder Adder_PCPlus4 (
    .IN1(PC),
    .IN2(32'd4),
    .OUT(PCPlus4)
);

logic [31:0] SrcA;
logic [31:0] WriteData;
logic [31:0] Result;
logic        RegWrite;

regFile RegFile (
    .clk(clk),
    .rst_n(rst_n),
    .we3(RegWrite),
    .A1(Instr[19:15]),
    .A2(Instr[24:20]),
    .A3(Instr[11:7]),
    .WD3(Result),
    .RD1(SrcA),
    .RD2(WriteData)
);

logic [1:0] ImmSrc;
logic [31:0] ImmExt;

extend Extend (
    .IN(Instr),
    .signal(ImmSrc),
    .OUT(ImmExt)
);

adder Adder_PCTarget (
    .IN1(PC),
    .IN2(ImmExt),
    .OUT(PCTarget)
);

logic ALUSrc;
logic [31:0] SrcB;

mux2 #(32) Mux_SrcB (
    .a(WriteData),
    .b(ImmExt),
    .sel(ALUSrc),
    .y(SrcB)
);

logic [3:0] ALUControl;
logic Zero;
logic [31:0] ALUResult;

alu ALU (
    .A(SrcA),
    .B(SrcB),
    .alu_ctrl(ALUControl),
    .RESULT(ALUResult),
    .ZERO(Zero)
);

logic MemWrite;
logic [31:0] ReadData;

dMem DMem (
    .clk(clk),
    .we(MemWrite),
    .A(ALUResult),
    .WD(WriteData),
    .RD(ReadData)
);

logic [1:0] ResultSrc;

mux3 Mux_Result (
    .a(ALUResult),
    .b(ReadData),
    .c(PCPlus4),
    .sel(ResultSrc),
    .y(Result)
);

decoder Decoder (
    .Instr(Instr),
    .Zero(Zero),
    .PCSrc(PCSrc),
    .ResultSrc(ResultSrc),
    .MemWrite(MemWrite),
    .ALUControl(ALUControl),
    .ALUSrc(ALUSrc),
    .ImmSrc(ImmSrc),
    .RegWrite(RegWrite)
);

endmodule
