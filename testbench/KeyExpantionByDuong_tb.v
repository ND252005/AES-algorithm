`timescale 1ns/1ps

module KeyExpantionbyDuong_tb();

    // Tham số
    parameter DATA_W   = 128;
    parameter KEY_LEN  = 128;
    parameter NO_ROUNDS = 10;

    // DUT Signals
    reg clk;
    reg reset;
    reg valid_in;
    reg [KEY_LEN-1:0] cipher_key;

    wire [(NO_ROUNDS*DATA_W)-1:0] SuperKey;
    wire [NO_ROUNDS-1:0] valid_out;

    // Khởi tạo DUT
    KeyExpantionbyDuong #(
        .DATA_W(DATA_W),
        .KEY_LEN(KEY_LEN),
        .NO_ROUNDS(NO_ROUNDS)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .valid_in(valid_in),
        .cipher_key(cipher_key),
        .SuperKey(SuperKey),
        .valid_out(valid_out)
    );

    // Clock 10ns
    always #5 clk = ~clk;

    integer k;
    reg [127:0] round_key_tmp;

    initial begin
        $display("===== START KEY EXPANSION TEST =====");

        // INIT
        clk = 0;
        reset = 0;
        valid_in = 0;
        cipher_key = 0;

        // RESET
        #12 reset = 1;

        // Apply input key
        #10;
        cipher_key = 128'h2b7e151628aed2a6abf7158809cf4f3c;   // AES-128 test key chuẩn NIST
        valid_in = 1;

        #10 valid_in = 0;

        // Wait until last round valid output fires
        wait (valid_out[9] == 1);
        #20;

        $display("\n===== ALL ROUND KEYS (SUPERKEY) =====");
        $display("SuperKey (1280-bit) = %h\n", SuperKey);

        // PRINT ROUND KEYS SEPARATELY
        $display("===== PRINT KEYS ONE BY ONE =====");

        for (k = 0; k < NO_ROUNDS; k = k + 1) begin
            // SuperKey = {round0, round1, ..., round9} → round0 nằm trên cùng
            round_key_tmp = SuperKey[((NO_ROUNDS-1-k)*128) +: 128];
            $display("Round %0d Key = %h", k, round_key_tmp);
        end

        $display("\n===== TEST DONE =====");
        $stop;
    end

endmodule
