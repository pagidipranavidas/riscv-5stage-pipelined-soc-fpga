// ========== DIVIDER UNIT (M Extension) - OPTIMIZED ==========
module divider(
 //  input clk,
    input [31:0] a,
    input [31:0] b,
    input [1:0] div_op,
    output reg [31:0] div_result
);
    // Register inputs
    reg [31:0] a_reg, b_reg;
    reg [1:0] op_reg;
    
    always @(* ) begin
        a_reg <= a;
        b_reg <= b;
        op_reg <= div_op;
    end
    
    // Pipelined division
    always @(*) begin
        case(op_reg)
            2'b00: begin // DIV - Signed division
                if (b_reg == 0)
                    div_result <= 32'hFFFFFFFF;
                else if (a_reg == 32'h80000000 && b_reg == 32'hFFFFFFFF)
                    div_result <= 32'h80000000;
                else
                    div_result <= $signed(a_reg) / $signed(b_reg);
            end
            2'b01: begin // DIVU - Unsigned division
                if (b_reg == 0)
                    div_result <= 32'hFFFFFFFF;
                else
                    div_result <= a_reg / b_reg;
            end
            2'b10: begin // REM - Signed remainder
                if (b_reg == 0)
                    div_result <= a_reg;
                else if (a_reg == 32'h80000000 && b_reg == 32'hFFFFFFFF)
                    div_result <= 0;
                else
                    div_result <= $signed(a_reg) % $signed(b_reg);
            end
            2'b11: begin // REMU - Unsigned remainder
                if (b_reg == 0)
                    div_result <= a_reg;
                else
                    div_result <= a_reg % b_reg;
            end
            default: div_result <= 32'h00000000;
        endcase
    end
endmodule
