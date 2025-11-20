`timescale 1ns/1ps
module KeyExpantion_tb;
    parameter NUMS_OF_ROUND = 10;
    parameter KEY_LEN = 128;
    reg clk;
    reg reset;
    reg [KEY_LEN-1 : 0] Secret_key;
    reg valid_in;
    wire [(NUMS_OF_ROUND*KEY_LEN-1) : 0] key_array;
    wire [NUMS_OF_ROUND-1 : 0] valid_out;
    reg  [NUMS_OF_ROUND-1 : 0] prev_valid_out;
    

    KeyExpantion #(
        .KEY_LEN(KEY_LEN),
        .NUMS_OF_ROUND(NUMS_OF_ROUND)
    ) KEX (
        .clk(clk),
        .reset(reset),
        .Secret_key(Secret_key),
        .valid_in(valid_in),
        .key_expan(key_array),
        .valid_out(valid_out)
    );

    initial begin
        reset = 1;
        prev_valid_out = 'b0;
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
    reset = 0;
    valid_in = 0;
    Secret_key = 0;
    #12;
    reset = 1;
    #10;
    Secret_key = 128'h00112233445566778899AABBCCDDEEFF;
    valid_in = 1;
    end

//---Hàm in dữ liệu, khi bắt đầu valid được set lên, chạy tới khi kết thúc
    integer i;
always @(posedge clk) begin
    if (valid_out != prev_valid_out) begin
        $display("---- Time=%0t ----", $time);
        for (i = 0; i < 10; i = i + 1) begin
        $display("Round %0d key = %h | valid_out = %b", i, key_array[i*KEY_LEN +: KEY_LEN], valid_out);
        end
        prev_valid_out <= valid_out;
    end
end

endmodule
// # ---- Time=495000 ----
// # Round 0 key = c0393478846c520f0cf5f8b4c028164b
// # Round 1 key = f67e87c27212d5cd7ee72d79becf3b32
// # Round 2 key = 789ca46c0a8e71a174695cd8caa667ea
// # Round 3 key = 541923185e9752b92afe0e61e058698b
// # Round 4 key = 2ee01ef970774c405a894221bad12baa
// # Round 5 key = 3011b20d4066fe4d1aefbc6ca03e97c6
// # Round 6 key = c29906ed82fff8a0981044cc382ed30a
// # Round 7 key = 73ff61eaf100994a6910dd86513e0e8c
// # Round 8 key = da54053b2b549c71424441f7137a4f7b
// # Round 9 key = 36d024461d84b8375fc0f9c04cbab6bb