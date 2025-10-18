module ControlUnit (
    input  logic [31:0] instr,
    output logic [4:0]  rs1,
    output logic [4:0]  rs2,
    output logic [4:0]  rd,
    output logic [31:0] imm,
    output logic        Jump,
    output logic        BranchPos,
    output logic        BranchNeg,
    output logic        RegWrite,
    output logic        ALUSrc,
    output logic [3:0]  ALUControl,
    output logic        AddSrc,
    output logic        JALR,
    output logic        MemWrite,
    output logic [1:0]  ResultSrc
);

    // Extract instruction fields
    logic [6:0] opcode;
    logic [2:0] funct3;
    logic [6:0] funct7;

    always_comb begin
        opcode = instr[6:0];
        rd     = instr[11:7];
        funct3 = instr[14:12];
        rs1    = instr[19:15];
        rs2    = instr[24:20];
        funct7 = instr[31:25];

        // ------------------------
        // Default output values
        // ------------------------
        imm        = 32'b0;
        Jump       = 1'b0;
        BranchPos  = 1'b0;
        BranchNeg  = 1'b0;
        RegWrite   = 1'b0;
        ALUSrc     = 1'b0;
        ALUControl = 4'b0000;
        AddSrc     = 1'b0;
        JALR       = 1'b0;
        MemWrite   = 1'b0;
        ResultSrc  = 2'b00; // Default: ALU result

        // ------------------------
        // Immediate generation
        // ------------------------
        case (opcode)
            7'b0110011: imm = 32'b0;                                           // R-type
            7'b0010011, 7'b0000011, 7'b1100111:                                 // I-type, load, JALR
                imm = {{20{instr[31]}}, instr[31:20]};
            7'b0100011: imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};    // Store
            7'b1100011: imm = {{19{instr[31]}}, instr[31], instr[7],
                               instr[30:25], instr[11:8], 1'b0};               // Branch
            7'b0110111, 7'b0010111: imm = {instr[31:12], 12'b0};               // LUI / AUIPC
            7'b1101111: imm = {{11{instr[31]}}, instr[31],
                               instr[19:12], instr[20],
                               instr[30:21], 1'b0};                            // JAL
            default: imm = 32'b0;
        endcase

        // ------------------------
        // Instruction decoding
        // ------------------------

        case (opcode)
            // ----------------- R-type -----------------
            7'b0110011: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b0; // Operand comes from registers
                case ({funct7, funct3})
                    10'b0000000_000: ALUControl = 4'b0000; // ADD
                    10'b0100000_000: ALUControl = 4'b0001; // SUB
                    10'b0000000_111: ALUControl = 4'b0010; // AND
                    10'b0000000_110: ALUControl = 4'b0011; // OR
                    10'b0000000_100: ALUControl = 4'b0100; // XOR
                    10'b0000000_001: ALUControl = 4'b0101; // SLL
                    10'b0000000_101: ALUControl = 4'b0110; // SRL
                    10'b0100000_101: ALUControl = 4'b0111; // SRA
                    10'b0000000_010: ALUControl = 4'b1000; // SLT
                    10'b0000000_011: ALUControl = 4'b1001; // SLTU
                    default:          ALUControl = 4'b0000;
                endcase
            end

            // ----------------- I-type (ALU immediate) -----------------
            7'b0010011: begin
                RegWrite = 1'b1;
                ALUSrc   = 1'b1; // Operand comes from immediate
                case (funct3)
                    3'b000: ALUControl = 4'b0000; // ADDI
                    3'b010: ALUControl = 4'b1000; // SLTI
                    3'b011: ALUControl = 4'b1001; // SLTIU
                    3'b100: ALUControl = 4'b0100; // XORI
                    3'b110: ALUControl = 4'b0011; // ORI
                    3'b111: ALUControl = 4'b0010; // ANDI
                    3'b001: ALUControl = 4'b0101; // SLLI
                    3'b101: ALUControl = (funct7 == 7'b0000000) ? 4'b0110 : 4'b0111; // SRLI/SRAI
                    default: ALUControl = 4'b0000;
                endcase
            end

            // ----------------- Load instructions -----------------
            7'b0000011: begin
                RegWrite   = 1'b1;
                ALUSrc     = 1'b1;
                ALUControl = 4'b0000; // ADD (for address calculation)
                ResultSrc  = 2'b01;   // Load value from memory
            end

            // ----------------- Store instructions -----------------
            7'b0100011: begin
                RegWrite   = 1'b0;
                ALUSrc     = 1'b1;
                ALUControl = 4'b0000; // ADD (for address calculation)
                MemWrite   = 1'b1;    // Enable memory write
            end

            // ----------------- Branch instructions -----------------
            7'b1100011: begin
                ALUSrc   = 1'b0;
                case (funct3)
                    3'b000: begin BranchNeg = 1'b1; ALUControl = 4'b0001; end // BEQ
                    3'b001: begin BranchPos = 1'b1; ALUControl = 4'b0001; end // BNE
                    3'b100: begin BranchPos = 1'b1; ALUControl = 4'b1000; end // BLT
                    3'b101: begin BranchNeg = 1'b1; ALUControl = 4'b1000; end // BGE
                    3'b110: begin BranchPos = 1'b1; ALUControl = 4'b1001; end // BLTU
                    3'b111: begin BranchNeg = 1'b1; ALUControl = 4'b1001; end // BGEU
                    default: begin BranchNeg = 1'b0; BranchPos = 1'b0; end
                endcase
            end

            // ----------------- LUI -----------------
            7'b0110111: begin
                RegWrite   = 1'b1;
                ALUSrc     = 1'b1;
                ALUControl = 4'b0000;
                ResultSrc  = 2'b00; // ALU result
            end

            // ----------------- AUIPC -----------------
            7'b0010111: begin
                RegWrite   = 1'b1;
                ALUSrc     = 1'b1;
                ALUControl = 4'b0000;
                AddSrc     = 1'b0; // PC + imm
                ResultSrc  = 2'b10;
            end

            // ----------------- JAL -----------------
            7'b1101111: begin
                Jump       = 1'b1;
                RegWrite   = 1'b1;
                AddSrc     = 1'b0;
                ResultSrc  = 2'b11; // Write PC+4
            end

            // ----------------- JALR -----------------
            7'b1100111: begin
                Jump       = 1'b1;
                RegWrite   = 1'b1;
                ALUSrc     = 1'b1;
                AddSrc     = 1'b1;
                JALR       = 1'b1;
                ResultSrc  = 2'b11; // Write PC+4
            end
        endcase
    end
endmodule