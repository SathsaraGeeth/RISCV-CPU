module dMem (
    input  logic            clk,
    input  logic            WE,
    input  logic   [31:0]   A,
    input  logic   [31:0]   WD,
    output logic   [31:0]   RD
    );

logic [31:0] RAM[63:0];
assign RD = RAM[A[31:2]]; // word aligned
    
always_ff @(posedge clk)
    if (WE) begin
        RAM[a[31:2]] <= WD;
    end
endmodule