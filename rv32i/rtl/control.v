`timescale 1ns / 1ps

module control(
    input  wire [6:0] opcode,
    input  wire [2:0] funct3,
    input  wire [6:0] funct7,

    output reg  [3:0] alu_op,
    output reg        alu_src1_pc,
    output reg        alu_src2_imm,
    output reg        reg_write,
    output reg        mem_read,
    output reg        mem_write,
    output reg  [1:0] wb_sel,
    output reg        branch,
    output reg        jal,
    output reg        jalr
);

    localparam OPCODE_LOAD   = 7'b0000011;
    localparam OPCODE_MISC   = 7'b0001111;
    localparam OPCODE_OP_IMM = 7'b0010011;
    localparam OPCODE_AUIPC  = 7'b0010111;
    localparam OPCODE_STORE  = 7'b0100011;
    localparam OPCODE_OP     = 7'b0110011;
    localparam OPCODE_LUI    = 7'b0110111;
    localparam OPCODE_BRANCH = 7'b1100011;
    localparam OPCODE_JALR   = 7'b1100111;
    localparam OPCODE_JAL    = 7'b1101111;

    localparam WB_ALU = 2'b00;
    localparam WB_MEM = 2'b01;
    localparam WB_PC4 = 2'b10;
    localparam WB_IMM = 2'b11;

    always @(*) begin
        alu_op = 4'b0000;
        case (opcode)
            OPCODE_OP: begin
                case (funct3)
                    3'b000: alu_op = funct7[5] ? 4'b0001 : 4'b0000; // SUB/ADD
                    3'b001: alu_op = 4'b0111;                       // SLL
                    3'b010: alu_op = 4'b0110;                       // SLT
                    3'b011: alu_op = 4'b0101;                       // SLTU
                    3'b100: alu_op = 4'b0100;                       // XOR
                    3'b101: alu_op = funct7[5] ? 4'b1001 : 4'b1000; // SRA/SRL
                    3'b110: alu_op = 4'b0011;                       // OR
                    3'b111: alu_op = 4'b0010;                       // AND
                    default: alu_op = 4'b0000;
                endcase
            end

            OPCODE_OP_IMM: begin
                case (funct3)
                    3'b000: alu_op = 4'b0000;                       // ADDI
                    3'b001: alu_op = 4'b0111;                       // SLLI
                    3'b010: alu_op = 4'b0110;                       // SLTI
                    3'b011: alu_op = 4'b0101;                       // SLTIU
                    3'b100: alu_op = 4'b0100;                       // XORI
                    3'b101: alu_op = funct7[5] ? 4'b1001 : 4'b1000; // SRAI/SRLI
                    3'b110: alu_op = 4'b0011;                       // ORI
                    3'b111: alu_op = 4'b0010;                       // ANDI
                    default: alu_op = 4'b0000;
                endcase
            end

            default: alu_op = 4'b0000; // LOAD/STORE/AUIPC use ADD
        endcase
    end

    always @(*) begin
        case (opcode)
            OPCODE_AUIPC: alu_src1_pc = 1'b1;
            default:      alu_src1_pc = 1'b0;
        endcase
    end

    always @(*) begin
        case (opcode)
            OPCODE_OP_IMM,
            OPCODE_LOAD,
            OPCODE_STORE,
            OPCODE_AUIPC: alu_src2_imm = 1'b1;
            default:      alu_src2_imm = 1'b0;
        endcase
    end

    always @(*) begin
        reg_write = 1'b0;
        case (opcode)
            OPCODE_OP: begin
                case (funct3)
                    3'b000: reg_write = (funct7 == 7'b0000000 || funct7 == 7'b0100000);
                    3'b101: reg_write = (funct7 == 7'b0000000 || funct7 == 7'b0100000);
                    default: reg_write = (funct7 == 7'b0000000);
                endcase
            end

            OPCODE_OP_IMM: begin
                case (funct3)
                    3'b001: reg_write = (funct7 == 7'b0000000);
                    3'b101: reg_write = (funct7 == 7'b0000000 || funct7 == 7'b0100000);
                    default: reg_write = 1'b1;
                endcase
            end

            OPCODE_LOAD: begin
                case (funct3)
                    3'b000, 3'b001, 3'b010, 3'b100, 3'b101: reg_write = 1'b1;
                    default: reg_write = 1'b0;
                endcase
            end

            OPCODE_LUI,
            OPCODE_AUIPC,
            OPCODE_JAL: reg_write = 1'b1;

            OPCODE_JALR: reg_write = (funct3 == 3'b000);

            default: reg_write = 1'b0;
        endcase
    end

    always @(*) begin
        mem_read = 1'b0;
        case (opcode)
            OPCODE_LOAD: begin
                case (funct3)
                    3'b000, 3'b001, 3'b010, 3'b100, 3'b101: mem_read = 1'b1;
                    default: mem_read = 1'b0;
                endcase
            end
            default: mem_read = 1'b0;
        endcase
    end

    always @(*) begin
        mem_write = 1'b0;
        case (opcode)
            OPCODE_STORE: begin
                case (funct3)
                    3'b000, 3'b001, 3'b010: mem_write = 1'b1;
                    default: mem_write = 1'b0;
                endcase
            end
            default: mem_write = 1'b0;
        endcase
    end

    always @(*) begin
        case (opcode)
            OPCODE_LOAD: wb_sel = WB_MEM;
            OPCODE_JAL,
            OPCODE_JALR: wb_sel = WB_PC4;
            OPCODE_LUI:  wb_sel = WB_IMM;
            default:     wb_sel = WB_ALU;
        endcase
    end

    always @(*) begin
        branch = 1'b0;
        case (opcode)
            OPCODE_BRANCH: begin
                case (funct3)
                    3'b000, 3'b001, 3'b100, 3'b101, 3'b110, 3'b111: branch = 1'b1;
                    default: branch = 1'b0;
                endcase
            end
            default: branch = 1'b0;
        endcase
    end

    always @(*) begin
        case (opcode)
            OPCODE_JAL: jal = 1'b1;
            default:    jal = 1'b0;
        endcase
    end

    always @(*) begin
        case (opcode)
            OPCODE_JALR: jalr = (funct3 == 3'b000);
            default:     jalr = 1'b0;
        endcase
    end

endmodule
