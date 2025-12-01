`timescale 1 ns/1 ps

module Top_tb;

parameter DATA_W = 128;
parameter KEY_LEN = 128;
parameter NO_ROUNDS = 10;

// DUT signals
reg input clk;
reg reset;
reg data_valid_in;
reg key_valid_in;
input [KEY_LEN-1:0] cipher_key;
input [DATA_W-1:0] plain_text;


wire valid_out;
wire [DATA_W-1:0] cirpher_text;

Top_Pipelined #(DATA_W, KEY_LEN, NO_ROUNDS) DUT (
    .clk(clk),
    .reset(reset),
    .data_valid_in(data_valid_in),
    .key_valid_in(key_valid_in),
    .cipher_key(cipher_key),
    .plain_text(),
    .valid_out(valid_out),
    .cipher_text(cipher_text)
);


