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


// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk; // 10 ns clock period    
end

// Test sequence
initial begin
    $display("===== AES PIPELINED TOP TESTBENCH START =====");
    
    // Initialize
    reset = 0;
    data_valid_in = 0;
    key_valid_in  = 0;
    cipher_key  = 128'h0;
    plain_text  = 128'h0;

    #20;
    reset = 1;

    // ================================
    // AES-128 TEST VECTOR (FIPS-197)
    // ================================
    // plaintext = 00112233445566778899aabbccddeeff
    // key       = 000102030405060708090a0b0c0d0e0f

    cipher_key = 128'h000102030405060708090a0b0c0d0e0f;
    plain_text = 128'h00112233445566778899aabbccddeeff;

    // Apply key
    #10;
    key_valid_in = 1;
    #10;
    key_valid_in = 0;

    // Apply plaintext
    #20;
    data_valid_in = 1;
    #10;
    data_valid_in = 0;

    // =====================
    // Waiting for result
    // =====================
    wait(valid_out == 1);

    #5;
    $display("===== AES Encryption Completed =====");
    $display("Cipher Text = %h", cipher_text);

    #20;
    $stop;
end

// =====================
// Debug monitor
// =====================
initial begin
    $monitor("Time=%0t | valid_out=%b | cipher_text=%h",
              $time, valid_out, cipher_text);
end

endmodule