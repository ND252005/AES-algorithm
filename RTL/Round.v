`timescale 1ns/1ps

module Round #(
    parameter DATA_LEN = 128
) (
    input clk,                          // Xung clock của hệ thống
    input reset,                        // Tín hiệu reset bất đồng bộ
    input data_valid_in,                // Tín hiệu dữ liệu đầu vào 
    input [DATA_LEN-1 : 0] data_in,     // Dữ liệu đầu vào 
    input key_valid_in,                 // Tín hiệu khóa con đầu vào mỗi vòng
    input [DATA_LEN-1 : 0] sub_key,     // Khóa con đầu vào mỗi vòng
    output valid_out,                   // Tín hiệu đầu ra mỗi vòng
    output [DATA_LEN-1 : 0] data_out    // Dữ liệu đầu ra mỗi vòng
); 

    wire [DATA_LEN-1 : 0] shift_data_in; // Output của SubByte -> Input của ShiftRows
    wire [DATA_LEN-1 : 0] mix_data_in;   // Output của ShiftRows -> Input của MixColumns
    wire [DATA_LEN-1 : 0] addrk_data_in; // Output của MixColumns -> Input của AddRoundKey

    wire shift_valid_in; 
    wire mix_valid_in; 
    wire addrk_valid_in; 

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
    ShiftRows #(.DATA_LEN(DATA_LEN)) ShR_R (
        .clk(clk),
        .reset(reset),
        .valid_in(shift_valid_in),
        .data_in(shift_data_in),
        .valid_out(mix_valid_in),
        .data_out(mix_data_in)
    );

//-----Third stage: MixColumns()-----
    MixColumns #(.DATA_LEN(DATA_LEN)) MxC_R (
        .clk(clk),
        .reset(reset),
        .valid_in(mix_valid_in),
        .data_in(mix_data_in),
        .valid_out(addrk_valid_in),
        .data_out(addrk_data_in)
    );

//-----Fourth stage: AddRoundKey()-----
    AddRoundKey #(.DATA_LEN(DATA_LEN)) Addrk_R (
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