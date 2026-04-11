`timescale 1ns / 1ps

module tb_counter;

    // =========================
    // 信号定义
    // =========================
    reg clk;
    reg rst_n;
    wire out_valid;

    // =========================
    // DUT 实例化
    // =========================
    counter uut (
        .clk(clk),
        .rst_n(rst_n),
        .out_valid(out_valid)
    );

    // =========================
    // 时钟生成：10ns周期（100MHz）
    // =========================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // =========================
    // 复位与激励
    // =========================
    initial begin
        rst_n = 0;

        // 保持复位一段时间
        #20;
        rst_n = 1;

        // 运行一段时间观察多个周期
        #200;

        $finish;
    end

endmodule