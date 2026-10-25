// ========== ALU CONTROL ==========
module alu_control(
    input [1:0] alu_op,
    input [2:0] funct3,
    input [6:0] funct7,
    output reg [4:0] alu_control
);
    always @(*) begin
        case(alu_op)
            2'b00: alu_control = 5'b00010; // ADD for load/store
            2'b01: alu_control = 5'b00110; // SUB for branch
            2'b10: begin
                case(funct3)
                    3'b000: begin
                        if (funct7 == 7'b0000001) // M Extension
                            alu_control = 5'b10000; // MUL
                        else
                            alu_control = (funct7[5]) ? 5'b00110 : 5'b00010; // SUB : ADD
                    end
                    3'b001: begin
                        if (funct7 == 7'b0000001)
                            alu_control = 5'b10001; // MULH
                        else
                            alu_control = 5'b00011; // SLL
                    end
                    3'b010: begin
                        if (funct7 == 7'b0000001)
                            alu_control = 5'b10010; // MULHSU
                        else
                            alu_control = 5'b00111; // SLT
                    end
                    3'b011: begin
                        if (funct7 == 7'b0000001)
                            alu_control = 5'b10011; // MULHU
                        else
                            alu_control = 5'b01001; // SLTU
                    end
                    3'b100: begin
                        if (funct7 == 7'b0000001)
                            alu_control = 5'b10100; // DIV
                        else
                            alu_control = 5'b00100; // XOR
                    end
                    3'b101: begin
                        if (funct7 == 7'b0000001)
                            alu_control = 5'b10101; // DIVU
                        else
                            alu_control = (funct7[5]) ? 5'b01000 : 5'b00101; // SRA : SRL
                    end
                    3'b110: begin
                        if (funct7 == 7'b0000001)
                            alu_control = 5'b10110; // REM
                        else
                            alu_control = 5'b00001; // OR
                    end
                    3'b111: begin
                        if (funct7 == 7'b0000001)
                            alu_control = 5'b10111; // REMU
                        else
                            alu_control = 5'b00000; // AND
                    end
                    default: alu_control = 5'b00010;
                endcase
            end
            default: alu_control = 5'b00010;
        endcase
    end
endmodule
