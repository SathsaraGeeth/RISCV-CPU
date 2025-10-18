module RVCPU (
    input  logic clk,
    input  logic rst_n
);
///////////////////////////////////////////////////////////////////////////////////////////////////
/*                                            STAGE1: Fetch                                      */
///////////////////////////////////////////////////////////////////////////////////////////////////

logic [31:0] PCNextF, PCF, PCPlus4F, InstrF;

///////////////////////////////////////////////////////////////////////////////////////////////////
/*                                            STAGE2: Decode                                     */
///////////////////////////////////////////////////////////////////////////////////////////////////

logic [31:0] InstrD, PCD, PCPlus4D;
logic [4:0] rs1D, rs2D, rdD;
logic [31:0] RD1D, RD2D, ImmExtD;
logic JumpD, BranchPosD, BranchNegD, RegWriteD, ALUSrcD, AddSrcD, JALRD, MemWriteD;
logic [3:0] ALUControlD;
logic [2:0] ResultSrcD;
logic StallD, FlushD;

///////////////////////////////////////////////////////////////////////////////////////////////////
/*                                            STAGE3: Execute                                    */
///////////////////////////////////////////////////////////////////////////////////////////////////

logic [31:0] RD1E, RD2E, PCE, ImmExtE, PCPlus4E, PCTargetE;
logic [31:0] ALUSrcAE, ALUSrcBE, ALUResultE, AddSrc1E, AddSrc2E, AdderOutE;
logic JumpE, BranchPosE, BranchNegE, RegWriteE, ALUSrcE, AddSrcE, JALRE, MemWriteE;
logic [3:0] ALUControlE;
logic [2:0] ResultSrcE;
logic [31:0] ALUA, ALUB;
logic [1:0] ForwardAE, ForwardBE;
logic StallE, StallF, FlushE;

///////////////////////////////////////////////////////////////////////////////////////////////////
/*                                            STAGE4: Memory                                     */
///////////////////////////////////////////////////////////////////////////////////////////////////

logic [31:0] ALUResultM, RD2M, AdderOutM, PCPlus4M;
logic [4:0] rdM;
logic [31:0] WriteDataM, ReadDataM, ReadDataExtM;
logic RegWriteM, MemWriteM;
logic [2:0] ResultSrcM;

///////////////////////////////////////////////////////////////////////////////////////////////////
/*                                            STAGE5: WriteBack                                  */
///////////////////////////////////////////////////////////////////////////////////////////////////

logic [31:0] ALUResultW, ReadDataExtW, AdderOutW, PCPlus4W;
logic [4:0] rdW;
logic [31:0] ResultW;
logic RegWriteW;
logic [1:0] ResultSrcW;




///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////




///////////////////////////////////////////////////////////////////////////////////////////////////
/*                                            STAGE1: Fetch                                      */
///////////////////////////////////////////////////////////////////////////////////////////////////

/*
    If a branch or jump instruction (BEQ, BNE, BLT, BGE, BLTU, JAL, JALR) 
    in the Execute stage is taken, PCNextF becomes the branch target (PCTargetE).  
    Otherwise, it simply increments to the next sequential instruction (PCPlus4F).
*/

always_comb begin
    if (PCSrcE) begin
        PCNextF = PCTargetE;
    end else begin
        PCNextF = PCPlus4F;
    end
end

PC pc (
    .clk(clk),
    .rst_n(rst_n),
    .En(!StallF),
    .PCNext(PCNextF),
    .PC(PCF)
);

PCincr pcincr (
    .PC(PCF),
    .PCPlus4(PCPlus4F)
);

iMem imem (
    .A(PCF),
    .RD(InstrF)
);

IF_ID if_id (
    .clk(clk),
    .rst_n(rst_n),
    .clr(FlushD),
    .En(!StallD),
    .InstrF(InstrF),
    .PCF(PCF),
    .PCPlus4F(PCPlus4F),
    .InstrD(InstrD),
    .PCD(PCD),
    .PCPlus4D(PCPlus4D)
);


///////////////////////////////////////////////////////////////////////////////////////////////////
/*                                            STAGE2: Decode                                     */
///////////////////////////////////////////////////////////////////////////////////////////////////


ControlUnit controlunit (
    .instr(InstrD),
    .rs1(rs1D),
    .rs2(rs2D),
    .rd(rdD),
    .imm(ImmExtD),
    .Jump(JumpD),
    .BranchPos(BranchPosD),
    .BranchNeg(BranchNegD),
    .RegWrite(RegWriteD),
    .ALUSrc(ALUSrcD),
    .ALUControl(ALUControlD),
    .AddSrc(AddSrcD),
    .JALR(JALRD),
    .MemWrite(MemWriteD),
    .ResultSrc(ResultSrcD)
);

/*
    RegWrite instruction types:
        - LUI, AUIPC, ADDI, SLTI, SLTIU, XORI, ORI, ANDI, SLLI, SRLUI, SRAI
        - ADD, SUB, SLL, SLT, SLTU, XOR, SRL, SRU, OR, AND
        - LB, LH, LW, LBU, LHU
        - JAL, JALR

    Occurs in WriteBack stage.
    Generated during Decode stage.
*/

registerFile registerfile (
    .clk(clk),
    .rst_n(rst_n),
    .WE3(RegWriteW),                 
    .A1(rs1D),
    .A2(rs2D),
    .A3(rdW),
    .WD3(ResultW),
    .RD1(RD1D),
    .RD2(RD2D)
);

ID_IEx if_iex (
    .clk(clk),
    .rst_n(rst_n),
    .clr(FlushE),
    .RD1D(RD1D),
    .RD2D(RD2D),
    .PCD(PCD),
    .rs1D(rs1D),
    .rs2D(rs2D),
    .rdD(rdD),
    .ImmExtD(ImmExtD),
    .PCPlus4D(PCPlus4D),
    .RD1E(RD1E),
    .RD2E(RD2E),
    .PCE(PCE),
    .rs1E(rs1E),
    .rs2E(rs2E),
    .rdE(rdE),
    .ImmExtE(ImmExtE),
    .PCPlus4E(PCPlus4E)
);

CD_CEx cd_cex (
    .clk(clk),
    .rst_n(rst_n),
    .clr(FlushE),
    .JumpD(JumpD),
    .BranchPosD(BranchPosD),
    .BranchNegD(BranchNegD),
    .RegWriteD(RegWriteD),
    .ALUSrcD(ALUSrcD),
    .AddSrcD(AddSrcD),
    .JALRD(JALRD),
    .MemWriteD(MemWriteD),
    .ALUControlD(ALUControlD),
    .ResultSrcD(ResultSrcD),
    .JumpE(JumpE),
    .BranchPosE(BranchPosE),
    .BranchNegE(BranchNegE),
    .RegWriteE(RegWriteE),
    .ALUSrcE(ALUSrcE),
    .AddSrcE(AddSrcE),
    .JALRE(JALRE),
    .MemWriteE(MemWriteE),
    .ALUControlE(ALUControlE),
    .ResultSrcE(ResultSrcE)
);


///////////////////////////////////////////////////////////////////////////////////////////////////
/*                                            STAGE3: Execute                                    */
///////////////////////////////////////////////////////////////////////////////////////////////////


always_comb begin           // RAW Hazard mux1
    case (ForwardAE)
        2'b00 : ALUA = RD1E;
        2'b01 : ALUA = ResultW;
        2'b10 : ALUA = ALUResultM;
    endcase
end

assign ALUSrcAE = ALUA;

always_comb begin           // RAW Hazard mux2
    case (ForwardBE)
        2'b00 : ALUB = RD2E;
        2'b01 : ALUB = ResultW;
        2'b10 : ALUB = ALUResultM;
    endcase
end

always_comb begin
    if (ALUSrcE) begin                          // ALU src register types: 4, 6, 9. Imm types: 3, 5.
        ALUSrcBE = ALUB;
    end else begin
        ALUSrcBE = ImmExtE;
    end
end

alu32 alu (
    .A(ALUSrcAE),
    .B(ALUSrcBE),
    .ALU_ctrl(ALUControlE),                    // Alu ctrl E stage generated @ D.
    .Result(ALUResultE)
);

assign AddSrc1E = ImmExtE;

always_comb begin
    if (AddSrcE) begin                         // Reg types: 8.  // PC types: 2, 7, 9.                      
        AddSrc2E = ImmExtE;
    end else begin
        AddSrc2E = PCE;
    end
end

Adder adder (
    .in1(AddSrc1E),
    .in2(AddSrc2E),
    .out(AdderOutE)
);

always_comb begin
    if (JALRE) begin                           // if JALR.
        PCTargetE = AdderOutE;
    end else begin
        PCTargetE = {AdderOutE[31:1], 1'b0};
    end  
end

IEx_IMem iex_imem (
    .clk(clk),
    .rst_n(rst_n),
    .ALUResultE(ALUResultE),
    .RD2E(RD2E),
    .AdderOutE(AdderOutE),
    .PCPlus4E(PCPlus4E),
    .rdE(rdE),
    .ALUResultM(ALUResultM),
    .RD2M(RD2M),
    .AdderOutM(AdderOutM),
    .PCPlus4M(PCPlus4M),
    .rdM(rdM)
);

BJDec bjdec (
    .ALUResult(ALUResultE),
    .Jump(JumpE),
    .BranchPos(BranchPosE),
    .BranchNeg(BranchNegE),
    .PCSrc(PCSrcE)
);

CEx_CM cex_cm (
    .clk(clk),
    .rst_n(rst_n),
    .RegWriteE(RegWriteE),
    .ResultSrcE(ResultSrcE),
    .MemWriteE(MemWriteE),
    .RegWriteM(RegWriteM),
    .ResultSrcM(ResultSrcM),
    .MemWriteM(MemWriteM)
);


///////////////////////////////////////////////////////////////////////////////////////////////////
/*                                            STAGE4: Memory                                     */
///////////////////////////////////////////////////////////////////////////////////////////////////


Strip strip (
    .in(RD2M),
    .signal(1'b1),                          // if 6 ; currently  placeholder signal
    .out(WriteDataM)
);

dMem dmem (
    .clk(clk),
    .WE(MemWriteM),                         // if 5, 6
    .A(ALUResultM),
    .WD(WriteDataM),
    .RD(ReadDataM)
);

Extend extend (
    .in(ReadDataM),
    .signal(1'b1),                          // if 5; curenlty a placeholder signal
    .out(ReadDataExtM)
);

IMem_IW imem_iw (
    .clk(clk),
    .rst_n(rst_n),
    .ALUResultM(ALUResultM),
    .ReadDataExtM(ReadDataExtM),
    .AdderOutM(AdderOutM),
    .PCPlus4M(PCPlus4M),
    .rdM(rdM),
    .ALUResultW(ALUResultW),
    .ReadDataExtW(ReadDataExtW),
    .AdderOutW(AdderOutW),
    .PCPlus4W(PCPlus4W),
    .rdW(rdW)
);


CM_CW cm_cw (
    .clk(clk),
    .rst_n(rst_n),
    .RegWriteM(RegWriteM),
    .ResultSrcM(ResultSrcM),
    .RegWriteW(RegWriteW),
    .ResultSrcW(ResultSrcW)
);


///////////////////////////////////////////////////////////////////////////////////////////////////
/*                                            STAGE5: WriteBack                                  */
///////////////////////////////////////////////////////////////////////////////////////////////////


always_comb begin
    case (ResultSrcW)
        2'b00 : ResultW = ALUResultW;
        2'b01 : ResultW = ReadDataExtW;
        2'b10 : ResultW = AdderOutW;
        2'b11 : ResultW = PCPlus4W;
    endcase
end


///////////////////////////////////////////////////////////////////////////////////////////////////
/*                                              HAZARD UNIT                                      */
///////////////////////////////////////////////////////////////////////////////////////////////////


HazardUnit hazardunit (
    .rs1E(rs1E),
    .rs2E(rs2E),
    .rdM(rdM),
    .rdW(rdW),
    .RegWriteM(RegWriteM),
    .RegWriteW(RegWriteW),
    .rs1D(rs1D),
    .rs2D(rs2D),
    .rdE(rdE),
    .ResultSrcE(ResultSrcE),
    .PCSrcE(PCSrcE),
    .ForwardAE(ForwardAE),
    .ForwardBE(ForwardBE),
    .StallF(StallF),
    .StallE(StallE),
    .FlushE(FlushE),
    .FlushD(FlushD)
);


endmodule