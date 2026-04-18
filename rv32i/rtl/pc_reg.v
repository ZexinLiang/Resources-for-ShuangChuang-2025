`timescale 1ns / 1ps

module pc_reg(
    input  wire        clk,                 // 时钟信号
    input  wire        rst,                 // 复位信号，高电平有效
    
    input  wire        jump_en,            // 跳转使能信号
    input  wire [31:0] jump_addr,           // 跳转目标地址
    
    output reg  [31:0] next_pc              // 当前PC地址
);

    localparam INIT_PC = 32'h8000_0000;     // 初始PC地址

    // 同步
    always @(posedge clk) begin
        if (rst) begin
            next_pc <= INIT_PC;             // 复位时PC设为0
        end 
        else if (jump_en) begin
            next_pc <= jump_addr;           // 跳转到目标地址
        end 
        else begin
            next_pc <= next_pc + 4;         // 顺序执行，PC加4
        end
    end

endmodule