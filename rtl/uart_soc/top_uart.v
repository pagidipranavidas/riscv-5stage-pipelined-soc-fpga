//// ============================================================
//// top_uart.v - Basys3 RISC-V + UART
//// Prints ONLY ALU result: "XXXXXXXX\r\n" (10 bytes per result)
//// Clock: W5 (100MHz)  Reset: btnC T17  TX: A18
//// PuTTY: 9600 baud, 8N1
//// ============================================================
//module top_uart (
//    input  clk,
//    input  rst,
//    output uart_txd
//);

//// ============================================================
//// 1. CPU - uses proper output ports, no hierarchical refs
//// ============================================================
//wire [31:0] ReadData;
//wire [31:0] ALUResult;
//wire [31:0] PC_wire;

//arch2 cpu (
//    .clk          (clk),
//    .rst          (rst),
//    .ReadData     (ReadData),
//    .ALUResult_out(ALUResult),
//    .PC_out       (PC_wire)
//);

//// ============================================================
//// 2. Detect change and snapshot
//// ============================================================
//reg [31:0] alu_prev;
//reg [31:0] alu_snap;
//reg        trigger;

//always @(posedge clk or posedge rst) begin
//    if (rst) begin
//        alu_prev <= 32'hFFFF_FFFE;
//        alu_snap <= 32'd0;
//        trigger  <= 1'b0;
//    end else begin
//        trigger <= 1'b0;
//        if (ALUResult != alu_prev) begin
//            alu_prev <= ALUResult;
//            alu_snap <= ALUResult;
//            trigger  <= 1'b1;
//        end
//    end
//end

//// ============================================================
//// 3. Build message: "XXXXXXXX\r\n" = 10 bytes only
//// ============================================================
//function [7:0] to_hex;
//    input [3:0] n;
//    begin
//        if (n < 4'd10) to_hex = 8'h30 + {4'h0, n};
//        else           to_hex = 8'h37 + {4'h0, n}; // 'A'-10+0x30 = 0x37
//    end
//endfunction

//wire [7:0] msg [0:9];
//assign msg[0] = to_hex(alu_snap[31:28]);
//assign msg[1] = to_hex(alu_snap[27:24]);
//assign msg[2] = to_hex(alu_snap[23:20]);
//assign msg[3] = to_hex(alu_snap[19:16]);
//assign msg[4] = to_hex(alu_snap[15:12]);
//assign msg[5] = to_hex(alu_snap[11:8]);
//assign msg[6] = to_hex(alu_snap[7:4]);
//assign msg[7] = to_hex(alu_snap[3:0]);
//assign msg[8] = 8'h0D; // \r
//assign msg[9] = 8'h0A; // \n

//// ============================================================
//// 4. FSM: 5 states, S_START prevents byte-skip glitch
//// ============================================================
//localparam S_IDLE  = 3'd0,
//           S_LOAD  = 3'd1,
//           S_START = 3'd2,
//           S_WAIT  = 3'd3,
//           S_NEXT  = 3'd4;

//reg [2:0] state;
//reg [3:0] byte_idx;
//reg       send_byte;
//reg [7:0] send_data;
//wire      uart_busy;

//always @(posedge clk or posedge rst) begin
//    if (rst) begin
//        state     <= S_IDLE;
//        byte_idx  <= 4'd0;
//        send_byte <= 1'b0;
//        send_data <= 8'd0;
//    end else begin
//        send_byte <= 1'b0;
//        case (state)
//            S_IDLE:  if (trigger) begin
//                         byte_idx <= 4'd0;
//                         state    <= S_LOAD;
//                     end
//            S_LOAD:  begin
//                         send_data <= msg[byte_idx];
//                         send_byte <= 1'b1;
//                         state     <= S_START;
//                     end
//            S_START: state <= S_WAIT;
//            S_WAIT:  if (!uart_busy) state <= S_NEXT;
//            S_NEXT:  if (byte_idx == 4'd9)
//                         state <= S_IDLE;
//                     else begin
//                         byte_idx <= byte_idx + 4'd1;
//                         state    <= S_LOAD;
//                     end
//            default: state <= S_IDLE;
//        endcase
//    end
//end

//// ============================================================
//// 5. UART TX
//// ============================================================
//uart_tx #(.CLK_FREQ(100_000_000), .BAUD(9600)) u_uart (
//    .clk (clk), .rst(rst),
//    .send(send_byte), .data(send_data),
//    .tx  (uart_txd),  .busy(uart_busy)
//);

//endmodule


// ============================================================
// top_uart.v  -  Basys3 RISC-V + UART  (Pure Verilog 2001)
//
// Prints every ALU result as 8-digit hex on its own line:
//   0000000A
//   00000014
//   00000028
//   00000064
//   ...
//
// Clock : W5  (100 MHz)
// Reset : T17 (btnC - press after programming)
// TX    : A18
// PuTTY : 9600 baud, 8N1
// ============================================================
module top_uart (
    input  clk,
    input  rst,
    output uart_txd
);

// ============================================================
// 1.  Clock divider: 100 MHz -> 50 Hz
//     CPU gets one clock edge every 1,000,000 fast cycles = 10ms
//     Full instruction period = 20ms
//     UART sends 10 bytes at 9600 baud in 10.4ms - fits safely
// ============================================================
reg [19:0] div_cnt;
reg        cpu_clk;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        div_cnt <= 20'd0;
        cpu_clk <= 1'b0;
    end else if (div_cnt == 20'd999999) begin
        div_cnt <= 20'd0;
        cpu_clk <= ~cpu_clk;
    end else begin
        div_cnt <= div_cnt + 20'd1;
    end
end

// ============================================================
// 2.  CPU
// ============================================================
wire [31:0] ReadData;
wire [31:0] ALUResult;
wire [31:0] PC_wire;

arch2 cpu (
    .clk          (cpu_clk),
    .rst          (rst),
    .ReadData     (ReadData),
    .ALUResult_out(ALUResult),
    .PC_out       (PC_wire)
);

// ============================================================
// 3.  Detect ALU result change (on fast 100 MHz clock)
// ============================================================
reg [31:0] alu_prev;
reg [31:0] alu_snap;
reg        trigger;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        alu_prev <= 32'hFFFFFFFF;
        alu_snap <= 32'd0;
        trigger  <= 1'b0;
    end else begin
        trigger <= 1'b0;
        if (ALUResult != alu_prev) begin
            alu_prev <= ALUResult;
            alu_snap <= ALUResult;
            trigger  <= 1'b1;
        end
    end
end

// ============================================================
// 4.  Hex conversion
// ============================================================
function [7:0] to_hex;
    input [3:0] n;
    begin
        if (n < 4'd10)
            to_hex = 8'h30 + {4'h0, n};   // '0'..'9'
        else
            to_hex = 8'h37 + {4'h0, n};   // 'A'..'F'
    end
endfunction

// ============================================================
// 5.  UART send FSM
//
//     States:
//       S_IDLE  : wait for trigger, latch message bytes
//       S_LOAD  : put next byte on tx_byte, assert send for 1 cycle
//       S_START : wait one cycle for uart_tx to assert busy
//       S_WAIT  : wait until uart_tx drops busy
//       S_NEXT  : advance byte index or return to idle
// ============================================================
localparam S_IDLE  = 3'd0,
           S_LOAD  = 3'd1,
           S_START = 3'd2,
           S_WAIT  = 3'd3,
           S_NEXT  = 3'd4;

reg [2:0]  state;
reg [3:0]  idx;
reg [7:0]  tx_byte;
reg        send;
wire       busy;

// 10 latched message bytes
reg [7:0] m0, m1, m2, m3, m4;
reg [7:0] m5, m6, m7, m8, m9;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state   <= S_IDLE;
        idx     <= 4'd0;
        tx_byte <= 8'd0;
        send    <= 1'b0;
        m0 <= 8'h30; m1 <= 8'h30; m2 <= 8'h30;
        m3 <= 8'h30; m4 <= 8'h30; m5 <= 8'h30;
        m6 <= 8'h30; m7 <= 8'h30;
        m8 <= 8'h0D; m9 <= 8'h0A;
    end else begin
        send <= 1'b0;  // default: no send pulse

        case (state)

            // --------------------------------------------------
            S_IDLE: begin
                if (trigger) begin
                    // Latch 8 hex bytes + CR + LF
                    m0 <= to_hex(alu_snap[31:28]);
                    m1 <= to_hex(alu_snap[27:24]);
                    m2 <= to_hex(alu_snap[23:20]);
                    m3 <= to_hex(alu_snap[19:16]);
                    m4 <= to_hex(alu_snap[15:12]);
                    m5 <= to_hex(alu_snap[11:8]);
                    m6 <= to_hex(alu_snap[7:4]);
                    m7 <= to_hex(alu_snap[3:0]);
                    m8 <= 8'h0D;  // CR
                    m9 <= 8'h0A;  // LF
                    idx   <= 4'd0;
                    state <= S_LOAD;
                end
            end

            // --------------------------------------------------
            // Select byte and send a 1-cycle pulse to uart_tx
            S_LOAD: begin
                case (idx)
                    4'd0: tx_byte <= m0;
                    4'd1: tx_byte <= m1;
                    4'd2: tx_byte <= m2;
                    4'd3: tx_byte <= m3;
                    4'd4: tx_byte <= m4;
                    4'd5: tx_byte <= m5;
                    4'd6: tx_byte <= m6;
                    4'd7: tx_byte <= m7;
                    4'd8: tx_byte <= m8;
                    4'd9: tx_byte <= m9;
                    default: tx_byte <= 8'h30;
                endcase
                send  <= 1'b1;   // 1-cycle pulse
                state <= S_START;
            end

            // --------------------------------------------------
            // Wait one cycle: gives uart_tx time to assert busy
            S_START: begin
                state <= S_WAIT;
            end

            // --------------------------------------------------
            // Wait until uart_tx finishes (busy goes low)
            S_WAIT: begin
                if (!busy)
                    state <= S_NEXT;
            end

            // --------------------------------------------------
            S_NEXT: begin
                if (idx == 4'd9)
                    state <= S_IDLE;   // all 10 bytes done
                else begin
                    idx   <= idx + 4'd1;
                    state <= S_LOAD;
                end
            end

            default: state <= S_IDLE;

        endcase
    end
end

// ============================================================
// 6.  UART TX (clocked at 100 MHz, 9600 baud)
// ============================================================
uart_tx #(
    .CLK_FREQ (100_000_000),
    .BAUD     (9600)
) u_uart (
    .clk  (clk),
    .rst  (rst),
    .send (send),
    .data (tx_byte),
    .tx   (uart_txd),
    .busy (busy)
);

endmodule