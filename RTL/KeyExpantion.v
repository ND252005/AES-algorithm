
`timescale 1ns/1ps

module KeyExpantion #(
    parameter KEY_LEN = 128,                                //Độ dài khóa
    parameter NUMS_OF_ROUND = 10,                           //Số vòng lăp
    parameter WORD_LEN = 32                                 //độ dài 1 word
) (
    input clk,
    input reset,
    input [KEY_LEN-1 : 0] Secret_key,
    input valid_in,
    output wire [(NUMS_OF_ROUND*KEY_LEN-1) : 0] key_expan,
    output wire [NUMS_OF_ROUND-1 : 0] valid_out
);
    wire [KEY_LEN-1:0] key_arr [0 : NUMS_OF_ROUND];
    wire [NUMS_OF_ROUND-1:0] subkey_valid_out;


//---Rcon table---
wire [WORD_LEN-1:0] Rcon [0:9];
assign Rcon[0] = 32'h01000000;
assign Rcon[1] = 32'h02000000;
assign Rcon[2] = 32'h04000000;
assign Rcon[3] = 32'h08000000;
assign Rcon[4] = 32'h10000000;
assign Rcon[5] = 32'h20000000;
assign Rcon[6] = 32'h40000000;
assign Rcon[7] = 32'h80000000;
assign Rcon[8] = 32'h1B000000;
assign Rcon[9] = 32'h36000000;


// ----------------------------------------------------------------
// Round 1: Rcon = 01
// ----------------------------------------------------------------
GenSubKey #(
    .KEY_LEN(KEY_LEN)
    ) GSK_1 (
    .clk(clk),
    .reset(reset),
    .Rcon(Rcon[0]),
    .data_in(Secret_key),
    .valid_in(valid_in),
    .data_out(key_arr[0]),
    .valid_out(subkey_valid_out[0])
);

// ----------------------------------------------------------------
// Round 2: Rcon = 02
// ----------------------------------------------------------------
GenSubKey #(.KEY_LEN(KEY_LEN)) GSK_2 (
    .clk(clk),
    .reset(reset),
    .Rcon(Rcon[1]),
    .data_in(key_arr[0]),
    .valid_in(subkey_valid_out[0]),
    .data_out(key_arr[1]),
    .valid_out(subkey_valid_out[1])
);

// ----------------------------------------------------------------
// Round 3: Rcon = 04
// ----------------------------------------------------------------
GenSubKey #(.KEY_LEN(KEY_LEN)) GSK_3 (
    .clk(clk),
    .reset(reset),
    .Rcon(Rcon[2]),
    .data_in(key_arr[1]),
    .valid_in(subkey_valid_out[1]),
    .data_out(key_arr[2]),
    .valid_out(subkey_valid_out[2])
);

// ----------------------------------------------------------------
// Round 4: Rcon = 08
// ----------------------------------------------------------------
GenSubKey #(.KEY_LEN(KEY_LEN)) GSK_4 (
    .clk(clk),
    .reset(reset),
    .Rcon(Rcon[3]),
    .data_in(key_arr[2]),
    .valid_in(subkey_valid_out[2]),
    .data_out(key_arr[3]),
    .valid_out(subkey_valid_out[3])
);

// ----------------------------------------------------------------
// Round 5: Rcon = 10
// ----------------------------------------------------------------
GenSubKey #(.KEY_LEN(KEY_LEN)) GSK_5 (
    .clk(clk),
    .reset(reset),
    .Rcon(Rcon[4]),
    .data_in(key_arr[3]),
    .valid_in(subkey_valid_out[3]),
    .data_out(key_arr[4]),
    .valid_out(subkey_valid_out[4])
);

// ----------------------------------------------------------------
// Round 6: Rcon = 20
// ----------------------------------------------------------------
GenSubKey #(.KEY_LEN(KEY_LEN)) GSK_6 (
    .clk(clk),
    .reset(reset),
    .Rcon(Rcon[5]),
    .data_in(key_arr[4]),
    .valid_in(subkey_valid_out[4]),
    .data_out(key_arr[5]),
    .valid_out(subkey_valid_out[5])
);

// ----------------------------------------------------------------
// Round 7: Rcon = 40
// ----------------------------------------------------------------
GenSubKey #(.KEY_LEN(KEY_LEN)) GSK_7 (
    .clk(clk),
    .reset(reset),
    .Rcon(Rcon[6]),
    .data_in(key_arr[5]),
    .valid_in(subkey_valid_out[5]),
    .data_out(key_arr[6]),
    .valid_out(subkey_valid_out[6])
);

// ----------------------------------------------------------------
// Round 8: Rcon = 80
// ----------------------------------------------------------------
GenSubKey #(.KEY_LEN(KEY_LEN)) GSK_8 (
    .clk(clk),
    .reset(reset),
    .Rcon(Rcon[7]),
    .data_in(key_arr[6]),
    .valid_in(subkey_valid_out[6]),
    .data_out(key_arr[7]),
    .valid_out(subkey_valid_out[7])
);

// ----------------------------------------------------------------
// Round 9: Rcon = 1B
// ----------------------------------------------------------------
GenSubKey #(.KEY_LEN(KEY_LEN)) GSK_9 (
    .clk(clk),
    .reset(reset),
    .Rcon(Rcon[8]),
    .data_in(key_arr[7]),
    .valid_in(subkey_valid_out[7]),
    .data_out(key_arr[8]),
    .valid_out(subkey_valid_out[8])
);

// ----------------------------------------------------------------
// Round 10: Rcon = 36
// ----------------------------------------------------------------
GenSubKey #(.KEY_LEN(KEY_LEN)) GSK_10 (
    .clk(clk),
    .reset(reset),
    .Rcon(Rcon[9]),
    .data_in(key_arr[8]),
    .valid_in(subkey_valid_out[8]),
    .data_out(key_arr[9]),
    .valid_out(subkey_valid_out[9])
);


assign key_expan = {
    key_arr[9],
    key_arr[8],
    key_arr[7],
    key_arr[6],
    key_arr[5],
    key_arr[4],
    key_arr[3],
    key_arr[2],
    key_arr[1],
    key_arr[0]
    };
assign valid_out = subkey_valid_out;
    
endmodule