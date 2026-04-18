`timescale 1ns / 1ps

module registers (
    input  wire        clk,     // write
    input  wire [4:0]  rs1_addr,    
    input  wire [4:0]  rs2_addr, 
    output wire [31:0] rs1_data,    
    output wire [31:0] rs2_data, 
     
    input  wire [4:0]  rd_addr,
    input  wire        rd_wen,    // 寄存器写使能
    input  wire [31:0] rd_data    // 最终写回数据     
);

    (* ram_style = "distributed" *) reg [31:0] reg_file [0:31];  // 例化 32 个 registers （LUTRAM 异步读，同步写）


    // 别这样写
    // rst 来的时候，给每个 lutram 复位
    // always @(negedge rst) begin
    //     for (integer i = 0; i < 32; i = i + 1) reg_file[i] = 32'b0;
    // end

    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) reg_file[i] = 32'b0;
    end

    // 同步写：由 WB 阶段驱动
    always @(posedge clk) begin
        if (rd_wen && rd_addr != 5'd0) begin  // 写使能且不写 x0
            reg_file[rd_addr] <= rd_data;
        end
    end

    // 异步读 (内部 Bypass 逻辑)
    assign rs1_data = (rs1_addr == 5'd0) ? 32'b0 : 
                      (rd_wen && rs1_addr == rd_addr) ? rd_data :  // 写地址 = 读地址，同时写使能
                      reg_file[rs1_addr];

    assign rs2_data = (rs2_addr == 5'd0) ? 32'b0 : 
                      (rd_wen && rs2_addr == rd_addr) ? rd_data : 
                      reg_file[rs2_addr];




    // 读时间/写时间  -----  读时间

    // assgin rs1_data = (rs1_addr == 5'd0) ? 32'b0 : reg_file[rs1_addr];

    // 指令1 x5写入
    // 指令2 x5读取，应该读到指令1写入的值（数据旁路）

    // clk1上升沿，x5 被计算出来
    // clk2上升沿，x5 被写回寄存器堆吗, x5 被异步读取

    // 旁路


endmodule