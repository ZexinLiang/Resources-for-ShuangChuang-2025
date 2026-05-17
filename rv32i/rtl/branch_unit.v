`timescale 1ns / 1ps

module branch_unit(
    input  wire        branch,
    input  wire        jal,
    input  wire        jalr,
    input  wire [2:0]  funct3,
    input  wire [31:0] pc,
    input  wire [31:0] imm,
    input  wire [31:0] rs1_data,
    input  wire [31:0] rs2_data,

    output wire        redirect_en,
    output wire [31:0] redirect_addr
);

    wire branch_taken =
        branch &&
        ((funct3 == 3'b000 && rs1_data == rs2_data) ||
         (funct3 == 3'b001 && rs1_data != rs2_data) ||
         (funct3 == 3'b100 && $signed(rs1_data) <  $signed(rs2_data)) ||
         (funct3 == 3'b101 && $signed(rs1_data) >= $signed(rs2_data)) ||
         (funct3 == 3'b110 && rs1_data <  rs2_data) ||
         (funct3 == 3'b111 && rs1_data >= rs2_data));

    wire [31:0] pc_target = pc + imm;
    wire [31:0] jalr_target = (rs1_data + imm) & 32'hffff_fffe;

    assign redirect_en = jal || jalr || branch_taken;
    assign redirect_addr = jalr ? jalr_target : pc_target;

endmodule
