`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/03/26 23:06:35
// Design Name: 
// Module Name: fir_tops
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
 
 
module fir(
input i_clk,
input i_rst,
input signed[1:0]i_din,
output signed[15:0]o_dout
    );
//滤波器系数
parameter b0 =  14'd82;
parameter b1 =  14'd317; 
parameter b2 =  14'd788;  
parameter b3 =  14'd1023;  
parameter b4 =  14'd788;   
parameter b5 =  14'd317;   
parameter b6 =  14'd82;
reg signed[1:0]x0;
reg signed[1:0]x1;
reg signed[1:0]x2;
reg signed[1:0]x3;
reg signed[1:0]x4;
reg signed[1:0]x5;
reg signed[1:0]x6;
//xn延迟
always @(posedge i_clk or posedge i_rst)
begin
     if(i_rst)
	  begin
	  x0 <= 2'd0;
	  x1 <= 2'd0;
      x2 <= 2'd0;
      x3 <= 2'd0;
      x4 <= 2'd0;
      x5 <= 2'd0;
      x6 <= 2'd0;
	  end
else begin
	  x0 <= i_din;
	  x1 <= x0;
      x2 <= x1;
      x3 <= x2;
      x4 <= x3;
      x5 <= x4;
      x6 <= x5;	 
     end
end
 
//使用乘法器IP核计算乘法
wire signed[15:0]r0;
mult multer_u0 (
  .CLK(i_clk),    // input wire CLK
  .A(x0),        // input wire [1 : 0] A
  .B(b0),        // input wire [13 : 0] B
  .SCLR(i_rst),  // input wire SCLR
  .P(r0)        // output wire [15 : 0] P
);
 
wire signed[15:0]r1;
mult multer_u1 (
  .CLK(i_clk),    // input wire CLK
  .A(x1),        // input wire [1 : 0] A
  .B(b1),        // input wire [13 : 0] B
  .SCLR(i_rst),  // input wire SCLR
  .P(r1)        // output wire [15 : 0] P
);
 
 
 
wire signed[15:0]r2;
mult multer_u2 (
  .CLK(i_clk),    // input wire CLK
  .A(x2),        // input wire [1 : 0] A
  .B(b2),        // input wire [13 : 0] B
  .SCLR(i_rst),  // input wire SCLR
  .P(r2)        // output wire [15 : 0] P
);
 
 
wire signed[15:0]r3;
mult multer_u3 (
  .CLK(i_clk),    // input wire CLK
  .A(x3),        // input wire [1 : 0] A
  .B(b3),        // input wire [13 : 0] B
  .SCLR(i_rst),  // input wire SCLR
  .P(r3)        // output wire [15 : 0] P
);
 
 
wire signed[15:0]r4;
mult multer_u4 (
  .CLK(i_clk),    // input wire CLK
  .A(x4),        // input wire [1 : 0] A
  .B(b4),        // input wire [13 : 0] B
  .SCLR(i_rst),  // input wire SCLR
  .P(r4)        // output wire [15 : 0] P
);
 
 
wire signed[15:0]r5;
mult multer_u5 (
  .CLK(i_clk),    // input wire CLK
  .A(x5),        // input wire [1 : 0] A
  .B(b5),        // input wire [13 : 0] B
  .SCLR(i_rst),  // input wire SCLR
  .P(r5)        // output wire [15 : 0] P
);
 
 
wire signed[15:0]r6;
mult multer_u6 (
  .CLK(i_clk),    // input wire CLK
  .A(x6),        // input wire [1 : 0] A
  .B(b6),        // input wire [13 : 0] B
  .SCLR(i_rst),  // input wire SCLR
  .P(r6)        // output wire [15 : 0] P
);
 
assign o_dout = r0+r1+r2+r3+r4+r5+r6;
 
endmodule