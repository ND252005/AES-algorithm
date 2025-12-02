/*
    testbench file for generate subkey

*/
`timescale 1ns/1ps
module GenSubKey_tb;

    parameter KEY_LEN = 128;
    parameter WORD_LEN = 32;

    reg clk;
    reg reset;
    reg opcode;
    reg [WORD_LEN-1 : 0] Rcon;
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
        .opcode(opcode),
      	.Rcon(Rcon),
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
      $monitor ("Time=%d   |   Rcon=%h   |   last_sub_key=%h   |   valid_in=%b   |   current_key=%h   |   valid_out=%b| opcode=%b",
                $time, Rcon, last_sub_key, valid_in, current_key, valid_out, opcode);
    end
    initial begin
      	// #5; Rcon = 32'h01000000; last_sub_key = 128'h2b7e151628aed2a6abf7158809cf4f3c; valid_in = 1; opcode = 0;
        // #40; valid_in = 0;valid_out=0;
        #5; Rcon = 32'h01000000; last_sub_key = 128'h2b7e151628aed2a6abf7158809cf4f3c; valid_in = 1; opcode = 0;
        #40;valid_in = 0;
        #30;
        $finish;
    end


endmodule
