`timescale 1ns / 1ps

module alu(
    input [3:0] alu_op,             // ALU操作码
    input [31:0] src1,              // 源操作数1
    input [31:0] src2,              // 源操作数2
    output reg [31:0] result        // 结果
    );
    // 各个运算独立分离

    // 加法器 (ADD)
    wire [31:0] add_result = src1 + src2;
    // 减法器 (SUB)
    wire [31:0] sub_result = src1 - src2;

    // 比较（无符号小于）
    wire sltu_res = (src1 < src2) ? 1'b1 : 1'b0;
    // 比较（有符号小于）
    wire slt_res = ($signed(src1) < $signed(src2)) ? 1'b1 : 1'b0;

    // 右移
    wire [31:0] shift_right_res = src1 >> src2[4:0];
    wire [31:0] shift_right_arith_res = $signed(src1) >>> src2[4:0];

    // 左移 (SLL)
    wire [31:0] shift_left_res  = src1 << src2[4:0];


    // 计算结果选择
    always @(*) begin
        case (alu_op)
            // 加减法
            4'b0000: result = add_result;         // ADD
            4'b0001: result = sub_result;         // SUB

            // 逻辑运算
            4'b0010: result = src1 & src2;        // AND
            4'b0011: result = src1 | src2;        // OR
            4'b0100: result = src1 ^ src2;        // XOR

            // 比较运算
            4'b0101: result = {31'b0, sltu_res};  // SLTU
            4'b0110: result = {31'b0, slt_res};   // SLT

            // 移位运算
            4'b0111: result = shift_left_res;     // SLL
            4'b1000: result = shift_right_res;    // SRL
            4'b1001: result = shift_right_arith_res; // SRA

            default: result = 32'b0;
        endcase
    end
endmodule

/* ALU操作码说明：
0000: 加法              ADD
0001: 减法              SUB
0010: 按位与            AND
0011: 按位或            OR
0100: 按位异或          XOR
0101: 无符号小于比较    SLTU
0110: 小于比较          SLT
0111: 左移              SLL
1000: 逻辑右移          SRL
1001: 算术右移          SRA
*/