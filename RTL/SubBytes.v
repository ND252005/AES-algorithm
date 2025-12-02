/*
Hàm thay thế từng bytes trong 128 bit, 1 phần của aes 
*/
`timescale 1ns/1ps

module SubBytes #(
    parameter DATA_LEN = 128,
    parameter NUM_OF_BYTES = DATA_LEN >> 3 // số lượng byte cần thay thế number_of_bytes = DATA_LEN/8
) (
    input clk,
    input reset,
    input valid_in, // biến kiểm tra tín hiệu đầu vào hợp lệ không 
  	input [DATA_LEN-1:0] data_in, //dữ liệu đầu vào
    output reg valid_out, // biến kiểm tra tín hiệu đầu ra
    output [DATA_LEN-1:0] data_out //dữ liệu đầu ra
);

// tạo ra các instance Sbyte, sub các byte dữ liệu cùng lúc
// -----------------------------------------------------------
    // Byte 0 (i=0): Bits [7 : 0]
    // -----------------------------------------------------------
    Sbox Sbyte_0 (
        .clk(clk), 
        .reset(reset),
        .valid_in(valid_in), 
        .data_in(data_in[7:0]), 
        .data_out(data_out[7:0])
    );

    // -----------------------------------------------------------
    // Byte 1 (i=1): Bits [15 : 8]
    // -----------------------------------------------------------
    Sbox Sbyte_1 (
        .clk(clk), 
        .reset(reset),
        .valid_in(valid_in), 
        .data_in(data_in[15:8]), 
        .data_out(data_out[15:8])
    );

    // -----------------------------------------------------------
    // Byte 2 (i=2): Bits [23 : 16]
    // -----------------------------------------------------------
    Sbox Sbyte_2 (
        .clk(clk), 
        .reset(reset),
        .valid_in(valid_in), 
        .data_in(data_in[23:16]), 
        .data_out(data_out[23:16])
    );

    // -----------------------------------------------------------
    // Byte 3 (i=3): Bits [31 : 24]
    // -----------------------------------------------------------
    Sbox Sbyte_3 (
        .clk(clk), 
        .reset(reset),
        .valid_in(valid_in), 
        .data_in(data_in[31:24]), 
        .data_out(data_out[31:24])
    );

    // -----------------------------------------------------------
    // Byte 4 (i=4): Bits [39 : 32]
    // -----------------------------------------------------------
    Sbox Sbyte_4 (
        .clk(clk), 
        .reset(reset),
        .valid_in(valid_in), 
        .data_in(data_in[39:32]), 
        .data_out(data_out[39:32])
    );

    // -----------------------------------------------------------
    // Byte 5 (i=5): Bits [47 : 40]
    // -----------------------------------------------------------
    Sbox Sbyte_5 (
        .clk(clk), 
        .reset(reset),
        .valid_in(valid_in), 
        .data_in(data_in[47:40]), 
        .data_out(data_out[47:40])
    );

    // -----------------------------------------------------------
    // Byte 6 (i=6): Bits [55 : 48]
    // -----------------------------------------------------------
    Sbox Sbyte_6 (
        .clk(clk), 
        .reset(reset),
        .valid_in(valid_in), 
        .data_in(data_in[55:48]), 
        .data_out(data_out[55:48])
    );

    // -----------------------------------------------------------
    // Byte 7 (i=7): Bits [63 : 56]
    // -----------------------------------------------------------
    Sbox Sbyte_7 (
        .clk(clk), 
        .reset(reset),
        .valid_in(valid_in), 
        .data_in(data_in[63:56]), 
        .data_out(data_out[63:56])
    );

    // -----------------------------------------------------------
    // Byte 8 (i=8): Bits [71 : 64]
    // -----------------------------------------------------------
    Sbox Sbyte_8 (
        .clk(clk), 
        .reset(reset),
        .valid_in(valid_in), 
        .data_in(data_in[71:64]), 
        .data_out(data_out[71:64])
    );

    // -----------------------------------------------------------
    // Byte 9 (i=9): Bits [79 : 72]
    // -----------------------------------------------------------
    Sbox Sbyte_9 (
        .clk(clk), 
        .reset(reset),
        .valid_in(valid_in), 
        .data_in(data_in[79:72]), 
        .data_out(data_out[79:72])
    );

    // -----------------------------------------------------------
    // Byte 10 (i=10): Bits [87 : 80]
    // -----------------------------------------------------------
    Sbox Sbyte_10 (
        .clk(clk), 
        .reset(reset),
        .valid_in(valid_in), 
        .data_in(data_in[87:80]), 
        .data_out(data_out[87:80])
    );

    // -----------------------------------------------------------
    // Byte 11 (i=11): Bits [95 : 88]
    // -----------------------------------------------------------
    Sbox Sbyte_11 (
        .clk(clk), 
        .reset(reset),
        .valid_in(valid_in), 
        .data_in(data_in[95:88]), 
        .data_out(data_out[95:88])
    );

    // -----------------------------------------------------------
    // Byte 12 (i=12): Bits [103 : 96]
    // -----------------------------------------------------------
    Sbox Sbyte_12 (
        .clk(clk), 
        .reset(reset),
        .valid_in(valid_in), 
        .data_in(data_in[103:96]), 
        .data_out(data_out[103:96])
    );

    // -----------------------------------------------------------
    // Byte 13 (i=13): Bits [111 : 104]
    // -----------------------------------------------------------
    Sbox Sbyte_13 (
        .clk(clk), 
        .reset(reset),
        .valid_in(valid_in), 
        .data_in(data_in[111:104]), 
        .data_out(data_out[111:104])
    );

    // -----------------------------------------------------------
    // Byte 14 (i=14): Bits [119 : 112]
    // -----------------------------------------------------------
    Sbox Sbyte_14 (
        .clk(clk), 
        .reset(reset),
        .valid_in(valid_in), 
        .data_in(data_in[119:112]), 
        .data_out(data_out[119:112])
    );

    // -----------------------------------------------------------
    // Byte 15 (i=15): Bits [127 : 120]
    // -----------------------------------------------------------
    Sbox Sbyte_15 (
        .clk(clk), 
        .reset(reset),
        .valid_in(valid_in), 
        .data_in(data_in[127:120]), 
        .data_out(data_out[127:120])
    );

    always @(posedge clk or negedge reset) begin
        if(!reset)begin
            valid_out <= 1'b0;
        end else begin
            valid_out <= valid_in;
        end
    end

endmodule
