// ========== HAZARD DETECTION UNIT ==========
module hazard_detection_unit(
    input ID_EX_mem_read,
    input [4:0] ID_EX_rd,
    input [4:0] IF_ID_rs1,
    input [4:0] IF_ID_rs2,
    output reg stall
);
    always @(*) begin
        if (ID_EX_mem_read && 
            ((ID_EX_rd == IF_ID_rs1) || (ID_EX_rd == IF_ID_rs2))) begin
            stall = 1'b1;
        end
        else begin
            stall = 1'b0;
        end
    end
endmodule