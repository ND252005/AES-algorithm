// Module name : KeyExpantion

`timescale 1 ns/1 ps

module KeyExpantionbyDuong #(
    parameter DATA_W = 128,
    parameter KEY_LEN = 128,
    parameter NO_ROUNDS = 10   
) (
    input clk,
    input reset,
    input valid_in,
    input [KEY_LEN-1:0] cipher_key,
    output [(NO_ROUNDS*DATA_W)-1:0] SuperKey,
    output [NO_ROUNDS-1:0] valid_out
);

wire [31:0] RCON [0:9];
wire [NO_ROUNDS-1:0] keygen_valid_out;
wire [DATA_W-1:0] SuperKey_array  [0:NO_ROUNDS-1];

// RCON qua các vòng
assign RCON[0] = 32'h01000000;
assign RCON[1] = 32'h02000000;
assign RCON[2] = 32'h04000000;
assign RCON[3] = 32'h08000000;
assign RCON[4] = 32'h10000000;
assign RCON[5] = 32'h20000000;
assign RCON[6] = 32'h40000000;
assign RCON[7] = 32'h80000000;
assign RCON[8] = 32'h1b000000;
assign RCON[9] = 32'h36000000;
    
// Tạo khóa đầu tiên từ khóa chính
GenKey #(KEY_LEN) RKGEN_U0(clk, reset, RCON[0], valid_in, cipher_key, SuperKey_array[0], keygen_valid_out[0]);

genvar i;
generate
    for (i = 1; i< NO_ROUNDS; i=i+1) begin : ROUND_KEY_GEN
    GenKey #(KEY_LEN) RKGEN_U(clk, reset, RCON[i], keygen_valid_out[i-1],SuperKey_array[i-1], SuperKey_array[i], keygen_valid_out[i]);
    end
endgenerate

// Gộp tất cả khóa vòng thành một output
assign SuperKey = {  SuperKey_array[0],
                     SuperKey_array[1],
                     SuperKey_array[2],
                     SuperKey_array[3],
                     SuperKey_array[4],
                     SuperKey_array[5],
                     SuperKey_array[6],
                     SuperKey_array[7],
                     SuperKey_array[8],
                     SuperKey_array[9] };
assign valid_out = keygen_valid_out;

endmodule