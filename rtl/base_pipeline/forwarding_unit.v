//========== FORWARDING UNIT ==========
module forwarding_unit(
    input EX_MEM_reg_write,
    input [4:0] EX_MEM_rd,
    input MEM_WB_reg_write,
    input [4:0] MEM_WB_rd,
    input [4:0] ID_EX_rs1,
    input [4:0] ID_EX_rs2,
    output reg [1:0] forward_a,
    output reg [1:0] forward_b
);
    always @(*) begin
        // Forward A
        if (EX_MEM_reg_write && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs1))
            forward_a = 2'b10;
        else if (MEM_WB_reg_write && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs1))
            forward_a = 2'b01;
        else
            forward_a = 2'b00;
            
        // Forward B
        if (EX_MEM_reg_write && (EX_MEM_rd != 0) && (EX_MEM_rd == ID_EX_rs2))
            forward_b = 2'b10;
        else if (MEM_WB_reg_write && (MEM_WB_rd != 0) && (MEM_WB_rd == ID_EX_rs2))
            forward_b = 2'b01;
        else
            forward_b = 2'b00;
    end
endmodule
