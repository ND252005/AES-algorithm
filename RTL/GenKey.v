//module name : GenKey
`timescale 1 ns / 1 ps

module GenKey #(
    parameter KEY_LEN = 128,  // ĐỘ DÀI KHÓA
    parameter WORD_LEN = 32   // 1 WORD = 4 BYTES = 32 BITS
) (
    input clk,
    input reset,
    input [WORD_LEN-1 : 0] Rcon,          // Rcon mỗi round
    input valid_in,
    input [KEY_LEN-1 : 0] key_in,
    output reg [KEY_LEN-1 : 0] round_key,
    output reg valid_out    
);

wire [WORD_LEN-1 : 0] Key_RotWord;
reg [KEY_LEN-1 : 0] Key_FirstStage;
reg [KEY_LEN-1 : 0] Key_SecondStage;
reg [KEY_LEN-1 : 0] round_key_delayed;
reg valid_FirstStage;
reg valid_round_key;
wire [WORD_LEN-1 : 0] Key_SubBytes;
wire subbytes_valid_out;
wire [KEY_LEN-1 : 0] temp_round_key;

// Quá trình tạo khóa sẽ trải qua 4 bước giống như quá trình mã hóa (SubBytes-ShiftRows-MixColumns-AddRoundKey)
// để đồng bộ khóa và dữ liệu cùng đến bước AddRoundKey (pipeline)

//****Đợi tín hiệu enable (ở đây là valid_in) để lấy dữ liệu vào lần đầu tiên****//

always @(posedge clk or negedge reset)
if (!reset) begin
    valid_FirstStage <= 1'b0;
    Key_FirstStage <= 'b0;
end else begin
 if (valid_in) begin
    Key_FirstStage = key_in;
 end
 valid_FirstStage <= valid_in;
end

//****Đợi tín hiệu enable từ bước đầu tiên để lấy dữ liệu vào bước thứ hai****//

always @(posedge clk or negedge reset)
if (!reset) begin
    Key_SecondStage <= 'b0;
end else begin
    if (valid_FirstStage) begin
        Key_SecondStage <= Key_FirstStage;
    end
end

//****Rotate Word****//
assign Key_RotWord = {Key_FirstStage[WORD_LEN-9:0], Key_FirstStage[WORD_LEN-1:WORD_LEN-8]}; // Xoay trái 3 byte cho byte trọng số lớn nhất về cuối

//****SubBytes (song song với thanh ghi bước hai)****//
SubBytes #(WORD_LEN) SUB_W (clk, reset, valid_FirstStage, Key_RotWord, subbytes_valid_out, Key_SubBytes);

//****Tính toán khóa cho vòng hiện tại****//
assign temp_round_key[4*WORD_LEN-1 : 3*WORD_LEN] = Key_SecondStage[4*WORD_LEN-1 : 3*WORD_LEN] ^ Key_SubBytes ^ Rcon; // Tính word đầu tiên của khóa vòng hiện tại
// Các word còn lại tính theo phép XOR với word liền trước
assign temp_round_key[3*WORD_LEN-1 : 2*WORD_LEN] = Key_SecondStage[3*WORD_LEN-1 : 2*WORD_LEN] ^ temp_round_key[4*WORD_LEN-1 : 3*WORD_LEN]; // Word thứ hai 
assign temp_round_key[2*WORD_LEN-1 : WORD_LEN] = Key_SecondStage[2*WORD_LEN-1 : WORD_LEN] ^ temp_round_key[3*WORD_LEN-1 : 2*WORD_LEN]; // Word thứ ba
assign temp_round_key[WORD_LEN-1 : 0] = Key_SecondStage[WORD_LEN-1 : 0] ^ temp_round_key[2*WORD_LEN-1 : WORD_LEN]; // Word thứ tư

//****Đợi tín hiệu từ SubBytes để lưu khóa vòng hiện tại vào thanh ghi (bước ba)****//
always @(posedge clk or negedge reset)
if (!reset) begin
    round_key_delayed <= 'b0;
    valid_round_key <= 1'b0;
end else begin
    if (subbytes_valid_out) begin
        round_key_delayed <= temp_round_key;
    end
    valid_round_key <= subbytes_valid_out;
end

//****Đưa khóa vòng hiện tại ra ngoài cùng với tín hiệu valid****//
always @(posedge clk or negedge reset)
if (!reset) begin
    round_key <= 'b0;
    valid_out <= 1'b0;
end else begin
    if (valid_round_key) begin
        round_key <= round_key_delayed;
    end
    valid_out <= valid_round_key;
end

endmodule