`timescale 1ns/1ps

module iMem(
  input  logic [31:0] A,
  output logic [31:0] RD
);
  logic [31:0] RAM[63:0]; // 256B cache
  // initial $readmemh("/Volumes/fileserver/Projects/cpu/program.txt", RAM); // Bootloader here
  assign RD = RAM[A[7:2]];//RAM[A[31:2]];
endmodule
