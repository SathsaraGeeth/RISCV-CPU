`timescale 1ns/1ps

module decoder (
    input  logic [31:0] Instr,
    input  logic        Zero,
    output logic        PCSrc,
    output logic [1:0]  ResultSrc,
    output logic        MemWrite,
    output logic [3:0]  ALUControl,
    output logic        ALUSrc,
    output logic [1:0]  ImmSrc,
    output logic        RegWrite
);
logic [1:0] ALUOp;
logic       Branch;
logic       Jump;
logic [6:0] Opcode;

logic [2:0] Funct3;
logic [6:0] Funct7;

assign Funct3 = Instr[14:12];
assign Funct7 = Instr[31:25];

assign Opcode = Instr[6:0];

assign PCSrc = Branch & Zero | Jump;

always_comb begin
    case (Opcode)
        7'b0000011: begin // lw
            {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump}
          = {1'b1,     2'b00,  1'b1,   1'b0,     2'b01,     1'b0,   2'b00, 1'b0};
        end
        7'b0100011: begin // sw
            {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump}
            = {1'b0,   2'b01,  1'b1,   1'b1,     2'b00,     1'b0,   2'b00, 1'b0};
        end
        7'b0110011: begin // R Type
            {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump}
          = {1'b1,     2'b00,  1'b0,   1'b0,     2'b00,     1'b0,   2'b10, 1'b0};
        end
        7'b1100011: begin // beq
            {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump}
          = {1'b0,     2'b10,  1'b0,   1'b0,     2'b00,     1'b1,   2'b01, 1'b0};
        end
        7'b0010011: begin // I Type
            {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump}
          = {1'b1,     2'b00,  1'b1,   1'b0,     2'b00,     1'b0,   2'b10, 1'b0};
        end
        7'b1101111: begin // jal
            {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump}
          = {1'b1,     2'b11,  1'b0,   1'b0,     2'b10,     1'b0,   2'b00, 1'b1};
        end
        default: begin
            {RegWrite, ImmSrc, ALUSrc, MemWrite, ResultSrc, Branch, ALUOp, Jump}
          = {1'b0,     2'b00,  1'b0,   1'b0,     2'b00,     1'b0,   2'b00, 1'b0};
        end
    endcase
end

always_comb begin
    case (ALUOp)
        2'b00: begin // lw, sw
            ALUControl = 4'b0000; // ADD
        end
        2'b01: begin // beq
            ALUControl = 4'b0001; // SUB
        end
        2'b10: begin 
            case (Funct3)
                3'b000: begin
                    case ({Opcode[5], Funct7[5]})
                        2'b00: ALUControl = 4'b0000; // ADD
                        2'b01: ALUControl = 4'b0000; // ADD
                        2'b10: ALUControl = 4'b0000; // ADD
                        2'b11: ALUControl = 4'b0001; // SUB
                        default: ALUControl = 4'b0000;
                    endcase
                end
                3'b010: begin 
                    ALUControl = 4'b1000; // SLT
                end
                3'b110: begin
                    ALUControl = 4'b0011; // OR
                end
                3'b111: begin
                    ALUControl = 4'b0010; // AND
                end
                default: ALUControl = 4'b0000;
            endcase
        end
        default: ALUControl = 4'b0000;
    endcase
end
endmodule
