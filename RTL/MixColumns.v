
`timescale 1ns/1ps
module MixColumns #(
    parameter DATA_LEN = 128
) (
    input clk,
    input reset,
    input valid_in, //tín hiệu bắt đầu
    input [DATA_LEN-1:0] data_in, //dữ liệu đầu vào 
    output reg valid_out, //tín hiệu khi có dư liệu đầu ra
    output reg [DATA_LEN-1:0] data_out //dữ liệu đầu ra
);
    wire [7 : 0] state [0 : 15]; //state sau khi nhân với 01, không thay đổi 
    wire [7 : 0] state_x2 [0 : 15]; //state sau khi nhân với 02 
    wire [7 : 0] state_x3 [0 : 15]; //state sau khi nhân với 03 
    wire [7 : 0] mx;

    assign mx = 8'b00011011;

// nhân mảng trạng thái với ma trận
// 02 03 01 01
// 01 02 03 01
// 01 01 02 03
// 03 01 01 02

    genvar i;
    generate
        for(i=0; i < 16; i = i+1) begin : state_mix
            assign state[i] = data_in[((15-i)*8+7) : ((15-i)*8)];
             // nhân với 02 trong trường GF(2^8) = dịch trái 1 bit
            assign state_x2[i] = (state[i][7]) ? ((state[i]<<1) ^ mx) : (state[i]<<1); // không được sài điều kiện if có điều kiện là biến trong generate
            assign state_x3[i] = state_x2[i] ^ state[i]; //nhân với 03 trong trường GF(2^8) khi đã có kq nhân với 02 = statex2 xor state
        end
    endgenerate

always @(posedge clk or negedge reset) begin
    if(!reset) begin
        valid_out = 1'b0;
        data_out = 'b0;
    end else begin
        if(valid_in) begin
            data_out[(15*8+7) : (15*8)] <= state_x2[0] ^ state_x3[1] ^ state[2] ^ state[3];
            data_out[(14*8+7) : (14*8)] <= state[0] ^ state_x2[1] ^ state_x3[2] ^ state[3];
            data_out[(13*8+7) : (13*8)] <= state[0] ^ state[1] ^ state_x2[2] ^ state_x3[3];
            data_out[(12*8+7) : (12*8)] <= state_x3[0] ^ state[1] ^ state[2] ^ state_x2[3];
            // --------------------First column--------------------

            data_out[(11*8+7) : (11*8)] <= state_x2[4] ^ state_x3[5] ^ state[6] ^ state[7];
            data_out[(10*8+7) : (10*8)] <= state[4] ^ state_x2[5] ^ state_x3[6] ^ state[7];
            data_out[(9*8+7) : (9*8)]   <= state[4] ^ state[5] ^ state_x2[6] ^ state_x3[7];
            data_out[(8*8+7) : (8*8)]   <= state_x3[4] ^ state[5] ^ state[6] ^ state_x2[7];
            // --------------------Second column--------------------
            
            data_out[(7*8+7) : (7*8)]   <= state_x2[8] ^ state_x3[9] ^ state[10] ^ state[11];
            data_out[(6*8+7) : (6*8)]   <= state[8] ^ state_x2[9] ^ state_x3[10] ^ state[11];
            data_out[(5*8+7) : (5*8)]   <= state[8] ^ state[9] ^ state_x2[10] ^ state_x3[11];
            data_out[(4*8+7) : (4*8)]   <= state_x3[8] ^ state[9] ^ state[10] ^ state_x2[11];
            // --------------------Third column--------------------
            
            data_out[(3*8+7) : (3*8)]   <= state_x2[12] ^ state_x3[13] ^ state[14] ^ state[15];
            data_out[(2*8+7) : (2*8)]   <= state[12] ^ state_x2[13] ^ state_x3[14] ^ state[15];
            data_out[(1*8+7) : (1*8)]   <= state[12] ^ state[13] ^ state_x2[14] ^ state_x3[15];
            data_out[(0*8+7) : (0*8)]   <= state_x3[12] ^ state[13] ^ state[14] ^ state_x2[15];
            // --------------------Fourth column--------------------
        end
        valid_out <= valid_in;
    end


end
endmodule