`timescale 1 ns/1 ps

module Round_tb;

parameter DATA_W = 128;

// DUT signals
reg clk;
reg reset;
reg data_valid_in;
reg key_valid_in;
reg [DATA_W-1:0] data_in;
reg [DATA_W-1:0] round_key;

wire valid_out;
wire [DATA_W-1:0] data_out;

// Instantiate DUT
Round #(DATA_W) DUT (
    .clk(clk),
    .reset(reset),
    .data_valid_in(data_valid_in),
    .key_valid_in(key_valid_in),
    .data_in(data_in),
    .round_key(round_key),
    .valid_out(valid_out),
    .data_out(data_out)
);

// Clock
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Stimulus
initial begin
    reset = 0;
    data_valid_in = 0;
    key_valid_in = 0;
    data_in = 0;
    round_key = 0;

    #20 reset = 1;

    #10;
    data_in    = 128'h00112233445566778899AABBCCDDEEFF;
    data_valid_in = 1;
    #10;
    data_valid_in = 0;
    #25;
    round_key  = 128'h000102030405060708090A0B0C0D0E0F;
    key_valid_in  = 1;

    #10;
    key_valid_in  = 0;

    repeat(20) @(posedge clk);
    $finish;
end

// Debug prints
always @(posedge clk) begin
    if (DUT.valid_sub_to_shift)
        $display("SubBytes  = %h", DUT.data_sub_to_shift);

    if (DUT.valid_shift_to_mix)
        $display("ShiftRows = %h", DUT.data_shift_to_mix);

    if (DUT.valid_mix_to_addkey)
        $display("MixCols   = %h", DUT.data_mix_to_addkey);

    if (valid_out)
        $display("AddKey Out = %h", data_out);
end

endmodule
