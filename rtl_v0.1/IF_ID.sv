module IF_ID (
    input   logic           clk,
    input   logic           rst_n,
    input   logic           En,
    input   logic           clr,
    input   logic   [31:0]  InstrF,
    input   logic   [31:0]  PCF,
    input   logic   [31:0]  PCPlus4F,
    output  logic   [31:0]  InstrD,
    output  logic   [31:0]  PCD,
    output  logic   [31:0]  PCPlus4D
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n or clr) begin
            InstrD <= 0;
            PCD <= 0;
            PCPlus4D <= 0;
        end else if (En) begin
            InstrD <= InstrF;
            PCD <= PCF;
            PCPlus4D <= PCPlus4F;
        end
    end
endmodule