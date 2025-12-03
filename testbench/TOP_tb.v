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

    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    task drive_test(
        input [127:0] plain_text_, 
        input [127:0] cipher_key_
    );
        begin
            @(posedge clk);
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

            //chờ data valid out lên 1
            wait(data_valid_out == 1'b1);
            
            #1;
            $display("[Time %0t] OUTPUT | Cipher: %h", $time, cipher_text);

 
            @(posedge clk);
            #10;            
        end
    endtask

    initial begin
        // --- Khởi tạo ban đầu ---
        reset = 0;       // Đang Reset (Active Low: 0 là Reset)
        data_valid_in = 0;
        key_valid_in  = 0;
        plain_text = 0;
        cipher_key = 0;

        // Reset hệ thống
        #(CLK_PERIOD * 5);
        reset = 1;
        $display("[Time %0t] System Reset Released...", $time);
        #(CLK_PERIOD * 2);

        // ==========================================
        // ==============TEST CASE 1=================
        // ==========================================
        drive_test(
            128'h000102030405060708090a0b0c0d0e0f,
            128'h00112233445566778899aabbccddeeff
        );

        // ==========================================
        // ==============TEST CASE 2=================
        // ==========================================
        drive_test(
            128'h54776f204f6e65204e696e652054776f,
            128'h5468617473206d79204b756e67204675
        );

        // Kết thúc mô phỏng
        #100;
        $display("----------------------------------------------------------");
        $display("All tests finished.");
        $stop;
    end

endmodule