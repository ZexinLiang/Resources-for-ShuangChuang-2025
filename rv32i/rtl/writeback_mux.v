`timescale 1ns / 1ps

module writeback_mux(
    input  wire [1:0]  wb_sel,
    input  wire [31:0] alu_result,
    input  wire [31:0] load_data,
    input  wire [31:0] pc_plus_4,
    input  wire [31:0] imm,
    output reg  [31:0] wb_data
);

    localparam WB_ALU = 2'b00;
    localparam WB_MEM = 2'b01;
    localparam WB_PC4 = 2'b10;
    localparam WB_IMM = 2'b11;

    always @(*) begin
        case (wb_sel)
            WB_MEM: wb_data = load_data;
            WB_PC4: wb_data = pc_plus_4;
            WB_IMM: wb_data = imm;
            default: wb_data = alu_result;
        endcase
    end

endmodule
