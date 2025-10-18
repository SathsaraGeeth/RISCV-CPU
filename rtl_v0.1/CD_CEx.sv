module CD_CEx (
    input  logic        clk,
    input  logic        rst_n,
    input   logic       clr,
    input  logic        JumpD,
    input  logic        BranchPosD,
    input  logic        BranchNegD,
    input  logic        RegWriteD,
    input  logic        ALUSrcD,
    input  logic        AddSrcD,
    input  logic        JALRD,
    input  logic        MemWriteD,
    input  logic [3:0]  ALUControlD,
    input  logic [1:0]  ResultSrcD,
    output logic        JumpE,
    output logic        BranchPosE,
    output logic        BranchNegE,
    output logic        RegWriteE,
    output logic        ALUSrcE,
    output logic        AddSrcE,
    output logic        JALRE,
    output logic        MemWriteE,
    output logic [3:0]  ALUControlE,
    output logic [1:0]  ResultSrcE
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n or clr) begin
            JumpE       <= '0;
            BranchPosE  <= '0;
            BranchNegE  <= '0;
            RegWriteE   <= '0;
            ALUSrcE     <= '0;
            AddSrcE     <= '0;
            JALRE       <= '0;
            MemWriteE   <= '0;
            ALUControlE <= '0;
            ResultSrcE  <= '0;
        end else begin
            JumpE       <= JumpD;
            BranchPosE  <= BranchPosD;
            BranchNegE  <= BranchNegD;
            RegWriteE   <= RegWriteD;
            ALUSrcE     <= ALUSrcD;
            AddSrcE     <= AddSrcD;
            JALRE       <= JALRD;
            MemWriteE   <= MemWriteD;
            ALUControlE <= ALUControlD;
            ResultSrcE  <= ResultSrcD;
        end
    end

endmodule