`timescale 1ns/1ps

module Round_tb;

    // 1. Khai báo tham số
    parameter DATA_LEN = 128;
    parameter CLK_PERIOD = 10; // Chu kỳ xung clock (ví dụ 10ns = 100MHz)

    // 2. Khai báo tín hiệu Input (reg) và Output (wire)
    reg clk;
    reg reset;                  // Active Low
    reg data_valid_in;
    reg [DATA_LEN-1 : 0] data_in;
    reg key_valid_in;
    reg [DATA_LEN-1 : 0] sub_key;
    
    wire valid_out;
    wire [DATA_LEN-1 : 0] data_out;

    // 3. Gọi module DUT (Device Under Test)
    Round #(
        .DATA_LEN(DATA_LEN)
    ) dut (
        .clk(clk),
        .reset(reset),
        .data_valid_in(data_valid_in),
        .data_in(data_in),
        .key_valid_in(key_valid_in),
        .sub_key(sub_key),
        .valid_out(valid_out),
        .data_out(data_out)
    );

    // 4. Tạo xung Clock
    initial begin
        clk = 0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    // 5. Khối kịch bản kiểm tra (Stimulus)
    initial begin
        // --- Giai đoạn 1: Khởi tạo giá trị ban đầu ---
        $display("------------------------------------------------------------------");
        $display("Simulation Start");
        reset = 1'b0;           // Đang Reset (Active Low)
        data_valid_in = 1'b0;
        key_valid_in = 1'b0;
        data_in = 128'd0;
        sub_key = 128'd0;

        // --- Giai đoạn 2: Thả Reset ---
        #(CLK_PERIOD * 2);
        reset = 1'b1;           // Ngắt Reset (Cho phép mạch chạy)
        $display("Time: %0t | Reset De-asserted", $time);
        
        // Đợi 1 nhịp để hệ thống ổn định
        @(posedge clk);

        // --- Giai đoạn 3: Test Case 1 - Đưa dữ liệu mẫu vào ---
        // Giả sử đây là Input của Round 1 theo chuẩn FIPS-197 (Ví dụ minh họa)
        // Data Input:  Block start of Round 1
        // Round Key:   Round Key 1
        
        data_valid_in = 1'b1;
        key_valid_in  = 1'b1;
        
        // Dữ liệu giả định (Bạn có thể thay bằng vector test chuẩn nếu muốn)
        data_in = 128'h3243f6a8885a308d313198a2e0370734; 
        sub_key = 128'h2b7e151628aed2a6abf7158809cf4f3c; 

        $display("Time: %0t | INPUT  | Data: %h | Key: %h", $time, data_in, sub_key);

        // Giữ tín hiệu Input trong 1 chu kỳ clock
        @(posedge clk);
        
        // --- Giai đoạn 4: Ngắt tín hiệu đầu vào (Kiểm tra pipeline) ---
        // Thử đưa về 0 để xem mạch có tự đẩy dữ liệu ra sau vài nhịp clock không
        data_valid_in = 1'b0;
        key_valid_in  = 1'b0;
        data_in = 128'd0; 
        sub_key = 128'd0;

        // --- Giai đoạn 5: Test Case 2 (Pipeline Test - Optional) ---
        // Nếu muốn test khả năng xử lý liên tục, bạn có thể uncomment đoạn này:
        /*
        #(CLK_PERIOD * 2);
        data_valid_in = 1'b1; key_valid_in = 1'b1;
        data_in = 128'hAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
        sub_key = 128'h55555555555555555555555555555555;
        @(posedge clk);
        data_valid_in = 1'b0; key_valid_in = 1'b0;
        */

        // Đợi đủ lâu để dữ liệu đi qua hết các tầng (SubBytes -> ShiftRows -> MixColumns -> AddRoundKey)
        // Vì mạch Pipeline nên sẽ có độ trễ (Latency) khoảng 1-4 nhịp clock tùy vào thiết kế con của bạn
        #(CLK_PERIOD * 10);
        
        $display("------------------------------------------------------------------");
        $stop; // Dừng mô phỏng
    end

    // 6. Khối hiển thị kết quả tự động (Monitor)
    always @(posedge clk) begin
        if (valid_out) begin
            $display("Time: %0t | OUTPUT | Result: %h", $time, data_out);
        end
    end

endmodule