module IEx_IMem (
    input   logic           clk,
    input   logic           rst_n,
    input   logic   [31:0]  ALUResultE,
    input   logic   [31:0]  RD2E,
    input   logic   [31:0]  AdderOutE,
    input   logic   [31:0]  PCPlus4E,
    input   logic   [4:0]   rdE,
    output  logic   [31:0]  ALUResultM,
    output  logic   [31:0]  RD2M,
    output  logic   [31:0]  AdderOutM,
    output  logic   [31:0]  PCPlus4M,
    output  logic   [4:0]   rdM
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ALUResultM <= '0;
            RD2M       <= '0;
            AdderOutM  <= '0;
            PCPlus4M   <= '0;
            rdM        <= '0;
        end else begin
            ALUResultM <= ALUResultE;
            RD2M       <= RD2E;
            AdderOutM  <= AdderOutE;
            PCPlus4M   <= PCPlus4E;
            rdM        <= rdE;
        end
    end
endmodule