`timescale 1ns / 1ps

module sync_fifo #(
    parameter DATA_WIDTH = 8, // 数据位宽
    parameter ADDR_WIDTH = 4  // 地址位宽，决定FIFO深度为 2^4 = 16
)(
    input  wire                  clk,      // 时钟信号
    input  wire                  rst_n,    // 低电平复位
    
    // 写接口
    input  wire                  wr_en,    // 写使能
    input  wire [DATA_WIDTH-1:0] wr_data,  // 写入的数据
    output wire                  full,     // FIFO满标志
    
    // 读接口
    input  wire                  rd_en,    // 读使能
    output reg  [DATA_WIDTH-1:0] rd_data,  // 读出的数据
    output wire                  empty     // FIFO空标志
);

    // 计算FIFO深度
    localparam DEPTH = 1 << ADDR_WIDTH; 

    // 内存数组 (RAM)
    reg [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    // 读写指针：位宽比地址多1位，最高位用于判断折返 (Wrap around)
    reg [ADDR_WIDTH:0] wr_ptr;
    reg [ADDR_WIDTH:0] rd_ptr;

    // 空：读写指针完全一致
    assign empty = (wr_ptr == rd_ptr);
    
    // 满：读写指针最高位不同，但真实的地址段（低位）相同
    assign full  = (wr_ptr[ADDR_WIDTH] != rd_ptr[ADDR_WIDTH]) && 
                   (wr_ptr[ADDR_WIDTH-1:0] == rd_ptr[ADDR_WIDTH-1:0]);

    // --------------------------------------------------------
    // 写逻辑 (时序逻辑)
    // --------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            wr_ptr <= {(ADDR_WIDTH+1){1'b0}};
        end 
        else if (wr_en && !full) begin
            // 写入数据到真实地址 (丢弃最高位)
            mem[wr_ptr[ADDR_WIDTH-1:0]] <= wr_data;
            // 写指针加1
            wr_ptr <= wr_ptr + 1'b1;
        end
    end

    // --------------------------------------------------------
    // 读逻辑 (时序逻辑)
    // --------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rd_ptr  <= {(ADDR_WIDTH+1){1'b0}};
            rd_data <= {DATA_WIDTH{1'b0}};
        end 
        else if (rd_en && !empty) begin
            // 从真实地址读取数据
            rd_data <= mem[rd_ptr[ADDR_WIDTH-1:0]];
            // 读指针加1
            rd_ptr  <= rd_ptr + 1'b1;
        end
    end

endmodule