`timescale 1 ns/1 ps

module GenKey_tb();

// =========================
// THAM SỐ
// =========================
parameter KEY_LEN  = 128;
parameter WORD_LEN = 32;

// =========================
// Tín hiệu testbench
// =========================
reg clk;
reg reset;
reg valid_in;
reg [KEY_LEN-1:0] key_in;
reg [WORD_LEN-1:0] Rcon;

wire [KEY_LEN-1:0] round_key;
wire valid_out;

// =========================
// KHỞI TẠO MODULE DUT
// =========================
GenKey #(KEY_LEN, WORD_LEN) dut (
    .clk(clk),
    .reset(reset),
    .Rcon(Rcon),
    .valid_in(valid_in),
    .key_in(key_in),
    .round_key(round_key),
    .valid_out(valid_out)
);

// =========================
// Tạo clock
// =========================
always #5 clk = ~clk;   // chu kỳ 10ns

// =========================
// Test logic
// =========================
initial begin
    $display("=== BEGIN GENKEY TEST ===");

    // -------------------------
    // Khởi tạo tín hiệu
    // -------------------------
    clk = 0;
    reset = 0;
    valid_in = 0;
    key_in = 128'h0;
    Rcon = 32'h0;

    // RESET
    #20;
    reset = 1;

    // -------------------------
    // Test 1: gửi khóa AES-128 ban đầu
    // -------------------------
    // Ví dụ khóa chuẩn FIPS-197:
    // Key = 2b7e151628aed2a6abf7158809cf4f3c
    key_in = 128'h2b7e151628aed2a6abf7158809cf4f3c;

    // Rcon vòng 1 = 01 00 00 00
    Rcon = 32'h01000000;

    #10;
    valid_in = 1;
    #10;
    valid_in = 0;

    // -------------------------
    // Chờ kết quả
    // -------------------------
    wait(valid_out == 1);

    #1;
    $display("Round Key = %h", round_key);

    #20;
    $display("=== END GENKEY TEST ===");
    $finish;
end

endmodule
