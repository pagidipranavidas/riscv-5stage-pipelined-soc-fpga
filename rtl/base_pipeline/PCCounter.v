//module PCCounter( clk, PCNext, PC);

//input clk;
//input[31:0]PCNext;
//output reg [31:0] PC;

//always@(posedge clk)

//begin
//PC <= PCNext;
//end
//initial begin
//PC=32'b0;
//end

//endmodule


// ============================================================
// PCCounter.v  - FIXED: Added async reset so PC returns to 0
// ============================================================
module PCCounter(clk, rst, PCNext, PC);

input         clk;
input         rst;       // <-- ADDED: active-high async reset
input  [31:0] PCNext;
output reg [31:0] PC;

always @(posedge clk or posedge rst)
begin
    if (rst)
        PC <= 32'b0;     // <-- FIXED: reset PC to 0
    else
        PC <= PCNext;
end

endmodule