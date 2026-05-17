`timescale 1ns / 1ps

module rv32i_core(
    input  wire        clk,
    input  wire        rst,

    output wire [31:0] imem_addr,
    input  wire [31:0] imem_rdata,

    output wire        dmem_ren,
    output wire        dmem_wen,
    output wire [3:0]  dmem_wstrb,
    output wire [31:0] dmem_addr,
    output wire [31:0] dmem_wdata,
    input  wire [31:0] dmem_rdata,

    output wire [31:0] pc,

    output wire        debug_wb_wen,
    output wire [4:0]  debug_wb_rd,
    output wire [31:0] debug_wb_data
);

    wire [31:0] inst = imem_rdata;
    wire [6:0]  opcode = inst[6:0];
    wire [4:0]  rd = inst[11:7];
    wire [2:0]  funct3 = inst[14:12];
    wire [4:0]  rs1 = inst[19:15];
    wire [4:0]  rs2 = inst[24:20];
    wire [6:0]  funct7 = inst[31:25];

    wire [31:0] pc_current;
    wire [31:0] pc_plus_4;
    wire [31:0] imm;
    wire [31:0] rs1_data;
    wire [31:0] rs2_data;
    wire [31:0] alu_src1;
    wire [31:0] alu_src2;
    wire [31:0] alu_result;
    wire [31:0] load_data;
    wire [31:0] wb_data;
    wire [31:0] redirect_addr;

    wire [3:0]  alu_op;
    wire        alu_src1_pc;
    wire        alu_src2_imm;
    wire        reg_write;
    wire        mem_read;
    wire        mem_write;
    wire [1:0]  wb_sel;
    wire        branch;
    wire        jal;
    wire        jalr;
    wire        redirect_en;

    assign pc = pc_current;
    assign pc_plus_4 = pc_current + 32'd4;
    assign imem_addr = pc_current;
    assign alu_src1 = alu_src1_pc ? pc_current : rs1_data;
    assign alu_src2 = alu_src2_imm ? imm : rs2_data;

    pc_reg u_pc_reg(
        .clk(clk),
        .rst(rst),
        .jump_en(redirect_en),
        .jump_addr(redirect_addr),
        .next_pc(pc_current)
    );

    imm_gen u_imm_gen(
        .inst(inst),
        .imm(imm)
    );

    control u_control(
        .opcode(opcode),
        .funct3(funct3),
        .funct7(funct7),
        .alu_op(alu_op),
        .alu_src1_pc(alu_src1_pc),
        .alu_src2_imm(alu_src2_imm),
        .reg_write(reg_write),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .wb_sel(wb_sel),
        .branch(branch),
        .jal(jal),
        .jalr(jalr)
    );

    registers u_registers(
        .clk(clk),
        .rs1_addr(rs1),
        .rs2_addr(rs2),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .rd_addr(rd),
        .rd_wen(reg_write),
        .rd_data(wb_data)
    );

    alu u_alu(
        .alu_op(alu_op),
        .src1(alu_src1),
        .src2(alu_src2),
        .result(alu_result)
    );

    branch_unit u_branch_unit(
        .branch(branch),
        .jal(jal),
        .jalr(jalr),
        .funct3(funct3),
        .pc(pc_current),
        .imm(imm),
        .rs1_data(rs1_data),
        .rs2_data(rs2_data),
        .redirect_en(redirect_en),
        .redirect_addr(redirect_addr)
    );

    load_store_unit u_load_store_unit(
        .mem_read(mem_read),
        .mem_write(mem_write),
        .funct3(funct3),
        .addr(alu_result),
        .store_data(rs2_data),
        .dmem_rdata(dmem_rdata),
        .dmem_ren(dmem_ren),
        .dmem_wen(dmem_wen),
        .dmem_wstrb(dmem_wstrb),
        .dmem_addr(dmem_addr),
        .dmem_wdata(dmem_wdata),
        .load_data(load_data)
    );

    writeback_mux u_writeback_mux(
        .wb_sel(wb_sel),
        .alu_result(alu_result),
        .load_data(load_data),
        .pc_plus_4(pc_plus_4),
        .imm(imm),
        .wb_data(wb_data)
    );

    assign debug_wb_wen = reg_write;
    assign debug_wb_rd = rd;
    assign debug_wb_data = wb_data;

endmodule
