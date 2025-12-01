//File main

`timescale 1 ns / 1 ps
module Top_Pipelined #(
    parameter DATA_W = 128,
    parameter KEY_LEN = 128,
    parameter NO_ROUNDS = 10
) (
    input clk,
    input reset,
    input data_valid_in,
    input key_valid_in,
    input [KEY_LEN-1:0] cipher_key,  // khóa chính
    input [DATA_W-1:0] plain_text,  // dữ liệu đầu vào 
    output valid_out,
    output [DATA_W-1:0] cipher_text // dữ liệu sau khi mã hóa
);

wire [NO_ROUNDS-1:0] valid_round_key;           //tín hiệu valid của tất cả khóa vòng từ KeyExpantion
wire [NO_ROUNDS-1:0] valid_round_data;          //tín hiệu valid của tất cả dữ liệu đầu ra từ các vòng
wire [DATA_W-1:0] data_round [0:NO_ROUNDS-1];   //dữ liệu của tất cả các vòng
wire valid_sub_to_shift;
wire valid_shift_to_key;
wire [DATA_W-1:0] data_sub_to_shift;
wire [DATA_W-1:0] data_shift_to_key;
wire [(NO_ROUNDS*DATA_W)-1:0] W;                //tất cả khóa vòng

reg [DATA_W-1:0] data_shift_to_key_delayed;
reg valid_shift_to_key_delayed;
// Tạo khóa cho các vòng
KeyExpantionbyDuong #(DATA_W,KEY_LEN,NO_ROUNDS) U_KEYEXP (
    .clk(clk),
    .reset(reset),
    .valid_in(key_valid_in),
    .cipher_key(cipher_key),
    .SuperKey(W),
    .valid_out(valid_round_key)
);

// Vòng đầu tiên: AddRoundKey với plain_text
AddRoundKey #(DATA_W) U0_ARK (
    .clk(clk),
    .reset(reset),
    .data_valid_in(data_valid_in),
    .key_valid_in(key_valid_in),
    .data_in(plain_text),
    .round_key(cipher_key),
    .valid_out(valid_round_data[0]),
    .data_out(data_round[0])
);

// Tạo các khối cho các vòng tiếp theo
genvar i;
generate
    for (i = 0; i < NO_ROUNDS-1; i = i + 1) begin : ROUND
        Round #(DATA_W) U_ROUND (
            .clk(clk),
            .reset(reset),
            .data_valid_in(valid_round_data[i]),
            .key_valid_in(valid_round_key[i]),
            .data_in(data_round[i]),
            .round_key(W[(NO_ROUNDS-i)*DATA_W-1:(NO_ROUNDS-i-1)*DATA_W]),
            .valid_out(valid_round_data[i+1]),
            .data_out(data_round[i+1])
        );
    end
endgenerate
// Vòng cuối cùng: không có MixColumns
SubBytes #(DATA_W) U_SUB (
    .clk(clk),
    .reset(reset),
    .valid_in(valid_round_data[NO_ROUNDS-1]),
    .data_in(data_round[NO_ROUNDS-1]),
    .valid_out(valid_sub_to_shift),
    .data_out(data_sub_to_shift)
);
ShiftRows #(DATA_W) U_SH (
    .clk(clk),
    .reset(reset),
    .valid_in(valid_sub_to_shift),
    .data_in(data_sub_to_shift),
    .valid_out(valid_shift_to_key),
    .data_out(data_shift_to_key)
);
AddRoundKey #(DATA_W) U_KEY (
    .clk(clk),
    .reset(reset),
    .data_valid_in(valid_shift_to_key),
    .key_valid_in(valid_round_key[NO_ROUNDS-1]),
    .data_in(data_shift_to_key),
    .round_key(W[DATA_W-1:0]),
    .valid_out(valid_out),
    .data_out(cipher_text)
);

always @(posedge clk or negedge reset)
if (!reset) begin
    valid_shift_to_key_delayed <= 1'b0;
    data_shift_to_key_delayed <= 'b0;
end else begin
    if(valid_shift_to_key) begin
        data_shift_to_key_delayed <= data_shift_to_key;
    end
    valid_shift_to_key_delayed <= valid_shift_to_key;
end

endmodule