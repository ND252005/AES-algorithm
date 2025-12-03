// module name: AddRoundKey
`timescale 1 ns/1 ps

module AddRoundKey #(
    parameter DATA_LEN = 128
) (
    input clk,                          //clk, reset của hệ thống
    input reset,
    input data_valid_in,                //giá trị hợp lệ cho dữ liệu đầu vào
    input key_valid_in,                 //giá trị hợp lệ cho khóa đầu vào
    input [DATA_LEN-1:0] data_in,       //dữ liệu đầu vào
    input [DATA_LEN-1:0] round_key,     //khóa đầu vào
    output reg valid_out,
    output reg [DATA_LEN-1:0] data_out
);

always @(posedge clk or negedge reset) begin
    if (!reset) begin
        data_out <= 'b0;
        valid_out <= 1'b0;
    end else begin
        if (data_valid_in && key_valid_in) begin
            data_out <= data_in ^ round_key;
        end
        valid_out <= data_valid_in & key_valid_in;
    end
end
endmodule