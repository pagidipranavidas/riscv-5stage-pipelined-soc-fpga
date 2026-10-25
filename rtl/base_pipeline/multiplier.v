// ========== MULTIPLIER UNIT (M Extension) - OPTIMIZED ==========
module multiplier(
    //input clk,
    input [31:0] a,
    input [31:0] b,
    input [1:0] mul_op,
    output reg [31:0] mul_result
);
    reg [63:0] full_product;
    
    // Register inputs for better timing
    reg [31:0] a_reg, b_reg;
    reg [1:0] op_reg;
    
    always @(*) begin
        a_reg <= a;
        b_reg <= b;
        op_reg <= mul_op;
    end
    
    // Pipelined multiplication
    always @(*) begin
        case(op_reg)
            2'b00: begin // MUL - Lower 32 bits
                full_product <= $signed(a_reg) * $signed(b_reg);
                mul_result <= full_product[31:0];
            end
            2'b01: begin // MULH - Upper 32 bits (signed x signed)
                full_product <= $signed(a_reg) * $signed(b_reg);
                mul_result <= full_product[63:32];
            end
            2'b10: begin // MULHSU - Upper 32 bits (signed x unsigned)
                full_product <= $signed(a_reg) * $signed({1'b0, b_reg});
                mul_result <= full_product[63:32];
            end
            2'b11: begin // MULHU - Upper 32 bits (unsigned x unsigned)
                full_product <= a_reg * b_reg;
                mul_result <= full_product[63:32];
            end
            default: mul_result <= 32'h00000000;
        endcase
    end
endmodule
