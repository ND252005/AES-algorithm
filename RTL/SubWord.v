`timescale 1ns/1ps

module SubWord #(
    parameter DATA_LEN = 32,
    parameter NUM_OF_BYTES = 4
) (
    input clk,
    input reset,
    input valid_in,                 // biến kiểm tra tín hiệu đầu vào hợp lệ không 
  	input [DATA_LEN-1:0] data_in,   //dữ liệu đầu vào
    output reg valid_out,           // biến kiểm tra tín hiệu đầu ra
    output [DATA_LEN-1:0] data_out  //dữ liệu đầu ra
);

// tạo ra các instance Sbyte, sub các byte dữ liệu cùng lúc
// -----------------------------------------------------------
    // Byte 0 (i=0): Bits [7 : 0]
    // -----------------------------------------------------------
    Sbox Sword_0 (
        .clk(clk), 
        .reset(reset),
        .valid_in(valid_in), 
        .data_in(data_in[7:0]), 
        .data_out(data_out[7:0])
    );

    // -----------------------------------------------------------
    // Byte 1 (i=1): Bits [15 : 8]
    // -----------------------------------------------------------
    Sbox Sword_1 (
        .clk(clk), 
        .reset(reset),
        .valid_in(valid_in), 
        .data_in(data_in[15:8]), 
        .data_out(data_out[15:8])
    );

    // -----------------------------------------------------------
    // Byte 2 (i=2): Bits [23 : 16]
    // -----------------------------------------------------------
    Sbox Sword_2 (
        .clk(clk), 
        .reset(reset),
        .valid_in(valid_in), 
        .data_in(data_in[23:16]), 
        .data_out(data_out[23:16])
    );

    // -----------------------------------------------------------
    // Byte 3 (i=3): Bits [31 : 24]
    // -----------------------------------------------------------
    Sbox Sword_3 (
        .clk(clk), 
        .reset(reset),
        .valid_in(valid_in), 
        .data_in(data_in[31:24]), 
        .data_out(data_out[31:24])
    );

    always @(posedge clk or negedge reset) begin
        if(!reset)begin
            valid_out <= 1'b0;
        end else begin
            valid_out <= valid_in;
        end
    end

endmodule
