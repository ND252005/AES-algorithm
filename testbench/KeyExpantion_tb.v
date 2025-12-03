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
    Secret_key = 128'h2b7e151628aed2a6abf7158809cf4f3c;
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
