`timescale 1ns / 1ps

module rv32i_soc #(
    parameter MEM_WORDS = 4096,
    parameter IMEM_FILE = "",
    parameter DMEM_FILE = ""
)(
    input  wire        clk,
    input  wire        rst,
    output wire [31:0] pc,
    output wire        debug_wb_wen,
    output wire [4:0]  debug_wb_rd,
    output wire [31:0] debug_wb_data
);

    wire [31:0] imem_addr;
    wire [31:0] imem_rdata;
    wire        dmem_ren;
    wire        dmem_wen;
    wire [3:0]  dmem_wstrb;
    wire [31:0] dmem_addr;
    wire [31:0] dmem_wdata;
    wire [31:0] dmem_rdata;

    inst_mem #(
        .MEM_WORDS(MEM_WORDS),
        .IMEM_FILE(IMEM_FILE)
    ) u_inst_mem (
        .addr(imem_addr),
        .rdata(imem_rdata)
    );

    data_mem #(
        .MEM_WORDS(MEM_WORDS),
        .DMEM_FILE(DMEM_FILE)
    ) u_data_mem (
        .clk(clk),
        .wen(dmem_wen),
        .wstrb(dmem_wstrb),
        .addr(dmem_addr),
        .wdata(dmem_wdata),
        .rdata(dmem_rdata)
    );

    rv32i_core u_core(
        .clk(clk),
        .rst(rst),
        .imem_addr(imem_addr),
        .imem_rdata(imem_rdata),
        .dmem_ren(dmem_ren),
        .dmem_wen(dmem_wen),
        .dmem_wstrb(dmem_wstrb),
        .dmem_addr(dmem_addr),
        .dmem_wdata(dmem_wdata),
        .dmem_rdata(dmem_rdata),
        .pc(pc),
        .debug_wb_wen(debug_wb_wen),
        .debug_wb_rd(debug_wb_rd),
        .debug_wb_data(debug_wb_data)
    );

endmodule
