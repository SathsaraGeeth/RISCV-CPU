module CEx_CM (
    input  logic        clk,
    input  logic        rst_n,

    input  logic        RegWriteE,
    input  logic [1:0]  ResultSrcE,
    input  logic        MemWriteE,

    output logic        RegWriteM,
    output logic [1:0]  ResultSrcM,
    output logic        MemWriteM
);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            RegWriteM  <= '0;
            ResultSrcM <= '0;
            MemWriteM  <= '0;
        end else begin
            RegWriteM  <= RegWriteE;
            ResultSrcM <= ResultSrcE;
            MemWriteM  <= MemWriteE;
        end
    end

endmodule