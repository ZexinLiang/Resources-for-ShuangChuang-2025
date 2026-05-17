`timescale 1ns / 1ps

module data_mem #(
    parameter MEM_WORDS = 4096,
    parameter DMEM_FILE = ""
)(
    input  wire        clk,
    input  wire        wen,
    input  wire [3:0]  wstrb,
    input  wire [31:0] addr,
    input  wire [31:0] wdata,
    output wire [31:0] rdata
);

    reg [31:0] mem [0:MEM_WORDS-1];
    wire [31:0] word_addr = addr >> 2;

    integer i;
    initial begin
        for (i = 0; i < MEM_WORDS; i = i + 1) begin
            mem[i] = 32'b0;
        end

        if (DMEM_FILE != "") begin
            $readmemh(DMEM_FILE, mem);
        end
    end

    assign rdata = (word_addr < MEM_WORDS) ? mem[word_addr] : 32'b0;

    always @(posedge clk) begin
        if (wen && word_addr < MEM_WORDS) begin
            if (wstrb[0]) mem[word_addr][7:0]   <= wdata[7:0];
            if (wstrb[1]) mem[word_addr][15:8]  <= wdata[15:8];
            if (wstrb[2]) mem[word_addr][23:16] <= wdata[23:16];
            if (wstrb[3]) mem[word_addr][31:24] <= wdata[31:24];
        end
    end

endmodule
