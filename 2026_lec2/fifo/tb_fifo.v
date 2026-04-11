`timescale 1ns / 1ps

module tb_fifo();

    //为了测试更快看到满/空状态，把深度改小一点（深度设置为8）
    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 3; 


    reg                   clk;
    reg                   rst_n;
    reg                   wr_en;
    reg  [DATA_WIDTH-1:0] wr_data;
    wire                  full;
    reg                   rd_en;
    wire [DATA_WIDTH-1:0] rd_data;
    wire                  empty;

    // 例化 FIFO
    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) u_fifo (
        .clk     (clk),
        .rst_n   (rst_n),
        .wr_en   (wr_en),
        .wr_data (wr_data),
        .full    (full),
        .rd_en   (rd_en),
        .rd_data (rd_data),
        .empty   (empty)
    );

    // 生成时钟 (周期 10ns)
    always #5 clk = ~clk;

    // 循环变量
    integer i;

    // 测试主流程
    initial begin
        // 1. 初始化
        clk = 0;
        rst_n = 0;
        wr_en = 0;
        wr_data = 0;
        rd_en = 0;
        
        // 释放复位
        #15 rst_n = 1;

        // 深度为8，我们尝试写9次，第9次应该写不进去
        for (i = 0; i < 9; i = i + 1) begin
            @(posedge clk);
            wr_en   = 1;
            wr_data = 8'hA0 + i; // 写入 A0, A1, A2...
        end
        @(posedge clk);
        wr_en = 0; // 停止写入
        #20;


        // FIFO里有8个数据，我们尝试读9次，第9次读出的数据不变
        for (i = 0; i < 9; i = i + 1) begin
            @(posedge clk);
            rd_en = 1;
        end
        @(posedge clk);
        rd_en = 0; // 停止读取
        #20;

        // 边读边写
        // 先写入一个数据
        @(posedge clk);
        wr_en = 1; wr_data = 8'h11;
        
        // 第二个周期：一边写新数据，一边读出上一个数据
        @(posedge clk);
        wr_en = 1; wr_data = 8'h22; 
        rd_en = 1; 

        // 第三个周期：继续写和读
        @(posedge clk);
        wr_en = 1; wr_data = 8'h33; 
        rd_en = 1;

        // 停止
        @(posedge clk);
        wr_en = 0; rd_en = 0;

        // 结束仿真
        #50;
        $finish;
    end

    //在控制台打印信号状态，方便没有看波形的同学也能理解
    initial begin
        $monitor("TIME:%0t | FULL:%b EMPTY:%b | WEN:%b W_DATA:%h | REN:%b R_DATA:%h", 
                 $time, full, empty, wr_en, wr_data, rd_en, rd_data);
    end

endmodule