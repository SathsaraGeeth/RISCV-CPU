module PCincr (
    input   logic   [31:0]  PC,
    output  logic   [31:0]  PCPlus4
);
    assign PCNext = PC + 4;
endmodule