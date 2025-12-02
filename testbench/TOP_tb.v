`timescale 1ns/1ps
module TOP_tb ();
    parameter KEY_LEN = 256;
    parameter DATA_LEN = 128;
    parameter NUMS_OF_ROUND = 14;

    reg clk, reset; 
    reg data_valid_in;
    reg [DATA_LEN-1 : 0] plain_text;
    reg key_valid_in;
    reg [KEY_LEN-1 : 0] cipher_key;
    wire data_valid_out;
    wire [DATA_LEN-1 : 0] cipher_text;

    TOP #(
        .KEY_LEN(KEY_LEN),
        .DATA_LEN(DATA_LEN),
        .NUMS_OF_ROUND(NUMS_OF_ROUND)
    ) AES_algorithm (
        .clk(clk),
        .reset(reset),
        .data_valid_in(data_valid_in),
        .plain_text(plain_text),
        .key_valid_in(key_valid_in),
        .cipher_key(cipher_key),
        .data_valid_out(data_valid_out),
        .cipher_text(cipher_text)
    );

    // tạo xung clk
    initial begin
        clk = 0;
        forever begin
            #5 clk = ~clk;
        end
    end
    // monitor output
    always @(posedge clk) begin
        if (data_valid_out) begin
            $display("Time = %0t ns", $time);
            $display("Cipher text output = %h", cipher_text);
        end
    end

    initial begin
        // init signals
        reset = 0;
        data_valid_in = 0;
        key_valid_in  = 0;
        plain_text = 0;
        cipher_key = 0;
        key_valid_in = 0;

        // ---- Test vector (có thể thay đổi) ----
        cipher_key = 128'h00000000000000000000000000000000;
        plain_text = 128'hf34481ec3cc627bacd5dc3fb08f273e6;
        
        #10; 
        key_valid_in = 0;
        data_valid_in = 0;

        #20;
        reset = 1;
        data_valid_in = 1;
        key_valid_in = 1;
        $display("Time = %0t ns", $time);
        $display("plain text input = %h | cipher key input = %h", plain_text, cipher_key);
        // thêm delay cho chắc
        #1000;
        $finish;
    end

endmodule