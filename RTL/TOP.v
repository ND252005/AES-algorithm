`timescale 1ns/1ps
module TOP #(
    parameter KEY_LEN = 128,
    parameter DATA_LEN = 128,
    parameter NUMS_OF_ROUND = 10
) (
    input clk,
    input reset,
    input data_valid_in,
    input [DATA_LEN-1 : 0] plain_text,
    input key_valid_in,
    input [KEY_LEN-1 : 0] cipher_key,
    output reg data_valid_out,
    output reg [DATA_LEN-1 : 0] cipher_text
);
    wire [NUMS_OF_ROUND : 0] subkey_valid_out;
    wire [(NUMS_OF_ROUND*KEY_LEN-1) : 0] key_array;
    wire [NUMS_OF_ROUND-1 : 0] round_valid_in;
    wire [DATA_LEN-1 : 0] round_data_in [0 : NUMS_OF_ROUND-2];

// khai báo dây cho vòng cuối cùng
    wire [DATA_LEN-1 : 0] shift_data_in; // dữ liệu đầu ra của SubByte() là đầu vào của ShiftRows()
    wire [DATA_LEN-1 : 0] addrk_data_in; // dữ liệu đầu ra của MixColums() là đầu vào của AddRoundKey()
    wire [DATA_LEN-1 : 0] final_data;

    wire shift_valid_in; // tín hiệu đầu ra của SubByte() là đầu vào của ShiftRows()
    wire addrk_valid_in; // tín hiệu đầu ra của MixColums() là đầu vào của AddRoundKey()
    wire final_valid;

//delay cho vòng cuối để pipeline cho mixcolunms
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
        .valid_out(subkey_valid_out)
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
        .valid_out(round_valid_in[0]),
        .data_out(round_data_in[0])
    );

    genvar i;
generate
      for(i = 1; i <= NUMS_OF_ROUND-1; i = i+1) begin : ROUND
        Round #(
            .DATA_LEN(DATA_LEN)
        ) ROUND_inst (
            .clk(clk),
            .reset(reset),
            .data_valid_in(round_valid_in[i-1]),
            .data_in(round_data_in[i-1]),
            .key_valid_in(subkey_valid_out[i-1]),
            .sub_key(key_array[i-1]),
            .valid_out(round_valid_in[i]),
            .data_valid_out(key_array[i])
        );
    end 
endgenerate

// -----Last round: SubBytes ()-----

    SubBytes #(
        .DATA_LEN(DATA_LEN)
    ) SubBytes_last (
            .clk(clk), 
            .reset(reset),
            .valid_in(round_valid_in[NUMS_OF_ROUND-1]),
            .data_in(round_data_in[NUMS_OF_ROUND-1]),
            .valid_out(shift_valid_in),
            .data_out(shift_data_in)
    );

//-----Last round: ShiftRows()-----
    ShiftRows #(
        .DATA_LEN(DATA_LEN)
    ) ShiftRows_last (
        .clk(clk),
        .reset(reset),
        .valid_in(shift_valid_in),
        .data_in(shift_data_in),
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
        .key_valid_in(key_valid_in),
        .round_key(sub_key),
        .valid_out(valid_out),
        .data_out(cipher_text)
    );

    always @(posedge clk or negedge reset)

    if(!reset)begin
        valid_shift2key_delayed <= 1'b0;
        data_shift2key_delayed <= 'b0;
    end else begin

    if(valid_shift2key)begin
    data_shift2key_delayed <= data_shift2key;
    end
    valid_shift2key_delayed <= valid_shift2key;
    end

    // --- Output Assignment ---
    // always @(posedge clk or posedge reset) begin
    //     if (reset) begin
    //         data_valid_out <= 0;
    //         cipher_text    <= 0;
    //     end else begin
    //         data_valid_out <= final_valid;
    //         cipher_text    <= final_data;
    //     end
    // end

endmodule