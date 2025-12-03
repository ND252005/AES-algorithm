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
parameter KEY_LEN = 256, // độ dài khóa
parameter WORD_LEN = 32 // độ dài 1 word 
) (
    input wire clk,
    input wire reset,
    // input wire opcode, //opcode = 1: chỉ cần subword, opcode = 0: cần rotword + subword;
    input wire [WORD_LEN-1:0] Rcon,
    input wire [KEY_LEN-1:0] data_in,
    input wire valid_in,
    output reg [KEY_LEN-1:0] data_out,
    output reg valid_out

);
    reg [KEY_LEN-1 : 0] key_start;
    reg valid_first; // valid cho stage 1
    reg [KEY_LEN/2-1:0] high_key; // giá trị lưu sau khi delay
    reg [KEY_LEN/2-1:0] key_start_1; //
    wire [WORD_LEN-1:0] rotword;
    wire [WORD_LEN-1:0] high_subword;
    wire high_subword_valid_out;
    wire [KEY_LEN/2-1:0] high_tempt_key;
    reg [KEY_LEN/2-1:0] high_data_out;
    reg high_valid_out;
    reg [KEY_LEN/2-1:0] high_data_out_delay;
    reg high_delayed_valid;
    reg [31 : 0] last_col;


//----------------------
//---Pipeline để đồng bộ dữ liệu---
//---subbytes tốn 1 chu kỳ, nên delay 1 chu kỳ để lấy dữ liệu đồng bộ---
//---tại vòng đầu, gán giá trị để tính rotword và subbyte trước---
//---vì subbyte phải tốn 1 chu kỳ. khi subbyte vừa có kết quả thì tính tempt là được---
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        key_start_1 <= 'b0;
        key_start <= 'b0;
        valid_first <= 1'b0;
        last_col <= 'b0;
    end else if (valid_in) begin
        key_start_1 <= data_in[KEY_LEN-1 : KEY_LEN/2];
        key_start <= data_in[KEY_LEN-1 : 0];
        last_col <= data_in[31 : 0];

    end
        valid_first <= valid_in;
end
//---vòng delay chu kỳ, kiểm tra biến check ở chu kì trước đã set chưa---
//---nếu rồi thì mới gán giá trị để tính cho tempt---
always @(posedge clk or negedge reset) begin
    if (!reset)
        high_key <= 'b0;
    else if (valid_first)
        high_key <= key_start_1; // delay 1 chu kỳ
end

//xử lý word đầu tiên của khóa 128 bit 
//---Rotword--- sẽ check bit opcode để quyết định đầu vào cho khối Subwword vì một số trường hợp không cần subword
assign rotword =  {last_col[7 : 0], last_col[31 : 8]};

//---Subword---
//truyền độ dài word vì chỉ sub 1 word
//---tín hiệu đầu vào cho subbyte phải là tín hiệu khi tại key_start_1 có dữ liệu
//---key_start_1 có dữ liệu chỉ khi đã qua một xung clk 
//---khác với tín hiệu valid_in của khối, mặc dù nó giống nhau 
//---nhưng tín hiệu valid_in của khối được set ngay khi có có tín hiệu
//---làm cho subbyte nhầm lẫn khi đó đã có giá trị để tính toán
SubWord sw_gen (
    .clk(clk),
    .reset(reset),
    .valid_in(valid_first),
    .data_in(rotword),
    .valid_out(high_subword_valid_out),
    .data_out(high_subword)
    );

//---Rcon---
assign high_tempt_key[KEY_LEN/2-1 : KEY_LEN/2-WORD_LEN] = (high_key[KEY_LEN/2-1 : KEY_LEN/2-WORD_LEN] ^ high_subword ^ Rcon);
assign high_tempt_key[KEY_LEN/2-WORD_LEN-1 : KEY_LEN/2-2*WORD_LEN] = high_key[KEY_LEN/2-WORD_LEN-1 : KEY_LEN/2-2*WORD_LEN] ^ high_tempt_key[KEY_LEN/2-1 : KEY_LEN/2-WORD_LEN];
assign high_tempt_key[KEY_LEN/2-2*WORD_LEN-1 : KEY_LEN/2-3*WORD_LEN] = high_key [KEY_LEN/2-2*WORD_LEN-1 : KEY_LEN/2-3*WORD_LEN] ^ high_tempt_key[KEY_LEN/2-WORD_LEN-1 : KEY_LEN/2-2*WORD_LEN];
assign high_tempt_key[WORD_LEN-1 : 0] = high_key[WORD_LEN-1 : 0] ^ high_tempt_key[KEY_LEN/2-2*WORD_LEN-1 : KEY_LEN/2-3*WORD_LEN] ;

//---wait for posedge clk to show data out---
always @(posedge clk or negedge reset) begin
    if(!reset) begin
        high_delayed_valid <= 1'b0;
        high_data_out_delay <= 'b0;
    end else begin
        if(high_subword_valid_out) begin
           high_data_out_delay <= high_tempt_key;
        end 
        high_delayed_valid <= high_subword_valid_out;
    end
end

always @(posedge clk or negedge reset) begin
    if(!reset) begin
        high_data_out <= 1'b0;
        high_valid_out <= 'b0;
    end else begin
        if(high_delayed_valid) begin
           high_data_out <= high_data_out_delay;
        end
        high_valid_out <= high_delayed_valid;
    end
end

    reg valid_second;
    reg [KEY_LEN/2-1:0] low_key;
    reg [KEY_LEN/2-1:0] key_start_2;
    wire [WORD_LEN-1:0] low_subword;
    wire low_subword_valid_out;
    wire [KEY_LEN/2-1:0] low_tempt_key;
    reg [KEY_LEN/2-1:0] low_data_out_delay;
    reg low_delayed_valid;


always @(posedge clk or negedge reset) begin
    if (!reset) begin
        key_start_2 <= 'b0;
        valid_second <= 1'b0;    
    end else if (high_valid_out) begin
        key_start_2 <= key_start [127:0];
    end
        valid_second <= high_valid_out;
end
//---vòng delay chu kỳ, kiểm tra biến check ở chu kì trước đã set chưa---
//---nếu rồi thì mới gán giá trị để tính cho tempt---
always @(posedge clk or negedge reset) begin
    if (!reset)
        low_key <= 'b0;
    else if (valid_second)
        low_key <= key_start_2; // delay 1 chu kỳ
end
SubWord sw_gen_middle (
    .clk(clk),
    .reset(reset),
    .valid_in(valid_second),
    .data_in(high_data_out[31:0]),
    .valid_out(low_subword_valid_out),
    .data_out(low_subword)
    );

assign low_tempt_key[KEY_LEN/2-1 : KEY_LEN/2-WORD_LEN] = (low_subword ^ low_key[KEY_LEN/2-1 : KEY_LEN/2-WORD_LEN]);
assign low_tempt_key[KEY_LEN/2-WORD_LEN-1 : KEY_LEN/2-2*WORD_LEN] = low_key[KEY_LEN/2-WORD_LEN-1 : KEY_LEN/2-2*WORD_LEN] ^ low_tempt_key[KEY_LEN/2-1 : KEY_LEN/2-WORD_LEN];
assign low_tempt_key[KEY_LEN/2-2*WORD_LEN-1 : KEY_LEN/2-3*WORD_LEN] = low_key [KEY_LEN/2-2*WORD_LEN-1 : KEY_LEN/2-3*WORD_LEN] ^ low_tempt_key[KEY_LEN/2-WORD_LEN-1 : KEY_LEN/2-2*WORD_LEN];
assign low_tempt_key[WORD_LEN-1 : 0] = low_key[WORD_LEN-1 : 0] ^ low_tempt_key[KEY_LEN/2-2*WORD_LEN-1 : KEY_LEN/2-3*WORD_LEN];

//---wait for posedge clk to show data out---
always @(posedge clk or negedge reset) begin
    if(!reset) begin
        low_delayed_valid <= 1'b0;
        low_data_out_delay <= 'b0;
    end else begin
        if(low_subword_valid_out) begin
           low_data_out_delay <= low_tempt_key;
        end 
        low_delayed_valid <= low_subword_valid_out;
    end
end
always @(posedge clk or negedge reset) begin
    if(!reset) begin
        valid_out <= 1'b0;
        data_out <= 'b0;
    end else begin
        if(low_delayed_valid) begin
           data_out <= {high_data_out , low_data_out_delay};
        end
        valid_out <= low_delayed_valid;
    end
end

endmodule
