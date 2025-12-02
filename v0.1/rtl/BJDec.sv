module BJDec (
    input  logic [31:0] ALUResult,
    input  logic        Jump,
    input  logic        BranchPos,
    input  logic        BranchNeg,
    output logic        PCSrc
);
    assign PCSrc = ((|ALUResult) & BranchPos) || 
                   (~(|ALUResult) & BranchNeg) ||
                   Jump;
endmodule