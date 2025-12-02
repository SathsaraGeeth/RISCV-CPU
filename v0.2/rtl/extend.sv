`timescale 1ns/1ps

module extend (
    input  logic [31:0] IN,
    input  logic [1:0]  signal,
    output logic [31:0] OUT
);
    always_comb begin
        case (signal)
            2'b00: begin         // I Type
                OUT = {{20{IN[31]}}, IN[31:20]};
            end
            2'b01: begin         // S Type
                OUT = {{20{IN[31]}}, IN[31:25], IN[11:7]};
            end
            2'b10: begin         // B Type
                OUT = {{20{IN[31]}}, IN[7], IN[30:25], IN[11:8], 1'b0};
            end
            2'b11: begin         // J Type
                OUT = {{12{IN[31]}}, IN[19:12], IN[20], IN[30:21], 1'b0};
            end
            default: begin
                OUT = 32'b0;
            end
        endcase
    end
endmodule