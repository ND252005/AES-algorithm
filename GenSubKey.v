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
`timescale 1ps/1ps
module GenSubKey #(
parameter KEY_LEN = 128, // độ dài khóa
parameter WORD_LEN = 32 // độ dài 1 word 
) (
    input wire clk,
    input wire reset,
    input wire [3:0] round_n,
    input wire [KEY_LEN-1:0] data_in,
    input wire valid_in,
    output reg [KEY_LEN-1:0] data_out,
    output reg valid_out

);

    reg [KEY_LEN-1:0] key_start;
    reg [KEY_LEN-1:0] key_start_1;
    wire [WORD_LEN-1:0] rotword;
    wire [WORD_LEN-1:0] subword;
    wire [WORD_LEN-1 : 0] Rcon;
    reg [7 : 0] Rcon_firstbytes;
    wire subword_valid_out;
    wire [KEY_LEN-1:0] tempt_key;
    reg [KEY_LEN-1:0] data_out_1;
    reg delayed_valid;

//Rcon table
always @(*) begin
    case (round_n)
    4'd0: Rcon_firstbytes = 8'h01;
    4'd1: Rcon_firstbytes = 8'h02;
    4'd2: Rcon_firstbytes = 8'h04;
    4'd3: Rcon_firstbytes = 8'h08;
    4'd4: Rcon_firstbytes = 8'h10;
    4'd5: Rcon_firstbytes = 8'h20;
    4'd6: Rcon_firstbytes = 8'h40;
    4'd7: Rcon_firstbytes = 8'h80;
    4'd8: Rcon_firstbytes = 8'h1B;
    4'd9: Rcon_firstbytes = 8'h36;
        default: Rcon_firstbytes = 8'h00;
    endcase
end

assign Rcon = {Rcon_firstbytes, 24'h000000};
//----------------------
//---Pipeline để đồng bộ dữ liệu---
//---subbytes tốn 1 chu kỳ, nên delay 1 chu kỳ để lấy dữ liệu đồng bộ---
always @(posedge clk or negedge reset) begin
    if (!reset)
        key_start_1 <= 'b0;
    else if (valid_in)
        key_start_1 <= data_in;
end
always @(posedge clk or negedge reset) begin
    if (!reset)
        key_start <= 'b0;
    else if (valid_in)
        key_start <= key_start_1; // delay 1 chu kỳ
end

//xử lý word đầu tiên của khóa 128 bit 
//---Rotword---
assign rotword = {key_start_1[WORD_LEN-9:0], key_start_1[WORD_LEN-1 : WORD_LEN-8]};
//---Subword---
//truyền độ dài word vì chỉ sub 1 word
SubBytes #(
    .DATA_LEN(WORD_LEN)
    ) sb_gen (
    .clk(clk),
    .reset(reset),
    .valid_in(valid_in),
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
           delayed_valid <= 1'b1;
        end else begin
            delayed_valid <= 1'b0;
        end
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
