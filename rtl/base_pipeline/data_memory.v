// ========== DATA MEMORY ==========
module data_memory(
    input clk,
    input [31:0] address,
    input [31:0] write_data,
    input mem_read,
    input mem_write,
    output reg [31:0] read_data
);
    reg [31:0] mem [0:255];
    integer i;
    
    initial begin
        for ( i = 0; i < 256; i = i + 1)
            mem[i] = 32'h00000000;
    end
    
    always @(posedge clk) begin
        if (mem_write)
            mem[address[31:2]] <= write_data;
    end
    
    always @(*) begin
        if (mem_read)
            read_data = mem[address[31:2]];
        else
            read_data = 32'h00000000;
    end
endmodule