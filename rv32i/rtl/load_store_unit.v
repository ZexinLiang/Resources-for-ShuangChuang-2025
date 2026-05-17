`timescale 1ns / 1ps

module load_store_unit(
    input  wire        mem_read,
    input  wire        mem_write,
    input  wire [2:0]  funct3,
    input  wire [31:0] addr,
    input  wire [31:0] store_data,
    input  wire [31:0] dmem_rdata,

    output wire        dmem_ren,
    output wire        dmem_wen,
    output reg  [3:0]  dmem_wstrb,
    output wire [31:0] dmem_addr,
    output wire [31:0] dmem_wdata,
    output reg  [31:0] load_data
);

    wire [7:0] byte_value =
        (addr[1:0] == 2'b00) ? dmem_rdata[7:0] :
        (addr[1:0] == 2'b01) ? dmem_rdata[15:8] :
        (addr[1:0] == 2'b10) ? dmem_rdata[23:16] :
                                dmem_rdata[31:24];
    wire [15:0] half_value = addr[1] ? dmem_rdata[31:16] : dmem_rdata[15:0];

    assign dmem_addr = addr;
    assign dmem_ren = mem_read;
    assign dmem_wen = mem_write;
    assign dmem_wdata = store_data << {addr[1:0], 3'b000};

    always @(*) begin
        case (funct3)
            3'b000: dmem_wstrb = 4'b0001 << addr[1:0];        // SB
            3'b001: dmem_wstrb = addr[1] ? 4'b1100 : 4'b0011; // SH
            3'b010: dmem_wstrb = 4'b1111;                     // SW
            default: dmem_wstrb = 4'b0000;
        endcase
    end

    always @(*) begin
        case (funct3)
            3'b000: load_data = {{24{byte_value[7]}}, byte_value};  // LB
            3'b001: load_data = {{16{half_value[15]}}, half_value}; // LH
            3'b010: load_data = dmem_rdata;                         // LW
            3'b100: load_data = {24'b0, byte_value};                // LBU
            3'b101: load_data = {16'b0, half_value};                // LHU
            default: load_data = 32'b0;
        endcase
    end

endmodule
