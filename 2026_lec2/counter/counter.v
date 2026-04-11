`timescale 1ns / 1ps
module counter(
    input clk,
    input rst_n,
    output led
    );
    
    // 内部计数逻辑
    localparam MAX_CNT = 32'd99_999_999;
    reg [31:0] counter = 32'b0;
    always @(posedge clk) begin
        if(!rst_n) begin
            counter <= 32'b0;
        end
        else begin
            counter <= (counter==MAX_CNT) ? 32'b0 : counter + 32'b1;
        end
    end
    
    // 输出
    assign led = counter > 32'd49_999_999 ? 1'b1 : 1'b0;

endmodule