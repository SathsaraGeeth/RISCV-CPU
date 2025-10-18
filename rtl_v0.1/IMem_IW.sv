module IMem_IW (
    input   logic           clk,
    input   logic           rst_n,
    input   logic   [31:0]  ALUResultM,
    input   logic   [31:0]  ReadDataExtM,
    input   logic   [31:0]  AdderOutM,
    input   logic   [31:0]  PCPlus4M,
    input   logic   [4:0]   rdM,
    output  logic   [31:0]  ALUResultW,
    output  logic   [31:0]  ReadDataExtW,
    output  logic   [31:0]  AdderOutW,
    output  logic   [31:0]  PCPlus4W,
    output  logic   [4:0]   rdW
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ALUResultW    <= '0;
            ReadDataExtW  <= '0;
            AdderOutW     <= '0;
            PCPlus4W      <= '0;
            rdW           <= '0;
        end else begin
            ALUResultW    <= ALUResultM;
            ReadDataExtW  <= ReadDataExtM;
            AdderOutW     <= AdderOutM;
            PCPlus4W      <= PCPlus4M;
            rdW           <= rdM;
        end
    end
endmodule