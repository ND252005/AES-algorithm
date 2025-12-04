`timescale 1ns/1ps

module TOP_tb ();

    parameter KEY_LEN = 128;
    parameter DATA_LEN = 128;
    parameter NUMS_OF_ROUND = 10;
    parameter CLK_PERIOD = 10;

    reg clk, reset; 
    reg data_valid_in;
    reg [DATA_LEN-1 : 0] plain_text;
    reg key_valid_in;
    reg [KEY_LEN-1 : 0] cipher_key;
    
    wire data_valid_out;
    wire [DATA_LEN-1 : 0] cipher_text;

    // Instantiate DUT
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

    // --- 1. Clock Generation ---
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // --- 2. Monitor Block (Quan trọng cho Pipeline) ---
    // Khối này chạy song song, luôn rình xem có kết quả đầu ra không
    // Nó không chặn việc gửi dữ liệu đầu vào.
    initial begin
        forever begin
            @(posedge clk);
            if (data_valid_out) begin
                $display("[Time %0t] OUTPUT RECEIVED | Cipher: %h", $time, cipher_text);
            end
        end
    end

    // --- 3. Input Driver (Gửi dữ liệu) ---
    initial begin
        // A. Khởi tạo
        reset = 0;       // Giả sử Reset Active Low (Mức 0 là reset)
        data_valid_in = 0;
        key_valid_in  = 0;
        plain_text = 0;
        cipher_key = 0;

        // B. Reset hệ thống
        #(CLK_PERIOD * 5);
        reset = 1;       // Thả Reset
        $display("[Time %0t] System Reset Released...", $time);
        #(CLK_PERIOD * 2);

        // C. Bắt đầu nạp Pipeline (Gửi liên tiếp không chờ đợi)
        $display("--- BAT DAU NAP PIPELINE ---");

        // --- Gói tin 1 (Cycle T) ---
        @(posedge clk); // Đợi cạnh lên clock
        data_valid_in <= 1;
        key_valid_in  <= 1;
        plain_text    <= 128'h00112233445566778899aabbccddeeff;
        cipher_key    <= 128'h000102030405060708090a0b0c0d0e0f;
        $display("[Time %0t] Sent Packet 1", $time);

        // --- Gói tin 2 (Cycle T+1) ---
        // Nạp ngay lập tức ở chu kỳ tiếp theo
        @(posedge clk); 
        data_valid_in <= 1;
        key_valid_in  <= 1;
        plain_text    <= 128'h3243f6a8885a308d313198a2e0370734;
        cipher_key    <= 128'h2b7e151628aed2a6abf7158809cf4f3c;
        $display("[Time %0t] Sent Packet 2 (Pipeline)", $time);

        // --- Gói tin 3 (Cycle T+2 - Optional) ---
        @(posedge clk); 
        data_valid_in <= 1;
        key_valid_in  <= 1;
        plain_text    <= 128'h00000000000000000000000000000000;
        cipher_key    <= 128'h00000000000000000000000000000000;
        $display("[Time %0t] Sent Packet 3 (Pipeline)", $time);

        // --- Dừng gửi ---
        @(posedge clk);
        data_valid_in <= 0;
        key_valid_in  <= 0;
        plain_text    <= 0;
        cipher_key    <= 0;
        $display("--- NGUNG NAP, CHO KET QUA ---");

        // D. Chờ đủ lâu để Pipeline xả hết dữ liệu ra
        #(CLK_PERIOD * 150); 
        
        $display("All tests finished.");
        $stop;
    end

endmodule