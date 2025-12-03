`timescale 1ns/1ps

module TOP_tb ();

    // 1. Khai báo tham số
    parameter KEY_LEN = 128;
    parameter DATA_LEN = 128;
    parameter NUMS_OF_ROUND = 10;
    parameter CLK_PERIOD = 10; // 10ns = 100MHz

    // 2. Khai báo tín hiệu
    reg clk, reset; 
    reg data_valid_in;
    reg [DATA_LEN-1 : 0] plain_text;
    reg key_valid_in;
    reg [KEY_LEN-1 : 0] cipher_key;
    
    wire data_valid_out;
    wire [DATA_LEN-1 : 0] cipher_text;

    // 3. Gọi Module AES (DUT)
    // Đảm bảo tên module TOP và các tham số khớp với file thiết kế của bạn
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

    // 4. Tạo xung Clock
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // 5. Task chạy Test Case
    task drive_test(
        input [127:0] plain_text_, 
        input [127:0] cipher_key_
    );
        begin
            // --- Bước 1: Nạp dữ liệu vào ---
            @(posedge clk); // Đợi cạnh lên clock để đồng bộ
            plain_text    = plain_text_;
            cipher_key    = cipher_key_;
            data_valid_in = 1'b1;
            key_valid_in  = 1'b1;
            
            $display("----------------------------------------------------------");
            $display("[Time %0t] INPUT  | Plain: %h | Key: %h", $time, plain_text_, cipher_key_);
    
            // Giữ tín hiệu valid trong 1 chu kỳ clock (Pulse)
            @(posedge clk);
            data_valid_in = 1'b0;
            key_valid_in  = 1'b0;

            // --- Bước 2: Đợi kết quả (Wait for valid_out) ---
            // Lệnh wait sẽ treo task tại đây cho đến khi valid_out lên 1
            // Lưu ý: Nếu mạch bị lỗi reset và valid_out không bao giờ lên 1, mô phỏng sẽ treo tại đây.
            wait(data_valid_out == 1'b1);
            
            // --- Bước 3: Hiển thị kết quả (Ngay khi có valid) ---
            #1; // Delay nhỏ để tránh race condition khi hiển thị
            $display("[Time %0t] OUTPUT | Cipher: %h", $time, cipher_text);

            // --- Bước 4: Nghỉ giữa các lần test ---
            // Đợi hết chu kỳ hiện tại
            @(posedge clk); 
            // Nghỉ thêm 10ns như yêu cầu
            #10;            
        end
    endtask

    // 6. Kịch bản chạy (Main Test)
    initial begin
        // --- Khởi tạo ban đầu ---
        reset = 0;       // Đang Reset (Active Low: 0 là Reset)
        data_valid_in = 0;
        key_valid_in  = 0;
        plain_text = 0;
        cipher_key = 0;

        // Reset hệ thống
        #(CLK_PERIOD * 5);
        reset = 1;       // Thả Reset (Active Low: 1 là Chạy)
        $display("[Time %0t] System Reset Released...", $time);
        #(CLK_PERIOD * 2);

        // // ==========================================
        // // TEST CASE 1: Theo chuẩn FIPS-197
        // // ==========================================
        // drive_test(
        //     128'h00112233445566778899aabbccddeeff, // Plaintext
        //     128'h000102030405060708090a0b0c0d0e0f  // Key
        // );

        // // ==========================================
        // // TEST CASE 2: Test vector của bạn
        // // ==========================================
        // drive_test(
        //     128'hf34481ec3cc627bacd5dc3fb08f273e6, 
        //     128'h00000000000000000000000000000000 
        // );

        // ==========================================
        // TEST CASE 3: Thử một key khác
        // ==========================================
        drive_test(
            128'h3243f6a8885a308d313198a2e0370734,
            128'h2b7e151628aed2a6abf7158809cf4f3c
        );

        // Kết thúc mô phỏng
        #100;
        $display("----------------------------------------------------------");
        $display("All tests finished.");
        $stop;
    end

endmodule