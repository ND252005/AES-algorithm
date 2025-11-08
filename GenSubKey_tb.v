/*
    testbench file for generate subkey

*/
`timescale 1ps/1ps
module GenSubKey_tb;

    parameter KEY_LEN = 128;
    parameter WORD_LEN = 32;

    reg clk;
    reg reset;
    reg [3:0] round_n;
    reg [KEY_LEN-1:0] last_sub_key;
    reg valid_in;
    wire [KEY_LEN-1:0] current_key;
    wire valid_out;

    GenSubKey #(
      .KEY_LEN(KEY_LEN),
        .WORD_LEN(WORD_LEN)
    ) GSK (
        .clk(clk),
        .reset(reset),
      	.round_n(round_n),
        .data_in(last_sub_key),
        .valid_in(valid_in),
        .data_out(current_key),
        .valid_out(valid_out)
    );
    initial begin
        reset = 1;
        clk = 0;
        forever #5 clk = ~clk;
    end
    initial begin
      $monitor ("Time=%d   |   round=%h   |   last_sub_key=%h   |   valid_out=%b   |   current_key=%h   |   valid_out=%b",
                $time, round_n, last_sub_key, valid_in, current_key, valid_out);
    end
    initial begin
      	#5;
        round_n = 0; last_sub_key = 128'h00112233445566778899AABBCCDDEEFF; valid_in = 1;
//         #20;
//         round_n = 1; last_sub_key = 128'h0F1571C947D9E8590CB7ADD6AF7F6798;
//         #20;
//         round_n = 1; last_sub_key = 128'hA1B2C3D4E5F60718293A4B5C6D7E8F90; 
//         #15;
//         round_n = 1; last_sub_key = 128'h2B7E151628AED2A6ABF7158809CF4F3C; 
        #30; valid_in = 0;
        #30;
        $finish;
    end


endmodule
