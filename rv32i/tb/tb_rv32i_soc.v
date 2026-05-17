`timescale 1ns / 1ps

module tb_rv32i_soc;
    reg clk;
    reg rst;

    wire [31:0] pc;
    wire        debug_wb_wen;
    wire [4:0]  debug_wb_rd;
    wire [31:0] debug_wb_data;

    rv32i_soc #(
        .MEM_WORDS(256)
    ) dut (
        .clk(clk),
        .rst(rst),
        .pc(pc),
        .debug_wb_wen(debug_wb_wen),
        .debug_wb_rd(debug_wb_rd),
        .debug_wb_data(debug_wb_data)
    );

    function [31:0] r_type;
        input [6:0] funct7;
        input [4:0] rs2;
        input [4:0] rs1;
        input [2:0] funct3;
        input [4:0] rd;
        input [6:0] opcode;
        begin
            r_type = {funct7, rs2, rs1, funct3, rd, opcode};
        end
    endfunction

    function [31:0] i_type;
        input integer imm;
        input [4:0] rs1;
        input [2:0] funct3;
        input [4:0] rd;
        input [6:0] opcode;
        begin
            i_type = {imm[11:0], rs1, funct3, rd, opcode};
        end
    endfunction

    function [31:0] s_type;
        input integer imm;
        input [4:0] rs2;
        input [4:0] rs1;
        input [2:0] funct3;
        input [6:0] opcode;
        begin
            s_type = {imm[11:5], rs2, rs1, funct3, imm[4:0], opcode};
        end
    endfunction

    function [31:0] b_type;
        input integer imm;
        input [4:0] rs2;
        input [4:0] rs1;
        input [2:0] funct3;
        input [6:0] opcode;
        begin
            b_type = {imm[12], imm[10:5], rs2, rs1, funct3, imm[4:1], imm[11], opcode};
        end
    endfunction

    function [31:0] u_type;
        input [19:0] imm20;
        input [4:0] rd;
        input [6:0] opcode;
        begin
            u_type = {imm20, rd, opcode};
        end
    endfunction

    function [31:0] j_type;
        input integer imm;
        input [4:0] rd;
        input [6:0] opcode;
        begin
            j_type = {imm[20], imm[10:1], imm[11], imm[19:12], rd, opcode};
        end
    endfunction

    initial begin
        clk = 1'b0;
        forever #5 clk = ~clk;
    end

    initial begin
        rst = 1'b1;
        #1;

        dut.u_inst_mem.mem[0]  = u_type(20'h12345, 5'd1,  7'b0110111);                      // lui   x1, 0x12345
        dut.u_inst_mem.mem[1]  = u_type(20'h00000, 5'd2,  7'b0010111);                      // auipc x2, 0
        dut.u_inst_mem.mem[2]  = i_type(-1,       5'd0, 3'b000, 5'd3,  7'b0010011);          // addi  x3, x0, -1
        dut.u_inst_mem.mem[3]  = i_type(0,        5'd3, 3'b010, 5'd4,  7'b0010011);          // slti  x4, x3, 0
        dut.u_inst_mem.mem[4]  = i_type(1,        5'd3, 3'b011, 5'd5,  7'b0010011);          // sltiu x5, x3, 1
        dut.u_inst_mem.mem[5]  = i_type(12'h0ff,  5'd1, 3'b100, 5'd6,  7'b0010011);          // xori  x6, x1, 0xff
        dut.u_inst_mem.mem[6]  = i_type(12'h0f0,  5'd0, 3'b110, 5'd7,  7'b0010011);          // ori   x7, x0, 0xf0
        dut.u_inst_mem.mem[7]  = i_type(12'h0ff,  5'd6, 3'b111, 5'd8,  7'b0010011);          // andi  x8, x6, 0xff
        dut.u_inst_mem.mem[8]  = i_type(4,        5'd8, 3'b001, 5'd9,  7'b0010011);          // slli  x9, x8, 4
        dut.u_inst_mem.mem[9]  = i_type(4,        5'd9, 3'b101, 5'd10, 7'b0010011);          // srli  x10, x9, 4
        dut.u_inst_mem.mem[10] = i_type(12'h404,  5'd3, 3'b101, 5'd11, 7'b0010011);          // srai  x11, x3, 4
        dut.u_inst_mem.mem[11] = r_type(7'b0000000, 5'd10, 5'd9, 3'b000, 5'd12, 7'b0110011); // add   x12, x9, x10
        dut.u_inst_mem.mem[12] = r_type(7'b0100000, 5'd10, 5'd9, 3'b000, 5'd13, 7'b0110011); // sub   x13, x9, x10
        dut.u_inst_mem.mem[13] = r_type(7'b0000000, 5'd4,  5'd10,3'b001, 5'd14, 7'b0110011); // sll   x14, x10, x4
        dut.u_inst_mem.mem[14] = r_type(7'b0000000, 5'd0,  5'd3, 3'b010, 5'd15, 7'b0110011); // slt   x15, x3, x0
        dut.u_inst_mem.mem[15] = r_type(7'b0000000, 5'd0,  5'd3, 3'b011, 5'd16, 7'b0110011); // sltu  x16, x3, x0
        dut.u_inst_mem.mem[16] = r_type(7'b0000000, 5'd10, 5'd9, 3'b100, 5'd17, 7'b0110011); // xor   x17, x9, x10
        dut.u_inst_mem.mem[17] = r_type(7'b0000000, 5'd4,  5'd9, 3'b101, 5'd18, 7'b0110011); // srl   x18, x9, x4
        dut.u_inst_mem.mem[18] = r_type(7'b0100000, 5'd4,  5'd3, 3'b101, 5'd19, 7'b0110011); // sra   x19, x3, x4
        dut.u_inst_mem.mem[19] = r_type(7'b0000000, 5'd8,  5'd7, 3'b110, 5'd20, 7'b0110011); // or    x20, x7, x8
        dut.u_inst_mem.mem[20] = r_type(7'b0000000, 5'd8,  5'd6, 3'b111, 5'd21, 7'b0110011); // and   x21, x6, x8
        dut.u_inst_mem.mem[21] = s_type(0,        5'd12,5'd0, 3'b010, 7'b0100011);           // sw    x12, 0(x0)
        dut.u_inst_mem.mem[22] = i_type(0,        5'd0, 3'b010, 5'd22, 7'b0000011);          // lw    x22, 0(x0)
        dut.u_inst_mem.mem[23] = s_type(4,        5'd3, 5'd0, 3'b000, 7'b0100011);           // sb    x3, 4(x0)
        dut.u_inst_mem.mem[24] = i_type(4,        5'd0, 3'b000, 5'd23, 7'b0000011);          // lb    x23, 4(x0)
        dut.u_inst_mem.mem[25] = i_type(4,        5'd0, 3'b100, 5'd24, 7'b0000011);          // lbu   x24, 4(x0)
        dut.u_inst_mem.mem[26] = i_type(12'h345,  5'd0, 3'b000, 5'd25, 7'b0010011);          // addi  x25, x0, 0x345
        dut.u_inst_mem.mem[27] = s_type(6,        5'd25,5'd0, 3'b001, 7'b0100011);           // sh    x25, 6(x0)
        dut.u_inst_mem.mem[28] = i_type(6,        5'd0, 3'b001, 5'd26, 7'b0000011);          // lh    x26, 6(x0)
        dut.u_inst_mem.mem[29] = i_type(6,        5'd0, 3'b101, 5'd27, 7'b0000011);          // lhu   x27, 6(x0)
        dut.u_inst_mem.mem[30] = b_type(8,        5'd12,5'd22,3'b000, 7'b1100011);           // beq   x22, x12, +8
        dut.u_inst_mem.mem[31] = i_type(1,        5'd0, 3'b000, 5'd28, 7'b0010011);
        dut.u_inst_mem.mem[32] = b_type(8,        5'd12,5'd22,3'b001, 7'b1100011);           // bne   x22, x12, +8
        dut.u_inst_mem.mem[33] = i_type(0,        5'd0, 3'b000, 5'd28, 7'b0010011);
        dut.u_inst_mem.mem[34] = b_type(8,        5'd0, 5'd3, 3'b100, 7'b1100011);           // blt   x3, x0, +8
        dut.u_inst_mem.mem[35] = i_type(2,        5'd0, 3'b000, 5'd28, 7'b0010011);
        dut.u_inst_mem.mem[36] = b_type(8,        5'd3, 5'd0, 3'b101, 7'b1100011);           // bge   x0, x3, +8
        dut.u_inst_mem.mem[37] = i_type(3,        5'd0, 3'b000, 5'd28, 7'b0010011);
        dut.u_inst_mem.mem[38] = b_type(8,        5'd3, 5'd0, 3'b110, 7'b1100011);           // bltu  x0, x3, +8
        dut.u_inst_mem.mem[39] = i_type(4,        5'd0, 3'b000, 5'd28, 7'b0010011);
        dut.u_inst_mem.mem[40] = b_type(8,        5'd0, 5'd3, 3'b111, 7'b1100011);           // bgeu  x3, x0, +8
        dut.u_inst_mem.mem[41] = i_type(5,        5'd0, 3'b000, 5'd28, 7'b0010011);
        dut.u_inst_mem.mem[42] = j_type(8,        5'd29, 7'b1101111);                        // jal   x29, +8
        dut.u_inst_mem.mem[43] = i_type(6,        5'd0, 3'b000, 5'd28, 7'b0010011);
        dut.u_inst_mem.mem[44] = u_type(20'h00000, 5'd30, 7'b0010111);                      // auipc x30, 0
        dut.u_inst_mem.mem[45] = i_type(12,       5'd30,3'b000, 5'd31, 7'b1100111);          // jalr  x31, 12(x30)
        dut.u_inst_mem.mem[46] = i_type(7,        5'd0, 3'b000, 5'd28, 7'b0010011);
        dut.u_inst_mem.mem[47] = i_type(8,        5'd0, 3'b000, 5'd28, 7'b0010011);
        dut.u_inst_mem.mem[48] = i_type(9,        5'd0, 3'b000, 5'd28, 7'b0010011);
        dut.u_inst_mem.mem[49] = j_type(0,        5'd0,  7'b1101111);                       // jal   x0, 0

        #19;
        rst = 1'b0;

        #700;
        check_result;
        $display("PASS: RV32I single-cycle self-check passed");
        $finish;
    end

    task expect_reg;
        input [4:0] reg_id;
        input [31:0] expected;
        begin
            if (dut.u_core.u_registers.reg_file[reg_id] !== expected) begin
                $display("FAIL: x%0d expected=%h actual=%h",
                         reg_id, expected, dut.u_core.u_registers.reg_file[reg_id]);
                $stop;
            end
        end
    endtask

    task check_result;
        begin
            expect_reg(1,  32'h12345000);
            expect_reg(2,  32'h80000004);
            expect_reg(3,  32'hffffffff);
            expect_reg(4,  32'd1);
            expect_reg(5,  32'd0);
            expect_reg(6,  32'h123450ff);
            expect_reg(7,  32'h000000f0);
            expect_reg(8,  32'h000000ff);
            expect_reg(9,  32'h00000ff0);
            expect_reg(10, 32'h000000ff);
            expect_reg(11, 32'hffffffff);
            expect_reg(12, 32'h000010ef);
            expect_reg(13, 32'h00000ef1);
            expect_reg(14, 32'h000001fe);
            expect_reg(15, 32'd1);
            expect_reg(16, 32'd0);
            expect_reg(17, 32'h00000f0f);
            expect_reg(18, 32'h000007f8);
            expect_reg(19, 32'hffffffff);
            expect_reg(20, 32'h000000ff);
            expect_reg(21, 32'h000000ff);
            expect_reg(22, 32'h000010ef);
            expect_reg(23, 32'hffffffff);
            expect_reg(24, 32'h000000ff);
            expect_reg(25, 32'h00000345);
            expect_reg(26, 32'h00000345);
            expect_reg(27, 32'h00000345);
            expect_reg(28, 32'd9);
            expect_reg(29, 32'h800000ac);
            expect_reg(30, 32'h800000b0);
            expect_reg(31, 32'h800000b8);

            if (dut.u_data_mem.mem[0] !== 32'h000010ef || dut.u_data_mem.mem[1] !== 32'h034500ff) begin
                $display("FAIL: dmem0=%h dmem1=%h", dut.u_data_mem.mem[0], dut.u_data_mem.mem[1]);
                $stop;
            end
        end
    endtask

endmodule
