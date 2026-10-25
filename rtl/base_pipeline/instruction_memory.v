
// ========== INSTRUCTION MEMORY ==========
module instruction_memory(
    input [31:0] address,
    input [31:0] external_instr,
    input external_valid,
    output reg [31:0] instruction
);
    reg [31:0] mem [0:255];
    integer i;
    
    initial begin
        // RV32IM Instruction Set - Balanced Program
        // Focus: Core RV32I instructions + Key M-Extension operations
        
        // ===== Section 1: Register Initialization (0-9) =====
        mem[0]  = 32'h00A00093;  // ADDI x1, x0, 10       - x1 = 10
        mem[1]  = 32'h01400113;  // ADDI x2, x0, 20       - x2 = 20
        mem[2]  = 32'h01E00193;  // ADDI x3, x0, 30       - x3 = 30
        mem[3]  = 32'h00500213;  // ADDI x4, x0, 5        - x4 = 5
        mem[4]  = 32'h00300293;  // ADDI x5, x0, 3        - x5 = 3
        mem[5]  = 32'hFFF00313;  // ADDI x6, x0, -1       - x6 = -1
        mem[6]  = 32'h06400393;  // ADDI x7, x0, 100      - x7 = 100
        mem[7]  = 32'h00200413;  // ADDI x8, x0, 2        - x8 = 2
        mem[8]  = 32'h00800493;  // ADDI x9, x0, 8        - x9 = 8
        mem[9]  = 32'h03200513;  // ADDI x10, x0, 50      - x10 = 50
        
        // ===== Section 2: R-Type Arithmetic (10-19) =====
        mem[10] = 32'h002081B3;  // ADD x3, x1, x2        - x3 = 10 + 20 = 30
        mem[11] = 32'h40110233;  // SUB x4, x2, x1        - x4 = 20 - 10 = 10
        mem[12] = 32'h008092B3;  // SLL x5, x1, x8        - x5 = 10 << 2 = 40
        mem[13] = 32'h00A0D333;  // SRL x6, x1, x10       - x6 = 10 >> 50 = 0
        mem[14] = 32'h40A0D3B3;  // SRA x7, x1, x10       - x7 = 10 >>> 50 = 0
        mem[15] = 32'h0020A433;  // SLT x8, x1, x2        - x8 = (10 < 20) = 1
        mem[16] = 32'h0020B4B3;  // SLTU x9, x1, x2       - x9 = unsigned(10 < 20) = 1
        mem[17] = 32'h0020C533;  // XOR x10, x1, x2       - x10 = 10 ^ 20 = 30
        mem[18] = 32'h0020E5B3;  // OR x11, x1, x2        - x11 = 10 | 20 = 30
        mem[19] = 32'h0020F633;  // AND x12, x1, x2       - x12 = 10 & 20 = 0
        
        // ===== Section 3: I-Type Operations (20-29) =====
        mem[20] = 32'h01408693;  // ADDI x13, x1, 20      - x13 = 10 + 20 = 30
        mem[21] = 32'hFEC08713;  // ADDI x14, x1, -20     - x14 = 10 - 20 = -10
        mem[22] = 32'h00A0A793;  // SLTI x15, x1, 10      - x15 = (10 < 10) = 0
        mem[23] = 32'h00B0B813;  // SLTIU x16, x1, 11     - x16 = (10 < 11) = 1
        mem[24] = 32'h0140C893;  // XORI x17, x1, 20      - x17 = 10 ^ 20 = 30
        mem[25] = 32'h0140E913;  // ORI x18, x1, 20       - x18 = 10 | 20 = 30
        mem[26] = 32'h0140F993;  // ANDI x19, x1, 20      - x19 = 10 & 20 = 0
        mem[27] = 32'h00309A13;  // SLLI x20, x1, 3       - x20 = 10 << 3 = 80
        mem[28] = 32'h0020DA93;  // SRLI x21, x1, 2       - x21 = 10 >> 2 = 2
        mem[29] = 32'h4020DB13;  // SRAI x22, x1, 2       - x22 = 10 >>> 2 = 2
        
        // ===== Section 4: Load Upper Immediate & AUIPC (30-34) =====
        mem[30] = 32'h12345B97;  // AUIPC x23, 0x12345    - x23 = PC + 0x12345000
        mem[31] = 32'h00001C37;  // LUI x24, 0x1          - x24 = 0x00001000
        mem[32] = 32'hFFFFFCB7;  // LUI x25, 0xFFFFF      - x25 = 0xFFFFF000
        mem[33] = 32'h00002D37;  // LUI x26, 0x2          - x26 = 0x00002000
        mem[34] = 32'h001C0C13;  // ADDI x24, x24, 1      - x24 = 0x00001001
        
        // ===== Section 5: Branches (35-44) =====
        mem[35] = 32'h00208463;  // BEQ x1, x2, 8         - Branch if x1 == x2 (not taken)
        mem[36] = 32'h00209463;  // BNE x1, x2, 8         - Branch if x1 != x2 (taken, skip next)
        mem[37] = 32'h00108B93;  // ADDI x23, x1, 1       - x23 = 11 (might be skipped)
        mem[38] = 32'h0020C463;  // BLT x1, x2, 8         - Branch if x1 < x2 (taken)
        mem[39] = 32'h00110C13;  // ADDI x24, x2, 1       - x24 = 21 (might be skipped)
        mem[40] = 32'h00215463;  // BGE x2, x2, 8         - Branch if x2 >= x2 (taken)
        mem[41] = 32'h00108C93;  // ADDI x25, x1, 1       - x25 = 11 (might be skipped)
        mem[42] = 32'h0020E463;  // BLTU x1, x2, 8        - Branch if x1 < x2 unsigned (taken)
        mem[43] = 32'h00108D13;  // ADDI x26, x1, 1       - x26 = 11 (might be skipped)
        mem[44] = 32'h00117463;  // BGEU x2, x1, 8        - Branch if x2 >= x1 unsigned (taken)
        
        // ===== Section 6: JAL & JALR (45-49) =====
        mem[45] = 32'h00C000EF;  // JAL x1, 12            - Jump and Link, x1 = return address
        mem[46] = 32'h00000013;  // NOP (might be skipped)
        mem[47] = 32'h00000013;  // NOP (might be skipped)
        mem[48] = 32'h00000013;  // NOP (might be skipped)
        mem[49] = 32'h000080E7;  // JALR x1, x1, 0        - Jump to x1, x1 = return
        
        // ===== Section 7: Load/Store Operations (50-59) =====
        mem[50] = 32'h00112023;  // SW x1, 0(x2)          - Store x1 to mem[x2]
        mem[51] = 32'h00212223;  // SW x2, 4(x2)          - Store x2 to mem[x2+4]
        mem[52] = 32'h00312423;  // SW x3, 8(x2)          - Store x3 to mem[x2+8]
        mem[53] = 32'h00012D83;  // LW x27, 0(x2)         - Load x27 from mem[x2]
        mem[54] = 32'h00412E03;  // LW x28, 4(x2)         - Load x28 from mem[x2+4]
        mem[55] = 32'h00812E83;  // LW x29, 8(x2)         - Load x29 from mem[x2+8]
        mem[56] = 32'h00010F03;  // LB x30, 0(x2)         - Load byte
        mem[57] = 32'h00014F83;  // LBU x31, 0(x2)        - Load byte unsigned
        mem[58] = 32'h00011083;  // LH x1, 0(x2)          - Load halfword
        mem[59] = 32'h00015103;  // LHU x2, 0(x2)         - Load halfword unsigned
        
        // ===== Section 8: Store Variants (60-64) =====
        mem[60] = 32'h00D10023;  // SB x13, 0(x2)         - Store byte
        mem[61] = 32'h00E11123;  // SH x14, 2(x2)         - Store halfword
        mem[62] = 32'h00F12223;  // SW x15, 4(x2)         - Store word
        mem[63] = 32'h01012303;  // LW x6, 16(x2)         - Load from offset
        mem[64] = 32'h00612823;  // SW x6, 16(x2)         - Store to offset
        
        // ===== Section 9: M-Extension - Essential Operations (65-79) =====
        // MUL operations
        mem[65] = 32'h02208333;  // MUL x6, x1, x2        - x6 = x1 * x2
        mem[66] = 32'h023183B3;  // MUL x7, x3, x3        - x7 = x3 * x3
        mem[67] = 32'h02420433;  // MUL x8, x4, x4        - x8 = x4 * x4
        mem[68] = 32'h025284B3;  // MUL x9, x5, x5        - x9 = x5 * x5
        mem[69] = 32'h02738533;  // MUL x10, x7, x7       - x10 = x7 * x7
        
        // MULH operations
        mem[70] = 32'h022095B3;  // MULH x11, x1, x2      - x11 = upper(x1 * x2)
        mem[71] = 32'h02409633;  // MULH x12, x1, x4      - x12 = upper(x1 * x4)
        
        // DIV operations
        mem[72] = 32'h024146B3;  // DIV x13, x2, x4       - x13 = x2 / x4
        mem[73] = 32'h02515733;  // DIVU x14, x2, x5      - x14 = x2 / x5 unsigned
        
        // REM operations
        mem[74] = 32'h024167B3;  // REM x15, x2, x4       - x15 = x2 % x4
        mem[75] = 32'h02517833;  // REMU x16, x2, x5      - x16 = x2 % x5 unsigned
        
        // Additional MUL
        mem[76] = 32'h023388B3;  // MUL x17, x7, x3       - x17 = x7 * x3
        mem[77] = 32'h02440933;  // MUL x18, x8, x4       - x18 = x8 * x4
        mem[78] = 32'h025509B3;  // MUL x19, x10, x5      - x19 = x10 * x5
        mem[79] = 32'h02658A33;  // MUL x20, x11, x6      - x20 = x11 * x6
        
        // ===== Section 10: Complex Operations (80-89) =====
        mem[80] = 32'h011605B3;  // ADD x11, x12, x17     - Complex arithmetic
        mem[81] = 32'h40D60633;  // SUB x12, x12, x13     - Subtract results
        mem[82] = 32'h00E666B3;  // OR x13, x12, x14      - Logical OR
        mem[83] = 32'h00F67733;  // AND x14, x12, x15     - Logical AND
        mem[84] = 32'h010707B3;  // ADD x15, x14, x16     - Chain operations
        mem[85] = 32'h02F70833;  // MUL x16, x14, x15     - Multiply results
        mem[86] = 32'h030848B3;  // DIV x17, x16, x16     - Division
        mem[87] = 32'h00000013;  // NOP
        mem[88] = 32'h00000013;  // NOP
        mem[89] = 32'h00000013;  // NOP
        
        // Initialize rest to NOP
        for ( i = 90; i < 256; i = i + 1)
            mem[i] = 32'h00000013; // NOP (ADDI x0, x0, 0)
    end
    
    always @(*) begin
        if (external_valid)
            instruction = external_instr;
        else
            instruction = mem[address[31:2]];
    end
endmodule