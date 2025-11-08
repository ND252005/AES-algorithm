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
    output reg valid_out,
    output reg rw_out,
    output reg Rcon
);

reg [KEY_LEN-1:0] key_start;
wire [WORD_LEN-1:0] rotword;
wire [WORD_LEN-1:0] subword;
wire [WORD_LEN-1 : 0] Rcon;
reg [7 : 0] Rcon_firstbytes;
wire subword_valid_out;
wire [KEY_LEN-1:0] tempt_key;

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

always @(posedge clk or negedge reset) begin
    if(!reset) begin
        valid_out <= 1'b0;
        data_out <= 'b0;
    end else begin
        if (valid_in) 
            key_start <= data_in; //bắt đầu tạo khóa con
    end
end
//xử lý word đầu tiên của khóa 128 bit 
//---Rotword---
assign rotword = {key_start[7:0], key_start[WORD_LEN-1 : 8]};
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
        valid_out <= 1'b0;
        data_out <= 'b0;
    end else begin
        if(subword_valid_out) begin
           data_out <= tempt_key;
        end
        valid_out <= valid_in;
    end
end
endmodule
