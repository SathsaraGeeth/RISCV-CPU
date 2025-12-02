module register #(parameter WIDTH = 32) (
    input  logic              clk,
    input  logic              rst_n,
    input  logic              we,
    input  logic [WIDTH-1:0]  D,
    output logic [WIDTH-1:0]  Q
);
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            Q <= '0;
        else if (we)
            Q <= D;
    end
endmodule