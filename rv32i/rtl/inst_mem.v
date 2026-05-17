`timescale 1ns / 1ps

module inst_mem #(
    parameter MEM_WORDS = 4096,
    parameter IMEM_FILE = "",
    parameter BASE_ADDR = 32'h8000_0000
)(
    input  wire [31:0] addr,
    output wire [31:0] rdata
);

    reg [31:0] mem [0:MEM_WORDS-1];
    wire [31:0] word_addr = (addr - BASE_ADDR) >> 2;

    integer i;
    initial begin
        for (i = 0; i < MEM_WORDS; i = i + 1) begin
            mem[i] = 32'h0000_0013; // NOP: addi x0, x0, 0
        end

        if (IMEM_FILE != "") begin
            $readmemh(IMEM_FILE, mem);
        end
    end

    assign rdata = (word_addr < MEM_WORDS) ? mem[word_addr] : 32'h0000_0013;

endmodule
