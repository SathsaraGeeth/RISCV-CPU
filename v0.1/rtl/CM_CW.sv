module CM_CW (
    input  logic        clk,
    input  logic        rst_n,

    input  logic        RegWriteM,
    input  logic [1:0]  ResultSrcM,

    output logic        RegWriteW,
    output logic [1:0]  ResultSrcW
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            RegWriteW  <= '0;
            ResultSrcW <= '0;
        end else begin
            RegWriteW  <= RegWriteM;
            ResultSrcW <= ResultSrcM;
        end
    end

endmodule