`timescale 1ns/1ps

module Round #(
    parameter DATA_LEN = 128
) (
    wire clk, // Xung clock của hệ thống
    wire reset, // Tín hiệu reset bất đồng bộ của hệ thống
    wire data_valid_in, // tín hiệu dữ liệu đầu vào 
    wire [DATA_LEN-1 : 0] data_in, // dữ liệu đầu vào 
    wire key_valid_in, // tín hiệu khóa con đầu vào mỗi vòng
    wire [DATA_LEN-1 : 0] sub_key, // khóa con đầu vào mỗi vòng
    reg valid_out, // tín hiệu đầu ra mỗi vòng
    reg [DATA_LEN-1 : 0] data_out // dữ liệu đầu ra mỗi vòng

);
    wire [DATA_LEN-1 : 0] shift_data_in; // dữ liệu đầu ra của SubByte() là đầu vào của ShiftRows()
    wire [DATA_LEN-1 : 0] mix_data_in; // dữ liệu đầu ra của ShiftRows() là đầu vào của MixColums()
    wire [DATA_LEN-1 : 0] addrk_data_in; // dữ liệu đầu ra của MixColums() là đầu vào của AddRoundKey()

    wire shift_valid_in; // tín hiệu đầu ra của SubByte() là đầu vào của ShiftRows()
    wire mix_valid_in; // tín hiệu đầu ra của ShiftRows() là đầu vào của MixColums()
    wire addrk_valid_in; // tín hiệu đầu ra của MixColums() là đầu vào của AddRoundKey()

//-----First stage: SubBytes()-----
    SubBytes #(.DATA_LEN(DATA_LEN)) Sb (
            .clk(clk), 
            .reset(reset), 
            .valid_in(data_valid_in), 
            .data_in(data_in),
            .valid_out(shift_valid_in),
            .data_out(shift_data_in)
    );

//-----Second stage: ShiftRows()-----
    ShiftRows #(
        .DATA_LEN(DATA_LEN)
    ) ShR_R (
        .clk(clk),
        .reset(reset),
        .valid_in(shift_valid_in),
        .data_in(shift_data_in),
        .valid_out(mix_valid_in),
        .data_out(mix_data_in)
    );

//-----Third stage: MixColumns()-----
    MixColumns #(
        .DATA_LEN(DATA_LEN)
    ) MxC_R (
        .clk(clk),
        .reset(reset),
        .valid_in(mix_valid_in),
        .data_in(mix_data_in),
        .valid_out(addrk_valid_in),
        .data_out(addrk_data_in)
    );

//-----Fourth stage: AddRoundKey()-----
    AddRoundKey #(
        .DATA_LEN(DATA_LEN)
    ) Addrk_R (
        .clk(clk),
        .reset(reset),
        .data_valid_in(addrk_valid_in),
        .data_in(addrk_data_in),
        .key_valid_in(key_valid_in),
        .round_key(sub_key),
        .valid_out(valid_out),
        .data_out(data_out)
    );
    
endmodule