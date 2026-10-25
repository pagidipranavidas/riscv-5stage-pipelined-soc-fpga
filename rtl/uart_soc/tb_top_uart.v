
module tb_top_uart;
    reg  clk, rst;
    wire uart_txd;

    top_uart uut (.clk(clk), .rst(rst), .uart_txd(uart_txd));

    initial clk = 0;
    always #5 clk = ~clk;

    // ?? signals already available via proper ports ??
    wire [31:0] ALUResult = uut.ALUResult;
    wire [31:0] PC        = uut.PC_wire;

    // ?? SrcA / SrcB via hierarchical ref (sim only, fine for testbench) ??
    wire [31:0] SrcA      = uut.cpu.RD1;
    wire [31:0] SrcB      = uut.cpu.srcB;
    wire        Zero      = uut.cpu.zero;
    wire [3:0]  ALUCtrl   = uut.cpu.Control;

    reg  [31:0] prev_alu;

    initial begin
        $display("================================================================");
        $display("  PC  |  SrcA  |  SrcB  | ALUResult | Zero | ALUCtrl");
        $display("----------------------------------------------------------------");
        prev_alu = 32'hFFFF_FFFE;
        repeat(600) begin
            @(posedge clk); #1;
            if (ALUResult !== prev_alu) begin
                $display("   %6d | %6d | %9d |  %b   | %4b",
                 //   PC,
                    $signed(SrcA),
                    $signed(SrcB),
                    $signed(ALUResult),
                    Zero,
                    ALUCtrl);
                prev_alu = ALUResult;
            end
        end
        $display("================================================================");
    //    $finish;
    end

    // ?? waveform dump for Vivado / GTKWave ??
    initial begin
        $dumpfile("tb_top_uart.vcd");
        $dumpvars(0, tb_top_uart);   // dump ALL signals in design
    end

    initial begin rst = 1; #12; rst = 0; end
endmodule


//`timescale 1ns / 1ps

//module tb_top_uart;

//reg  clk, rst;
//wire uart_txd;

//top_uart uut (
//    .clk      (clk),
//    .rst      (rst),
//    .uart_txd (uart_txd)
//);

//// 100 MHz clock
//initial clk = 0;
//always #5 clk = ~clk;

//// Probe signals
//wire [31:0] ALUResult = uut.ALUResult;
//wire [31:0] PC        = uut.PC_wire;
//wire [31:0] SrcA      = uut.cpu.RD1;
//wire [31:0] SrcB      = uut.cpu.srcB;
//wire        Zero      = uut.cpu.zero;
//wire [3:0]  ALUCtrl   = uut.cpu.Control;

//reg [31:0] prev_alu;
//integer    count;

//initial begin
//    $dumpfile("tb_top_uart.vcd");
//    $dumpvars(0, tb_top_uart);

//    // Reset
//    rst = 1;
//    repeat(10) @(posedge clk);

//    // *** TRICK: Force divider to roll over every 5 cycles ***
//    // This makes cpu_clk toggle fast without editing top_uart.v
//    force uut.div_cnt = 20'd999995;

//    rst = 0;

//    prev_alu = 32'hFFFF_FFFF;
//    count    = 0;

//    $display("=========================================================");
//    $display("  PC      |    SrcA    |    SrcB    | ALUResult  | Z | Ctrl");
//    $display("---------------------------------------------------------");

//    forever begin
//        @(posedge clk); #1;

//        // Keep forcing div_cnt near rollover every cycle
//        force uut.div_cnt = 20'd999995;

//        if (ALUResult !== prev_alu) begin
//            $display("0x%08X | %10d | %10d | %10d | %b | %04b",
//                PC,
//                $signed(SrcA),
//                $signed(SrcB),
//                $signed(ALUResult),
//                Zero,
//                ALUCtrl);
//            prev_alu = ALUResult;
//            count    = count + 1;

//            if (count == 20) begin
//                $display("=========================================================");
//                $display("Done: printed %0d results", count);
//                $finish;
//            end
//        end
//    end
//end

//// Safety timeout
//initial begin
//    #5_000_000;
//    $display("TIMEOUT - only %0d results printed", count);
//    $finish;
//end

//endmodule
