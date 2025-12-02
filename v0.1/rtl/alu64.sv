module alu64 (
    input  logic [63:0] A,
    input  logic [63:0] B,
    input  logic [3:0]  ALU_ctrl,
    output logic [63:0] Result
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
        case (ALU_ctrl)
            ADD:  Result = A + B;
            SUB:  Result = A - B;
            AND:  Result = A & B;
            OR:   Result = A | B;
            XOR:  Result = A ^ B;
            SLL:  Result = A << B[5:0];
            SRL:  Result = A >> B[5:0];
            SRA:  Result = $signed(A) >>> B[5:0];
            SLT:  Result = {63'b0, ($signed(A) < $signed(B))};
            SLTU: Result = {63'b0, (A < B)};
            default: Result = 64'b0;
        endcase
    end
endmodule