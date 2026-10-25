//module mainctrl2(
//input [6:0] RD,
//output Branch,jump,MemWrite,MemRead,ALUSrc,RegWrite,[1:0]immsrc,[1:0]Aluop,[1:0]Resultsrc);

//reg [11:0] control;


//assign {Branch,jump,ALUSrc,immsrc,RegWrite,MemWrite,Aluop,Resultsrc,MemRead} = control;
//always @(*)
//begin
//case(RD)
//7'b0110011 : control <= 12'b0_0_0_xx__1_0_10_00_0; // R-type
//7'b0000011 : control <= 12'b0_0_1_00__1_0_00_01_1; // lw-type
//7'b0100011 : control <= 12'b0_0_1_01__0_1_00_xx_0; // s-type//sw
//7'b1100011 : control <= 12'b1_0_0_01__0_0_01_xx_0; // sb-type
//7'b0010011 : control <= 12'b0_0_1_00__1_0_11_00_0; // I-type
//7'b1100111 : control <= 12'b0_1_1_11__1_x_00_10_0; // jalr-type
//7'b1101111 : control <= 12'b0_1_1_11__1_x_00_10_0; // jal-type
//default : control    <= 12'bx_x_x_xx__x_x_xx_xx_x;
//endcase
//end
//endmodule


module mainctrl2(
input [6:0] RD,
output Branch,jump,MemWrite,MemRead,ALUSrc,RegWrite,
output [1:0] immsrc,
output [1:0] Aluop,
output [1:0] Resultsrc);

reg [11:0] control;

// BIT MAPPING (12 bits total):
// [11]=Branch, [10]=jump, [9]=ALUSrc, [8:7]=immsrc,
// [6]=RegWrite, [5]=MemWrite, [4:3]=Aluop, [2:1]=Resultsrc, [0]=MemRead
assign {Branch,jump,ALUSrc,immsrc,RegWrite,MemWrite,Aluop,Resultsrc,MemRead} = control;

always @(*)
begin
    case(RD)
        // FIX: replaced "xx" with 2'b00 for unused immsrc/Resultsrc fields
        7'b0110011 : control = 12'b0_0_0_00_1_0_10_00_0; // R-type  (immsrc=00, Resultsrc=00)
        7'b0000011 : control = 12'b0_0_1_00_1_0_00_01_1; // lw
        7'b0100011 : control = 12'b0_0_1_01_0_1_00_00_0; // sw      (Resultsrc=00 not used)
        7'b1100011 : control = 12'b1_0_0_10_0_0_01_00_0; // beq     (immsrc=10 for B-type)
        7'b0010011 : control = 12'b0_0_1_00_1_0_11_00_0; // I-type (addi,andi,ori,xori,slli,srli)
        7'b1100111 : control = 12'b0_1_1_11_1_0_00_10_0; // jalr
        7'b1101111 : control = 12'b0_1_1_11_1_0_00_10_0; // jal
        // FIX: default is all 0, not all X - prevents X propagation
        default    : control = 12'b0_0_0_00_0_0_00_00_0;
    endcase
end
endmodule