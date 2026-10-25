// ========== REGISTER FILE ==========
module register_file(
    input clk,
    input reset,
    input [4:0] rs1,
    input [4:0] rs2,
    input [4:0] rd,
    input [31:0] write_data,
    input reg_write,
    output [31:0] rs1_data,
    output [31:0] rs2_data,
    output [31:0] x1_out,
    output [31:0] x2_out,
    output [31:0] x3_out,
    output [31:0] x4_out,
    output [31:0] x5_out
);
    reg [31:0] registers [0:31];
    integer i;
    
    initial begin
        for ( i = 0; i < 32; i = i + 1)
            registers[i] = 32'h00000000;
    end
    
    always @(posedge clk) begin
        if (reset) begin
            for ( i = 0; i < 32; i = i + 1)
                registers[i] <= 32'h00000000;
        end
        else if (reg_write && rd != 5'b00000)
            registers[rd] <= write_data;
    end
    
    assign rs1_data = (rs1 == 5'b00000) ? 32'h00000000 : registers[rs1];
    assign rs2_data = (rs2 == 5'b00000) ? 32'h00000000 : registers[rs2];
    
    // Output register values for monitoring
    assign x1_out = registers[1];
    assign x2_out = registers[2];
    assign x3_out = registers[3];
    assign x4_out = registers[4];
    assign x5_out = registers[5];
endmodule
