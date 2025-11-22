`timescale 1ns/1ps
module TOP #(
    parameter KEY_LEN = 128,
    parameter DATA_LEN = 128,
    parameter NUMS_OF_ROUND = 10
) (
    input clk, //Clock và reset của hệ thống
    input reset,
    input data_valid_in, // biến kiểm tra dữ liệu đầu vào có hay chưa
    input [DATA_LEN-1 : 0] plain_text, // dữ liệu cần mã hóa
    input key_valid_in, //biến kiểm ra khóa đầu vào có hay chưa
    input [KEY_LEN-1 : 0] cipher_key, // khóa đầu vào
    output wire data_valid_out, // biến kiểm tra dữ liệu đầu ra có hay chưa
    output wire [DATA_LEN-1 : 0] cipher_text // dữ liệu sau khi mã hóa
);
    wire [NUMS_OF_ROUND-1 : 0] subkey_valid; // biến kiểm tra khóa con của từng vòng có hay chưa
    wire [(NUMS_OF_ROUND*KEY_LEN-1) : 0] key_array; //  mảng khóa con của tất cả các vòng
    wire [NUMS_OF_ROUND-1 : 0] round_valid; // biến kiểm tra dữ liệu đầu ra của từng vòng có hay chưa
    wire [DATA_LEN-1 : 0] round_data [0 : NUMS_OF_ROUND-1]; // dữ liệu đầu ra của từng vòng

// khai báo dây cho vòng cuối cùng
    wire [DATA_LEN-1 : 0] data_sub2shift; // dữ liệu đầu ra của SubByte() là đầu vào của ShiftRows()

    wire valid_sub2shift; // tín hiệu đầu ra của SubByte() là đầu vào của ShiftRows()
    wire addrk_valid_in; // tín hiệu đầu ra của MixColums() là đầu vào của AddRoundKey()

//delay cho vòng cuối để pipeline cho mixcolunms
    wire[DATA_LEN-1:0] data_shift2key;           //for delay register
    wire valid_shift2key;
    reg[DATA_LEN-1:0] data_shift2key_delayed;           //for delay register
    reg valid_shift2key_delayed;

    KeyExpantion #(
        .KEY_LEN(KEY_LEN),
        .NUMS_OF_ROUND(NUMS_OF_ROUND)
    ) KeyExpantion_inst (
        .clk(clk),
        .reset(reset),
        .valid_in(key_valid_in),
        .Secret_key(cipher_key),
        .key_expan(key_array),
        .valid_out(subkey_valid)
    );

    AddRoundKey #(
        .DATA_LEN(DATA_LEN)
    ) AddRoundKey_inst (
        .clk(clk),  
        .reset(reset),
        .data_valid_in(data_valid_in),
        .data_in(plain_text),
        .key_valid_in(key_valid_in),
        .round_key(cipher_key),
        .valid_out(round_valid[0]),
        .data_out(round_data[0])
    );

    genvar i;
generate
      for(i = 1; i <= NUMS_OF_ROUND-1; i = i+1) begin : ROUND
        Round #(
            .DATA_LEN(DATA_LEN)
        ) ROUND_inst (
            .clk(clk),
            .reset(reset),
            .data_valid_in(round_valid[i-1]),
            .data_in(round_data[i-1]),
            .key_valid_in(subkey_valid[i-1]),
            .sub_key(key_array[(i*KEY_LEN-1) : ((i-1)*KEY_LEN)]),
            .valid_out(round_valid[i]),
            .data_out(round_data[i])
        );
    end 
endgenerate

// -----Last round: SubBytes ()-----
    SubBytes #(
        .DATA_LEN(DATA_LEN)
    ) SubBytes_last (
            .clk(clk), 
            .reset(reset),
            .valid_in(round_valid[NUMS_OF_ROUND-1]),
            .data_in(round_data[NUMS_OF_ROUND-1]),
            .valid_out(valid_sub2shift),
            .data_out(data_sub2shift)
    );

//-----Last round: ShiftRows()-----
    ShiftRows #(
        .DATA_LEN(DATA_LEN)
    ) ShiftRows_last (
        .clk(clk),
        .reset(reset),
        .valid_in(valid_sub2shift),
        .data_in(data_sub2shift),
        .valid_out(valid_shift2key),
        .data_out(data_shift2key)
    );

//-----Last round: AddRoundKey()-----
    AddRoundKey #(
        .DATA_LEN(DATA_LEN)
    ) AddRoundKey_last (
        .clk(clk),
        .reset(reset),
        .data_valid_in(valid_shift2key_delayed),
        .data_in(data_shift2key_delayed),
        .key_valid_in(subkey_valid[NUMS_OF_ROUND-1]),
        .round_key(key_array[(NUMS_OF_ROUND*KEY_LEN-1) : ((NUMS_OF_ROUND-1)*KEY_LEN)]),
        .valid_out(data_valid_out),
        .data_out(cipher_text)
    );

    always @(posedge clk or negedge reset)

    if(!reset)begin
        valid_shift2key_delayed <= 1'b0;
        data_shift2key_delayed <= 'b0;
    end else begin
        if(valid_shift2key)begin
            data_shift2key_delayed <= data_shift2key;
        end else begin
            data_shift2key_delayed = 'b0;
        end
        valid_shift2key_delayed <= valid_shift2key;
    end

endmodule