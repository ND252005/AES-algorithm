`timescale 1ns/1ps

module Top_Pipelined_tb;

    // ============================================================
    // Parameters
    // ============================================================
    parameter DATA_W   = 128;
    parameter KEY_LEN  = 128;
    parameter NO_ROUNDS = 10;

    // ============================================================
    // DUT signals
    // ============================================================
    reg clk;
    reg reset;
    reg data_valid_in;
    reg cipherkey_valid_in;

    reg  [KEY_LEN-1:0]  cipher_key;
    reg  [DATA_W-1:0]   plain_text;

    wire valid_out;
    wire [DATA_W-1:0] cipher_text;

    // ============================================================
    // Instantiate DUT
    // ============================================================
    Top_Pipelined #(
        .DATA_W(DATA_W),
        .KEY_LEN(KEY_LEN),
        .NO_ROUNDS(NO_ROUNDS)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .data_valid_in(data_valid_in),
        .cipherkey_valid_in(cipherkey_valid_in),
        .cipher_key(cipher_key),
        .plain_text(plain_text),
        .valid_out(valid_out),
        .cipher_text(cipher_text)
    );

    // ============================================================
    // Clock generator (10 ns period = 100 MHz)
    // ============================================================
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // ============================================================
    // Task: Apply Key + Plaintext
    // ============================================================
    task apply_data(
        input [KEY_LEN-1:0] key,
        input [DATA_W-1:0]  pt
    );
    begin
        @(posedge clk);
        cipher_key         <= key;
        plain_text         <= pt;

        cipherkey_valid_in <= 1;
        data_valid_in      <= 1;

        @(posedge clk);
        cipherkey_valid_in <= 0;
        data_valid_in      <= 0;
    end
    endtask

    // ============================================================
    // Main stimulus
    // ============================================================
    initial begin
        // Dump waveform for ModelSim
        $dumpfile("Top_Pipelined_tb.vcd");
        $dumpvars(0, Top_Pipelined_tb);

        // Init signals
        reset             = 0;
        cipherkey_valid_in = 0;
        data_valid_in      = 0;
        cipher_key         = 0;
        plain_text         = 0;

        // Apply reset
        repeat (5) @(posedge clk);
        reset = 1;

        // =======================================================
        // AES-128 TEST VECTOR (FIPS-197)
        // =======================================================
        // KEY = 2b7e151628aed2a6abf7158809cf4f3c
        // PT  = 3243f6a8885a308d313198a2e0370734
        // CT  = 3925841d02dc09fbdc118597196a0b32

        apply_data(
            128'h10a58869d74be5a374cf867cfb473859,  // key
            128'h00000000000000000000000000000000   // plaintext
        );

        // =======================================================
        // Wait for output
        // =======================================================
        wait(valid_out == 1);

        #1;
        $display("==================================================");
        $display(" AES-128 PIPELINED OUTPUT");
        $display(" Ciphertext = %h", cipher_text);
        $display(" Expected    = 6d251e6944b051e04eaa6fb4dbf78465");
        $display("==================================================");

        #20;
        $stop;
    end

endmodule
