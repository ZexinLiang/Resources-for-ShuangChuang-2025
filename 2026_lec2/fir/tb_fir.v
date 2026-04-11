`timescale 1ns / 1ps


module test_fir;
reg i_clk;
reg i_rst;
reg signed[1:0]i_din;
wire signed[15:0]o_dout;
 
fir fir_u(
.i_clk              (i_clk),
.i_rst              (i_rst),
.i_din              (i_din),
.o_dout             (o_dout)
);
 
initial
begin
i_clk=1'b1;
i_rst=1'b1;
i_din=2'b00;
#100
i_rst=1'b0;
 
i_din=2'b01;
 
#10
i_din=2'b00;
 
#30
i_din=2'b01;
#10
i_din=2'b00;
 
#30
i_din=2'b01;
#10
i_din=2'b00;
 
#30
i_din=2'b01;
#10
i_din=2'b00;
 
#30
i_din=2'b11;
#10
i_din=2'b00;
 
 
#30
i_din=2'b01;
#10
i_din=2'b00;
 
#30
i_din=2'b11;
#10
i_din=2'b00;
 
#30
i_din=2'b11;
#10
i_din=2'b00;
 
#30
i_din=2'b11;
#10
i_din=2'b00;
 
#30
i_din=2'b01;
#10
i_din=2'b00;
#30
i_din=2'b01;
#10
i_din=2'b00;
 
#30
i_din=2'b01;
#10
i_din=2'b00;
 
#30
i_din=2'b01;
#10
i_din=2'b00;
 
#30
i_din=2'b11;
#10
i_din=2'b00;
 
 
#30
i_din=2'b01;
#10
i_din=2'b00;
 
#30
i_din=2'b11;
#10
i_din=2'b00;
 
#30
i_din=2'b11;
#10
i_din=2'b00;
 
#30
i_din=2'b11;
#10
i_din=2'b00;
 
#30
i_din=2'b01;
#10
i_din=2'b00;
 
end
 
always #5 i_clk=~i_clk;

endmodule