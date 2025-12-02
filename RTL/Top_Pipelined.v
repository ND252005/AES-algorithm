`timescale 1 ns / 1 ps
module Top_Pipelined #(
    parameter DATA_W = 128,
    parameter KEY_LEN = 128,
    parameter NO_ROUNDS = 10
) (
    input clk,
    input reset,
    input data_valid_in,
    input cipherkey_valid_in,
    input [KEY_LEN-1:0] cipher_key,
    input [DATA_W-1:0] plain_text,
    output valid_out,
    output [DATA_W-1:0] cipher_text
);

wire [NO_ROUNDS-1:0] valid_round_key;
wire [NO_ROUNDS-1:0] valid_round_data;
wire [DATA_W-1:0] data_round [0:NO_ROUNDS-1];
wire valid_sub_to_shift;
wire valid_shift_to_key;
wire [DATA_W-1:0] data_sub_to_shift;
wire [DATA_W-1:0] data_shift_to_key;
wire [(NO_ROUNDS*DATA_W)-1:0] W;

reg [DATA_W-1:0] data_shift_to_key_delayed;
reg valid_shift_to_key_delayed;

// Key expansion
KeyExpantionbyDuong #(DATA_W,KEY_LEN,NO_ROUNDS) U_KEYEXP (
    .clk(clk),
    .reset(reset),
    .valid_in(cipherkey_valid_in),
    .cipher_key(cipher_key),
    .SuperKey(W),
    .valid_out(valid_round_key)
);

// First AddRoundKey (initial)
AddRoundKey #(DATA_W) U0_ARK (
    .clk(clk),
    .reset(reset),
    .data_valid_in(data_valid_in),
    .key_valid_in(cipherkey_valid_in),
    .data_in(plain_text),
    .round_key(cipher_key),
    .valid_out(valid_round_data[0]),
    .data_out(data_round[0])
);

// Rounds 1..(NO_ROUNDS-1)
genvar i;
generate
    for (i = 0; i < NO_ROUNDS-1; i = i + 1) begin : ROUND
        // Note: ensure W slicing matches the layout of SuperKey (key0..key9)
        Round #(DATA_W) U_ROUND (
            .clk(clk),
            .reset(reset),
            .data_valid_in(valid_round_data[i]),
            .key_valid_in(valid_round_key[i]),
            .data_in(data_round[i]),
            .round_key(W[(NO_ROUNDS-i)*DATA_W-1 : (NO_ROUNDS-i-1)*DATA_W]),
            .valid_out(valid_round_data[i+1]),
            .data_out(data_round[i+1])
        );
    end
endgenerate

// Final round (SubBytes -> ShiftRows -> AddRoundKey)
SubBytes #(DATA_W) U_SUB (
    .clk(clk),
    .reset(reset),
    .valid_in(valid_round_data[NO_ROUNDS-1]),
    .data_in(data_round[NO_ROUNDS-1]),
    .valid_out(valid_sub_to_shift),
    .data_out(data_sub_to_shift)
);

ShiftRows #(DATA_W) U_SH (
    .clk(clk),
    .reset(reset),
    .valid_in(valid_sub_to_shift),
    .data_in(data_sub_to_shift),
    .valid_out(valid_shift_to_key),
    .data_out(data_shift_to_key)
);

// Use delayed data/key-valid to align with KeyExpantion pipeline
AddRoundKey #(DATA_W) U_KEY (
    .clk(clk),
    .reset(reset),
    .data_valid_in(valid_shift_to_key_delayed),
    .key_valid_in(valid_round_key[NO_ROUNDS-1]),
    .data_in(data_shift_to_key_delayed),
    .round_key(W[DATA_W-1:0]),
    .valid_out(valid_out),
    .data_out(cipher_text)
);

// Delay registers to balance latency (must be consistent with KeyExpantion latency)
always @(posedge clk or negedge reset) begin
    if (!reset) begin
        valid_shift_to_key_delayed <= 1'b0;
        data_shift_to_key_delayed  <= {DATA_W{1'b0}};
    end else begin
        // capture when valid is asserted
        if (valid_shift_to_key) begin
            data_shift_to_key_delayed <= data_shift_to_key;
        end
        valid_shift_to_key_delayed <= valid_shift_to_key;
    end
end

endmodule
