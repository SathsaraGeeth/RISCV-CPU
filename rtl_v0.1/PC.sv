module PC (
    input   logic   clk,
    input   logic   rst_n,
    input   logic   En,
    input   logic [31:0] PCNext,
    output  logic [31:0] PC
    );

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            PC <= '0;
        end else if (En) begin
            PC <= PCNext;
        end
    end
endmodule