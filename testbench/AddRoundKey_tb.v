`timescale 1 ns/1 ps
module AddRoundKey_tb();

parameter DATA_W = 128;

// Tín hiệu
reg clk;
reg reset;
reg data_valid_in;
reg key_valid_in;
reg [DATA_W-1:0] data_in;
reg [DATA_W-1:0] round_key;
wire valid_out;
wire [DATA_W-1:0] data_out;

//Gọi inst
AddRoundKey #(
    .DATA_W(DATA_W)
) test(
    .clk(clk),
    .reset(reset),
    .data_valid_in(data_valid_in),
    .key_valid_in(key_valid_in),
    .data_in(data_in),
    .round_key(round_key),
    .valid_out(valid_out),
    .data_out(data_out)
);

//Tạo xung clk
initial begin
    clk = 0;
    forever begin
        #5 clk = ~clk;
    end
end


initial begin
    //Khởi tạo
    reset = 0;
    data_valid_in = 0;
    key_valid_in = 0;
    data_in = 0;
    round_key = 0;

    //Reset
    #10;
    reset = 1;

    #10;
    //Test1
    data_in =  128'h0123456789ABCDEFFEDCBA9876543210;
    round_key = 128'h00112233445566778899AABBCCDDEEFF;
    data_valid_in = 1;
    key_valid_in = 1;

    #20;
    //Test2
    data_in = 128'hFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
    round_key = 128'h00000000000000000000000000000000;
    data_valid_in = 1;
    key_valid_in = 1;

    #20;
    data_valid_in = 0;
    round_key = 0;

    #20;
    $finish;
end
always @(posedge clk) begin
    if (valid_out) begin
        $display ("Time=%0t ns | data_out = %h", $time, data_out);
    end
end

endmodule
