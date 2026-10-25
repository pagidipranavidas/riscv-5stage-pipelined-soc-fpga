// ============================================================
// uart_tx.v  -  Simple 8N1 UART Transmitter
// CLK_FREQ : FPGA clock frequency in Hz  (default 100 MHz)
// BAUD     : desired baud rate           (default 9600)
// ============================================================
module uart_tx #(
    parameter CLK_FREQ = 100_000_000,
    parameter BAUD     = 9600
)(
    input        clk,
    input        rst,
    input        send,       // pulse high for 1 cycle to start TX
    input  [7:0] data,       // byte to transmit
    output reg   tx,         // serial output ? FPGA pin ? PuTTY
    output reg   busy        // high while transmitting
);

localparam CLKS_PER_BIT = CLK_FREQ / BAUD;  // 10417 for 100MHz/9600

// States
localparam IDLE  = 2'd0,
           START = 2'd1,
           DATA  = 2'd2,
           STOP  = 2'd3;

reg [1:0]  state;
reg [13:0] clk_cnt;
reg [2:0]  bit_idx;
reg [7:0]  tx_data;

always @(posedge clk or posedge rst) begin
    if (rst) begin
        state   <= IDLE;
        tx      <= 1'b1;   // idle line is HIGH
        busy    <= 1'b0;
        clk_cnt <= 0;
        bit_idx <= 0;
    end else begin
        case (state)

            IDLE: begin
                tx   <= 1'b1;
                busy <= 1'b0;
                if (send) begin
                    tx_data <= data;
                    state   <= START;
                    busy    <= 1'b1;
                    clk_cnt <= 0;
                end
            end

            START: begin
                tx <= 1'b0;          // start bit
                if (clk_cnt == CLKS_PER_BIT - 1) begin
                    clk_cnt <= 0;
                    bit_idx <= 0;
                    state   <= DATA;
                end else
                    clk_cnt <= clk_cnt + 1;
            end

            DATA: begin
                tx <= tx_data[bit_idx];
                if (clk_cnt == CLKS_PER_BIT - 1) begin
                    clk_cnt <= 0;
                    if (bit_idx == 7) begin
                        state <= STOP;
                    end else
                        bit_idx <= bit_idx + 1;
                end else
                    clk_cnt <= clk_cnt + 1;
            end

            STOP: begin
                tx <= 1'b1;          // stop bit
                if (clk_cnt == CLKS_PER_BIT - 1) begin
                    clk_cnt <= 0;
                    state   <= IDLE;
                    busy    <= 1'b0;
                end else
                    clk_cnt <= clk_cnt + 1;
            end

            default: state <= IDLE;
        endcase
    end
end

endmodule