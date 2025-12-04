`timescale 1ns/1ps

module regFile (
    input   logic           clk,
    input   logic           rst_n,
    input   logic           we3,
    input   logic [4:0]     A1,
    input   logic [4:0]     A2,
    input   logic [4:0]     A3,
    input   logic [31:0]    WD3,
    output  logic [31:0]    RD1,
    output  logic [31:0]    RD2
);

    logic [31:0] Regs [31:0];

    // asynchronous read, x0 always returns 0
    assign RD1 = (A1 == 0) ? 32'b0 : Regs[A1];
    assign RD2 = (A2 == 0) ? 32'b0 : Regs[A2];

    always_ff @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            integer i;
            for(i=0; i<32; i=i+1)
                Regs[i] <= 32'b0;
        end
        else if(we3 && (A3 != 0)) begin
            Regs[A3] <= WD3;
        end
    end

endmodule