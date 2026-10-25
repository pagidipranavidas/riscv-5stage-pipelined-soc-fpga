// ============================================================
// arch2.v - RISC-V single-cycle processor
// ALUResult_out and PC_out are PROPER output ports
// (not hierarchical references - those don't synthesize)
// ============================================================
module arch2(
input         clk,
input         rst,
output [31:0] ReadData,
output [31:0] ALUResult_out,
output [31:0] PC_out);

wire [31:0] ALUResult, result;
wire [31:0] PCNext, PCPlus4, PCTarget;
wire [31:0] PC, RD;
wire [31:0] RD1, RD2, immext, srcB, Resultmux1;
wire        zero, Branch, jump;
wire        RegWrite, ALUSrc, MemWrite, MemRead;
wire [1:0]  Aluop, immsrc, Resultsrc;
wire [3:0]  Control;
wire        TakeBranch;

// Expose internal signals as outputs
assign ALUResult_out = ALUResult;
assign PC_out        = PC;

// Branch only when Branch=1 AND ALU result is zero
assign TakeBranch = Branch & zero;

PCCounter         P1 (.clk(clk), .rst(rst), .PCNext(PCNext), .PC(PC));
instructionmemory I1 (.PC(PC), .RD(RD));
mainctrl2         M1 (.RD(RD[6:0]), .Branch(Branch), .jump(jump),
                      .MemWrite(MemWrite), .MemRead(MemRead),
                      .ALUSrc(ALUSrc), .RegWrite(RegWrite),
                      .immsrc(immsrc), .Aluop(Aluop), .Resultsrc(Resultsrc));
Registerfile      R1 (.clk(clk), .RegWrite(RegWrite),
                      .A1(RD[19:15]), .A2(RD[24:20]), .A3(RD[11:7]),
                      .WD3(Resultmux1),
                      .RD1(RD1), .RD2(RD2), .result(result));
ALUControl        AC (.Aluop(Aluop), .funct7(RD[30]),
                      .funct3(RD[14:12]), .Control(Control));
immediategeneration S1 (.immsrc(immsrc), .instr(RD), .extimm(immext));
MUX               M4 (.a(RD2), .b(immext), .s(ALUSrc), .out(srcB));
ALU               A3 (.controlsignal(Control), .A1(RD1), .A2(srcB),
                      .Y(ALUResult), .zero(zero));
DataMemory        D1 (.clk(clk), .MemWrite(MemWrite), .MemRead(MemRead),
                      .ALUResult(ALUResult), .WriteData(RD2), .ReadData(ReadData));
adder             A1 (.PC(PC), .PCPlus4(PCPlus4));
MUX1              M2 (.a(ALUResult), .b(ReadData), .c(PCPlus4),
                      .s(Resultsrc), .out(Resultmux1));
add               A2 (.A1(PC), .A2(immext), .Y(PCTarget));
MUX               mPC(.a(PCPlus4), .b(PCTarget), .s(TakeBranch), .out(PCNext));

endmodule