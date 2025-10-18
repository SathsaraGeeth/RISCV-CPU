module ID_IEx (
    input   logic           clk,
    input   logic           rst_n,
    input   logic           clr,
    input   logic   [31:0]  RD1D,
    input   logic   [31:0]  RD2D,
    input   logic   [31:0]  PCD,
    input   logic   [4:0]   rs1D,
    input   logic   [4:0]   rs2D,
    input   logic   [4:0]   rdD,
    input   logic   [31:0]  ImmExtD,
    input   logic   [31:0]  PCPlus4D,
    output  logic   [31:0]  RD1E,
    output  logic   [31:0]  RD2E,
    output  logic   [31:0]  PCE,
    output  logic   [4:0]   rs1E,
    output  logic   [4:0]   rs2E,
    output  logic   [4:0]   rdE,
    output  logic   [31:0]  ImmExtE,
    output  logic   [31:0]  PCPlus4E
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n or clr) begin
            RD1E       <= '0;
            RD2E       <= '0;
            PCE        <= '0;
            rs1E       <= '0;
            rs2E       <= '0;
            rdE        <= '0;
            ImmExtE    <= '0;
            PCPlus4E   <= '0;
        end else begin
            RD1E       <= RD1D;
            RD2E       <= RD2D;
            PCE        <= PCD;
            rs1E       <= rs1D;
            rs2E       <= rs2D;
            rdE        <= rdD;
            ImmExtE    <= ImmExtD;
            PCPlus4E   <= PCPlus4D;
        end
    end
endmodule