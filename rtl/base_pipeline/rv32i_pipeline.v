
module rv32i_pipeline(
    input clk,
    input reset,
    input enable,
    input [31:0] instruction_in,
    input instruction_valid,
    
    // Outputs - Pipeline Stages
    output [31:0] pc_out,
    output [31:0] pc_address,
    output [31:0] instruction_out,
    
    // ALU Inputs and Output
    output [31:0] a_out,
    output [31:0] b_out,
    output [31:0] alu_result_out,
    
    // Memory Signals
    output [31:0] mem_read_data,
    output [31:0] mem_write_data,
    output mem_read_out,
    output mem_write_out,
    
    // Write Back
    output [31:0] write_data_out,
    output [4:0] rd_out,
    output reg_write_out,
    
    // Control Signals
    output stall_out,
    output flush_out,
    
    // Register file access
    output [31:0] x1_out,
    output [31:0] x2_out,
    output [31:0] x3_out,
    output [31:0] x4_out,
    output [31:0] x5_out
);

    // Pipeline registers
    reg [31:0] IF_ID_pc, IF_ID_instr;
    reg [31:0] ID_EX_pc, ID_EX_rs1_data, ID_EX_rs2_data, ID_EX_imm;
    reg [4:0] ID_EX_rd, ID_EX_rs1, ID_EX_rs2;
    reg [6:0] ID_EX_opcode;
    reg [2:0] ID_EX_funct3;
    reg [6:0] ID_EX_funct7;
    reg ID_EX_reg_write, ID_EX_mem_read, ID_EX_mem_write, ID_EX_branch, ID_EX_alu_src;
    
    reg [31:0] EX_MEM_alu_result, EX_MEM_rs2_data, EX_MEM_pc_branch;
    reg [4:0] EX_MEM_rd;
    reg EX_MEM_reg_write, EX_MEM_mem_read, EX_MEM_mem_write, EX_MEM_zero, EX_MEM_branch;
    
    reg [31:0] MEM_WB_read_data, MEM_WB_alu_result;
    reg [4:0] MEM_WB_rd;
    reg MEM_WB_reg_write, MEM_WB_mem_to_reg;
    
    // Control signals
    wire reg_write, mem_read, mem_write, branch, alu_src, mem_to_reg;
    wire [1:0] alu_op;
    
    // IF stage signals
    reg [31:0] pc;
    wire [31:0] pc_plus_4, pc_next;
    wire [31:0] instruction;
    
    // ID stage signals
    wire [31:0] rs1_data, rs2_data, imm_extended;
    wire [4:0] rs1, rs2, rd;
    wire [6:0] opcode, funct7;
    wire [2:0] funct3;
    
    // EX stage signals
    wire [31:0] alu_input2, alu_result_base, pc_branch;
    wire [4:0] alu_control;
    wire zero;
    wire [31:0] mul_result, div_result, alu_result;
    wire is_mul_op, is_div_op;
    
    // MEM stage signals
    wire [31:0] mem_read_data_wire;
    
    // WB stage signals
    wire [31:0] write_back_data;
    
    // Hazard detection
    wire stall, flush;
    wire [1:0] forward_a, forward_b;
    wire [31:0] forward_data_a, forward_data_b;
    
    // Register file wires for output
    wire [31:0] reg_x1, reg_x2, reg_x3, reg_x4, reg_x5;
    
    // Output assignments - Pipeline
    assign pc_out = pc;
    assign pc_address = pc;
    assign instruction_out = IF_ID_instr;
    
    // Output assignments - ALU
    assign a_out = forward_data_a;
    assign b_out = alu_input2;
    assign alu_result_out = EX_MEM_alu_result;
    
    // Output assignments - Memory
    assign mem_read_data = MEM_WB_read_data;
    assign mem_write_data = EX_MEM_rs2_data;
    assign mem_read_out = EX_MEM_mem_read;
    assign mem_write_out = EX_MEM_mem_write;
    
    // Output assignments - Write Back
    assign write_data_out = write_back_data;
    assign rd_out = MEM_WB_rd;
    assign reg_write_out = MEM_WB_reg_write;
    
    // Output assignments - Control
    assign stall_out = stall;
    assign flush_out = flush;
    
    // Register outputs (for debugging/monitoring)
    assign x1_out = reg_x1;
    assign x2_out = reg_x2;
    assign x3_out = reg_x3;
    assign x4_out = reg_x4;
    assign x5_out = reg_x5;

    // ========== IF STAGE ==========
    assign pc_plus_4 = pc + 4;
    assign pc_next = (EX_MEM_branch && EX_MEM_zero) ? EX_MEM_pc_branch : pc_plus_4;
    
    always @(posedge clk or posedge reset) begin
        if (reset)
            pc <= 32'h00000000;
        else if (enable && !stall)
            pc <= pc_next;
    end
    
    instruction_memory IMEM (
        .address(pc),
        .instruction(instruction),
        .external_instr(instruction_in),
        .external_valid(instruction_valid)
    );
    
    // IF/ID Pipeline Register
    always @(posedge clk or posedge reset) begin
        if (reset || flush) begin
            IF_ID_pc <= 32'h00000000;
            IF_ID_instr <= 32'h00000013; // NOP
        end
        else if (!stall) begin
            IF_ID_pc <= pc;
            IF_ID_instr <= instruction;
        end
    end

    // ========== ID STAGE ==========
    assign opcode = IF_ID_instr[6:0];
    assign rd = IF_ID_instr[11:7];
    assign funct3 = IF_ID_instr[14:12];
    assign rs1 = IF_ID_instr[19:15];
    assign rs2 = IF_ID_instr[24:20];
    assign funct7 = IF_ID_instr[31:25];
    
    register_file REGFILE (
        .clk(clk),
        .reset(reset),
        .rs1(rs1),
        .rs2(rs2),
        .rd(MEM_WB_rd),
        .write_data(write_back_data),
        .reg_write(MEM_WB_reg_write),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .x1_out(reg_x1),
        .x2_out(reg_x2),
        .x3_out(reg_x3),
        .x4_out(reg_x4),
        .x5_out(reg_x5)
    );
    
    control_unit CTRL (
        .opcode(opcode),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .branch(branch),
        .alu_src(alu_src),
        .mem_to_reg(mem_to_reg),
        .alu_op(alu_op)
    );
    
    immediate_generator IMM_GEN (
        .instruction(IF_ID_instr),
        .imm_extended(imm_extended)
    );
    
    // Hazard Detection Unit
    hazard_detection_unit HDU (
        .ID_EX_mem_read(ID_EX_mem_read),
        .ID_EX_rd(ID_EX_rd),
        .IF_ID_rs1(rs1),
        .IF_ID_rs2(rs2),
        .stall(stall)
    );
    
    assign flush = (EX_MEM_branch && EX_MEM_zero);
    
    // ID/EX Pipeline Register
    always @(posedge clk or posedge reset) begin
        if (reset || stall) begin
            ID_EX_pc <= 32'h00000000;
            ID_EX_rs1_data <= 32'h00000000;
            ID_EX_rs2_data <= 32'h00000000;
            ID_EX_imm <= 32'h00000000;
            ID_EX_rd <= 5'b00000;
            ID_EX_rs1 <= 5'b00000;
            ID_EX_rs2 <= 5'b00000;
            ID_EX_opcode <= 7'b0000000;
            ID_EX_funct3 <= 3'b000;
            ID_EX_funct7 <= 7'b0000000;
            ID_EX_reg_write <= 1'b0;
            ID_EX_mem_read <= 1'b0;
            ID_EX_mem_write <= 1'b0;
            ID_EX_branch <= 1'b0;
            ID_EX_alu_src <= 1'b0;
        end
        else begin
            ID_EX_pc <= IF_ID_pc;
            ID_EX_rs1_data <= rs1_data;
            ID_EX_rs2_data <= rs2_data;
            ID_EX_imm <= imm_extended;
            ID_EX_rd <= rd;
            ID_EX_rs1 <= rs1;
            ID_EX_rs2 <= rs2;
            ID_EX_opcode <= opcode;
            ID_EX_funct3 <= funct3;
            ID_EX_funct7 <= funct7;
            ID_EX_reg_write <= reg_write;
            ID_EX_mem_read <= mem_read;
            ID_EX_mem_write <= mem_write;
            ID_EX_branch <= branch;
            ID_EX_alu_src <= alu_src;
        end
    end

    // ========== EX STAGE ==========
    alu_control ALU_CTRL (
        .alu_op(alu_op),
        .funct3(ID_EX_funct3),
        .funct7(ID_EX_funct7),
        .alu_control(alu_control)
    );
    
    // Forwarding Unit
    forwarding_unit FWD (
        .EX_MEM_reg_write(EX_MEM_reg_write),
        .EX_MEM_rd(EX_MEM_rd),
        .MEM_WB_reg_write(MEM_WB_reg_write),
        .MEM_WB_rd(MEM_WB_rd),
        .ID_EX_rs1(ID_EX_rs1),
        .ID_EX_rs2(ID_EX_rs2),
        .forward_a(forward_a),
        .forward_b(forward_b)
    );
    
    // Forward data selection
    assign forward_data_a = (forward_a == 2'b10) ? EX_MEM_alu_result :
                           (forward_a == 2'b01) ? write_back_data :
                           ID_EX_rs1_data;
                           
    assign forward_data_b = (forward_b == 2'b10) ? EX_MEM_alu_result :
                           (forward_b == 2'b01) ? write_back_data :
                           ID_EX_rs2_data;
    
    assign alu_input2 = ID_EX_alu_src ? ID_EX_imm : forward_data_b;
    
    // Check if operation is multiplication or division
    assign is_mul_op = (alu_control >= 5'b10000 && alu_control <= 5'b10011);
    assign is_div_op = (alu_control >= 5'b10100 && alu_control <= 5'b10111);
    
    alu ALU (
        .a(forward_data_a),
        .b(alu_input2),
        .alu_control(alu_control),
        .result(alu_result_base),
        .zero(zero)
    );
    
    // Multiplier Unit (M Extension)
    multiplier MUL_UNIT (
       
        .a(forward_data_a),
        .b(alu_input2),
        .mul_op(alu_control[1:0]),
        .mul_result(mul_result)
    );
    
    // Divider Unit (M Extension)
    divider DIV_UNIT (
       
        .a(forward_data_a),
        .b(alu_input2),
        .div_op(alu_control[1:0]),
        .div_result(div_result)
    );
    
    // Select final result based on operation type
    assign alu_result = is_mul_op ? mul_result :
                       is_div_op ? div_result :
                       alu_result_base;
    
    assign pc_branch = ID_EX_pc + ID_EX_imm;
    
    // EX/MEM Pipeline Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            EX_MEM_alu_result <= 32'h00000000;
            EX_MEM_rs2_data <= 32'h00000000;
            EX_MEM_pc_branch <= 32'h00000000;
            EX_MEM_rd <= 5'b00000;
            EX_MEM_reg_write <= 1'b0;
            EX_MEM_mem_read <= 1'b0;
            EX_MEM_mem_write <= 1'b0;
            EX_MEM_zero <= 1'b0;
            EX_MEM_branch <= 1'b0;
        end
        else begin
            EX_MEM_alu_result <= alu_result;
            EX_MEM_rs2_data <= forward_data_b;
            EX_MEM_pc_branch <= pc_branch;
            EX_MEM_rd <= ID_EX_rd;
            EX_MEM_reg_write <= ID_EX_reg_write;
            EX_MEM_mem_read <= ID_EX_mem_read;
            EX_MEM_mem_write <= ID_EX_mem_write;
            EX_MEM_zero <= zero;
            EX_MEM_branch <= ID_EX_branch;
        end
    end

    // ========== MEM STAGE ==========
    data_memory DMEM (
        .clk(clk),
        .address(EX_MEM_alu_result),
        .write_data(EX_MEM_rs2_data),
        .mem_read(EX_MEM_mem_read),
        .mem_write(EX_MEM_mem_write),
        .read_data(mem_read_data_wire)
    );
    
    // MEM/WB Pipeline Register
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            MEM_WB_read_data <= 32'h00000000;
            MEM_WB_alu_result <= 32'h00000000;
            MEM_WB_rd <= 5'b00000;
            MEM_WB_reg_write <= 1'b0;
            MEM_WB_mem_to_reg <= 1'b0;
        end
        else begin
            MEM_WB_read_data <= mem_read_data_wire;
            MEM_WB_alu_result <= EX_MEM_alu_result;
            MEM_WB_rd <= EX_MEM_rd;
            MEM_WB_reg_write <= EX_MEM_reg_write;
            MEM_WB_mem_to_reg <= mem_to_reg;
        end
    end

    // ========== WB STAGE ==========
    assign write_back_data = MEM_WB_mem_to_reg ? MEM_WB_read_data : MEM_WB_alu_result;

endmodule

