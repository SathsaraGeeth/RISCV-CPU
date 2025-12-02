module iMem(
  input  logic [31:0] A,
  output logic [31:0] RD
);
  logic [31:0] RAM[63:0];
  initial $readmemh("program.txt", RAM);
  assign RD = RAM[A[31:2]];
endmodule