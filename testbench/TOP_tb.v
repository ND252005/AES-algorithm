`timescale 1ns/1ps
module TOP_tb ();
    reg clk, reset;
    reg data_valid_in;
    reg [DATA_LEN-1 : 0] plain_text;
    reg key_valid_in;
    reg [KEY_LEN-1 : 0] cipher_key;
    wire data_valid_out;
    wire [DATA_LEN-1 : 0] cipher_text;

endmodule