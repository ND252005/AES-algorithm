//Module Name: Round

`timescale 1 ns/1 ps
module Round #(
    parameter DATA_W = 128            
) (
    input clk,
    input reset,
    input data_valid_in,
    input key_valid_in,
    input [DATA_W-1:0] data_in,
    input [DATA_W-1:0] round_key,
    output valid_out,
    output [DATA_W-1:0] data_out
);
    
wire [DATA_W-1:0] data_sub_to_shift;
wire [DATA_W-1:0] data_shift_to_mix;
wire [DATA_W-1:0] data_mix_to_addkey;

wire valid_sub_to_shift;
wire valid_shift_to_mix;
wire valid_mix_to_addkey;

// SubBytes Module
SubBytes #(DATA_W) U_SUB (
    .clk(clk),
    .reset(reset),
    .valid_in(data_valid_in),
    .data_in(data_in),
    .valid_out(valid_sub_to_shift),
    .data_out(data_sub_to_shift)
);
// ShiftRows Module
ShiftRows #(DATA_W) U_SH (
    .clk(clk),
    .reset(reset),
    .valid_in(valid_sub_to_shift),
    .data_in(data_sub_to_shift),
    .valid_out(valid_shift_to_mix),
    .data_out(data_shift_to_mix)
);
// MixColumns Module
MixColumns #(DATA_W) U_MIX (
    .clk(clk),
    .reset(reset),
    .valid_in(valid_shift_to_mix),
    .data_in(data_shift_to_mix),
    .valid_out(valid_mix_to_addkey),
    .data_out(data_mix_to_addkey)
);
// AddRoundKey Module
AddRoundKey #(DATA_W) U_KEY (
    .clk(clk),
    .reset(reset),
    .data_valid_in(valid_mix_to_addkey),
    .key_valid_in(key_valid_in),
    .data_in(data_mix_to_addkey),
    .round_key(round_key),
    .valid_out(valid_out),
    .data_out(data_out)
);

endmodule