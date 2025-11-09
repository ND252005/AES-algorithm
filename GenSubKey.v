/*
parameter:
- KEY_LEN (128, 192, 256)
- WORD_LEN (32)
đầu vào: 
- Vòng thứ ... (0-10 or 12 or 14)
- khóa vòng trước data_in
- signal_in
- clk, reset của hệ thống
output:
- khoá trả về
- signal_out

*/
`timescale 1ns/1ps
module GenSubKey #(
parameter KEY_LEN = 128, // độ dài khóa
parameter WORD_LEN = 32 // độ dài 1 word 
) (
    input wire clk,
    input wire reset,
    input wire [WORD_LEN-1:0] Rcon,
    input wire [KEY_LEN-1:0] data_in,
    input wire valid_in,
    output reg [KEY_LEN-1:0] data_out,
    output reg valid_out

);

    reg valid_first;
    reg [KEY_LEN-1:0] key_start;
    reg [KEY_LEN-1:0] key_start_1;
    wire [WORD_LEN-1:0] rotword;
    wire [WORD_LEN-1:0] subword;
    wire subword_valid_out;
    wire [KEY_LEN-1:0] tempt_key;
    reg [KEY_LEN-1:0] data_out_1;
    reg delayed_valid;

//----------------------
//---Pipeline để đồng bộ dữ liệu---
//---subbytes tốn 1 chu kỳ, nên delay 1 chu kỳ để lấy dữ liệu đồng bộ---
//---tại vòng đầu, gán giá trị để tính rotword và subbyte trước---
//---vì subbyte phải tốn 1 chu kỳ. khi subbyte vừa có kết quả thì tính tempt là được---
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        key_start_1 <= 'b0;
        valid_first <= 1'b0;    
    end else if (valid_in) begin
        key_start_1 <= data_in;
    end
        valid_first <= valid_in;
end
//---vòng delay chu kỳ, kiểm tra biến check ở chu kì trước đã set chưa---
//---nếu rồi thì mới gán giá trị để tính cho tempt---
always @(posedge clk or negedge reset) begin
    if (!reset)
        key_start <= 'b0;
    else if (valid_first)
        key_start <= key_start_1; // delay 1 chu kỳ
end

//xử lý word đầu tiên của khóa 128 bit 
//---Rotword---
assign rotword = {key_start_1[WORD_LEN-9:0], key_start_1[WORD_LEN-1 : WORD_LEN-8]};
//---Subword---
//truyền độ dài word vì chỉ sub 1 word
//---tín hiệu đầu vào cho subbyte phải là tín hiệu khi tại key_start_1 có dữ liệu
//---key_start_1 có dữ liệu chỉ khi đã qua một xung clk 
//---khác với tín hiệu valid_in của khối, mặc dù nó giống nhau 
//---nhưng tín hiệu valid_in của khối được set ngay khi có có tín hiệu
//---làm cho subbyte nhầm lẫn khi đó đã có giá trị để tính toán
SubBytes #(
    .DATA_LEN(WORD_LEN)
    ) sb_gen (
    .clk(clk),
    .reset(reset),
    .valid_in(valid_first),
    .data_in(rotword),
    .valid_out(subword_valid_out),
    .data_out(subword)
    );

//---Rcon---
assign tempt_key[KEY_LEN-1 : KEY_LEN-WORD_LEN] = key_start[KEY_LEN-1 : KEY_LEN-WORD_LEN] ^ subword ^ Rcon;
assign tempt_key[KEY_LEN-WORD_LEN-1 : KEY_LEN-2*WORD_LEN] = key_start[KEY_LEN-WORD_LEN-1 : KEY_LEN-2*WORD_LEN] ^ tempt_key[KEY_LEN-1 : KEY_LEN-WORD_LEN];
assign tempt_key[KEY_LEN-2*WORD_LEN-1 : KEY_LEN-3*WORD_LEN] = key_start [KEY_LEN-2*WORD_LEN-1 : KEY_LEN-3*WORD_LEN] ^ tempt_key[KEY_LEN-WORD_LEN-1 : KEY_LEN-2*WORD_LEN];
assign tempt_key[WORD_LEN-1 : 0] = key_start[WORD_LEN-1 : 0] ^ tempt_key[KEY_LEN-2*WORD_LEN-1 : KEY_LEN-3*WORD_LEN] ;

//---wait for posedge clk to show data out---
always @(posedge clk or negedge reset) begin
    if(!reset) begin
        delayed_valid <= 1'b0;
        data_out_1 <= 'b0;
    end else begin
        if(subword_valid_out) begin
           data_out_1 <= tempt_key;
        end
        delayed_valid <= subword_valid_out;
    end
end
always @(posedge clk or negedge reset) begin
    if(!reset) begin
        valid_out <= 1'b0;
        data_out <= 'b0;
    end else begin
        if(delayed_valid) begin
           data_out <= data_out_1;
        end
        valid_out <= delayed_valid;
    end
end
endmodule
