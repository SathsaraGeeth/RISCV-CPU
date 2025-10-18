module HazardUnit (
    input   logic [4:0]     rs1E,
    input   logic [4:0]     rs2E,
    input   logic [4:0]     rdM,
    input   logic [4:0]     rdW,
    input   logic           RegWriteM,
    input   logic           RegWriteW,
    input   logic [4:0]     rs1D,
    input   logic [4:0]     rs2D,
    input   logic [4:0]     rdE,
    input   logic [1:0]     ResultSrcE,
    input   logic           PCSrcE,
    output  logic [1:0]     ForwardAE,
    output  logic [1:0]     ForwardBE,
    output  logic           StallF,
    output  logic           StallD,
    output  logic           FlushE,
    output  logic           FlushD
);

// Forwarding - RAW Hazards
always_comb begin
	ForwardAE = 2'b00;
	ForwardBE = 2'b00;
    if ((rs1E == rdM) & (RegWriteM) & (rs1E != 0)) // higher priority - most recent
        ForwardAE = 2'b10; // for forwarding ALU Result in Memory Stage
    else if ((rs1E == rdW) & (RegWriteW) & (rs1E != 0))
        ForwardAE = 2'b01; // for forwarding WriteBack Stage Result
    if ((rs2E == rdM) & (RegWriteM) & (rs2E != 0))
        ForwardBE = 2'b10; // for forwarding ALU Result in Memory Stage
    else if ((rs2E == rdW) & (RegWriteW) & (rs2E != 0))
        ForwardBE = 2'b01; // for forwarding WriteBack Stage Result
     
end
// Stalling - RAW Hazards
logic lStall;
assign lStall = (ResultSrcE == 2'b01) & ((rdE == rs1D) | (rdE == rs2D));

assign StallF = lStall;
assign StallD = lStall;
// assign FlushE = lStall;

// Flushese - Control Hazards
assign FlushE = lwStall | PCSrcE; // combined with STALLING - RAW HAZARDS
assign FlushD = PCSrcE;

endmodule