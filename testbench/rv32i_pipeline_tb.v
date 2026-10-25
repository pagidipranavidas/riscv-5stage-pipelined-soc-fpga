// ========== TESTBENCH ==========
module rv32i_pipeline_tb;
    reg clk;
    reg reset;
    reg enable;
    reg [31:0] instruction_in;
    reg instruction_valid;
    
    // Pipeline Outputs
    wire [31:0] pc_out;
    wire [31:0] pc_address;
    wire [31:0] instruction_out;
    
    // ALU Signals
    wire [31:0] a_out;
    wire [31:0] b_out;
    wire [31:0] alu_result_out;
    
    // Memory Signals
    wire [31:0] mem_read_data;
    wire [31:0] mem_write_data;
    wire mem_read_out;
    wire mem_write_out;
    
    // Write Back
    wire [31:0] write_data_out;
    wire [4:0] rd_out;
    wire reg_write_out;
    
    // Control Signals
    wire stall_out;
    wire flush_out;
    
    // Register Outputs
    wire [31:0] x1_out;
    wire [31:0] x2_out;
    wire [31:0] x3_out;
    wire [31:0] x4_out;
    wire [31:0] x5_out;
    
    rv32i_pipeline uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .instruction_in(instruction_in),
        .instruction_valid(instruction_valid),
        .pc_out(pc_out),
        .pc_address(pc_address),
        .instruction_out(instruction_out),
        .a_out(a_out),
        .b_out(b_out),
        .alu_result_out(alu_result_out),
        .mem_read_data(mem_read_data),
        .mem_write_data(mem_write_data),
        .mem_read_out(mem_read_out),
        .mem_write_out(mem_write_out),
        .write_data_out(write_data_out),
        .rd_out(rd_out),
        .reg_write_out(reg_write_out),
        .stall_out(stall_out),
        .flush_out(flush_out),
        .x1_out(x1_out),
        .x2_out(x2_out),
        .x3_out(x3_out),
        .x4_out(x4_out),
        .x5_out(x5_out)
    );
    
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 10ns clock period = 100MHz
    end
    
    initial begin
        $dumpfile("rv32i_pipeline.vcd");
        $dumpvars(0, rv32i_pipeline_tb);
        
        reset = 1;
        enable = 0;
        instruction_in = 32'h00000013;
        instruction_valid = 0;
        
        #20 reset = 0;      // Release reset after 20ns
        #10 enable = 1;     // Enable after 10ns
        
        #2000 $finish;      // Run for 2000ns (2 microseconds)
    end
    
    // Monitor 1: Pipeline Flow with proper time display
    initial begin
        $display("\n========== RV32IM 5-Stage Pipeline Simulation ==========\n");
        $display("Clock Period: 10ns (100MHz)");
        $display("Time(ns) | PC   | Instruction | A     | B     | ALU   | RD | RegWr | Stall");
        $display("---------|------|-------------|-------|-------|-------|-------|-------|------");
        $monitor("%8t | %4h | %8h    | %5d | %5d | %5d | x%-4d | %b     | %b", 
                 $time, pc_address, instruction_out, 
                 $signed(a_out), $signed(b_out), $signed(alu_result_out),
                 rd_out, reg_write_out, stall_out);
    end
    
    // Monitor 2: Register Values
    always @(posedge clk) begin
        if (reg_write_out && rd_out != 0) begin
            $display("[WRITE] x%0d <= %0d (0x%h) at time %0t", 
                     rd_out, $signed(write_data_out), write_data_out, $time);
        end
    end
    
    // Monitor 3: Memory Operations
    always @(posedge clk) begin
        if (mem_write_out) begin
            $display("[MEM WRITE] Address: 0x%h, Data: %0d (0x%h) at time %0t", 
                     alu_result_out, $signed(mem_write_data), mem_write_data, $time);
        end
        if (mem_read_out) begin
            $display("[MEM READ] Address: 0x%h, Data: %0d (0x%h) at time %0t", 
                     alu_result_out, $signed(mem_read_data), mem_read_data, $time);
        end
    end
    
    // Final Register State
    initial begin
        #480;
        $display("\n========== Final Register Values ==========");
        $display("x1 = %0d (0x%h)", $signed(x1_out), x1_out);
        $display("x2 = %0d (0x%h)", $signed(x2_out), x2_out);
        $display("x3 = %0d (0x%h)", $signed(x3_out), x3_out);
        $display("x4 = %0d (0x%h)", $signed(x4_out), x4_out);
        $display("x5 = %0d (0x%h)", $signed(x5_out), x5_out);
        $display("===========================================\n");
    end
endmodule