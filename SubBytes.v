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
genvar i;
generate
    for (i = 0; i < NUM_OF_BYTES; i = i + 1) begin : Sbyte
        Sbox Sbyte(
            .clk(clk), 
            .reset(reset),
            .valid_in(valid_in), 
            .data_in(data_in[i*8+7 : i*8]), 
            .data_out(data_out[i*8+7 : i*8])
        );
    end   
endgenerate
    
    always @(posedge clk or negedge reset) begin
        if(!reset)begin
            valid_out <= 1'b0;
        end else begin
            valid_out <= valid_in;
        end
    end

endmodule
