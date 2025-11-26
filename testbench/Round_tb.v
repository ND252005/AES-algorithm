`timescale 1 ns/1 ps

module tb_Round;

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

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;     // 10ns clock
end

// Stimulus
initial begin

    // Initial values
    reset = 0;
    data_valid_in = 0;
    key_valid_in = 0;
    data_in = 0;
    round_key = 0;

    // Apply reset
    #12;
    reset = 1;
    #10;

    // Provide test data
    data_in = 128'h00112233445566778899AABBCCDDEEFF;
    round_key = 128'h000102030405060708090A0B0C0D0E0F;

    data_valid_in = 1;
    key_valid_in  = 1;

    #10;
    data_valid_in = 0;   // one-cycle valid
    key_valid_in  = 0;

    // Wait for the pipeline to complete all stages
    repeat(20) @(posedge clk);

    $display("Simulation Done.");
    $finish;
end

// Print stage outputs
always @(posedge clk) begin
    if (DUT.valid_sub_to_shift)
        $display("SubBytes Output = %h", DUT.data_sub_to_shift);

    if (DUT.valid_shift_to_mix)
        $display("ShiftRows Output = %h", DUT.data_shift_to_mix);

    if (DUT.valid_mix_to_addkey)
        $display("MixColumns Output = %h", DUT.data_mix_to_addkey);

    if (valid_out)
        $display("AddRoundKey Output (Final Stage) = %h", data_out);
end

endmodule
