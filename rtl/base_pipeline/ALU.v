// ========== ALU (Without M Extension) ==========
module alu(
    input [31:0] a,
    input [31:0] b,
    input [4:0] alu_control,
    output reg [31:0] result,
    output zero
);
    always @(*) begin
        case(alu_control)
            5'b00000: result = a & b;                               // AND
            5'b00001: result = a | b;                               // OR
            5'b00010: result = a + b;                               // ADD
            5'b00011: result = a << b[4:0];                         // SLL
            5'b00100: result = a ^ b;                               // XOR
            5'b00101: result = a >> b[4:0];                         // SRL
            5'b00110: result = a - b;                               // SUB
            5'b00111: result = ($signed(a) < $signed(b)) ? 1 : 0;  // SLT
            5'b01000: result = $signed(a) >>> b[4:0];               // SRA
            5'b01001: result = (a < b) ? 1 : 0;                     // SLTU
            default: result = 32'h00000000;
        endcase
    end
    
    assign zero = (result == 32'h00000000);
endmodule
