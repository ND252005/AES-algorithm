
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
    wire [7 : 0] mx = 8'h1b; 

// nhân mảng trạng thái với ma trận
// 02 03 01 01
// 01 02 03 01
// 01 01 02 03
// 03 01 01 02

// Khai báo hằng số đa thức AES (x^8 + x^4 + x^3 + x + 1)
    // ----------------------------------------------------------------------
    // BYTE 0 (Tương ứng i=0)
    // ----------------------------------------------------------------------
    assign state[0]    = data_in[127:120];
    // Kiểm tra bit cao nhất (MSB), nếu = 1 thì Dịch trái XOR 1B, ngược lại chỉ dịch trái
    assign state_x2[0] = (state[0][7]) ? ((state[0] << 1) ^ mx) : (state[0] << 1);
    assign state_x3[0] = state_x2[0] ^ state[0];

    // ----------------------------------------------------------------------
    // BYTE 1 (Tương ứng i=1)
    // ----------------------------------------------------------------------
    assign state[1]    = data_in[119:112];
    assign state_x2[1] = (state[1][7]) ? ((state[1] << 1) ^ mx) : (state[1] << 1);
    assign state_x3[1] = state_x2[1] ^ state[1];

    // ----------------------------------------------------------------------
    // BYTE 2 (Tương ứng i=2)
    // ----------------------------------------------------------------------
    assign state[2]    = data_in[111:104];
    assign state_x2[2] = (state[2][7]) ? ((state[2] << 1) ^ mx) : (state[2] << 1);
    assign state_x3[2] = state_x2[2] ^ state[2];

    // ----------------------------------------------------------------------
    // BYTE 3 (Tương ứng i=3)
    // ----------------------------------------------------------------------
    assign state[3]    = data_in[103:96];
    assign state_x2[3] = (state[3][7]) ? ((state[3] << 1) ^ mx) : (state[3] << 1);
    assign state_x3[3] = state_x2[3] ^ state[3];

    // ----------------------------------------------------------------------
    // BYTE 4 (Tương ứng i=4)
    // ----------------------------------------------------------------------
    assign state[4]    = data_in[95:88];
    assign state_x2[4] = (state[4][7]) ? ((state[4] << 1) ^ mx) : (state[4] << 1);
    assign state_x3[4] = state_x2[4] ^ state[4];

    // ----------------------------------------------------------------------
    // BYTE 5 (Tương ứng i=5)
    // ----------------------------------------------------------------------
    assign state[5]    = data_in[87:80];
    assign state_x2[5] = (state[5][7]) ? ((state[5] << 1) ^ mx) : (state[5] << 1);
    assign state_x3[5] = state_x2[5] ^ state[5];

    // ----------------------------------------------------------------------
    // BYTE 6 (Tương ứng i=6)
    // ----------------------------------------------------------------------
    assign state[6]    = data_in[79:72];
    assign state_x2[6] = (state[6][7]) ? ((state[6] << 1) ^ mx) : (state[6] << 1);
    assign state_x3[6] = state_x2[6] ^ state[6];

    // ----------------------------------------------------------------------
    // BYTE 7 (Tương ứng i=7)
    // ----------------------------------------------------------------------
    assign state[7]    = data_in[71:64];
    assign state_x2[7] = (state[7][7]) ? ((state[7] << 1) ^ mx) : (state[7] << 1);
    assign state_x3[7] = state_x2[7] ^ state[7];

    // ----------------------------------------------------------------------
    // BYTE 8 (Tương ứng i=8)
    // ----------------------------------------------------------------------
    assign state[8]    = data_in[63:56];
    assign state_x2[8] = (state[8][7]) ? ((state[8] << 1) ^ mx) : (state[8] << 1);
    assign state_x3[8] = state_x2[8] ^ state[8];

    // ----------------------------------------------------------------------
    // BYTE 9 (Tương ứng i=9)
    // ----------------------------------------------------------------------
    assign state[9]    = data_in[55:48];
    assign state_x2[9] = (state[9][7]) ? ((state[9] << 1) ^ mx) : (state[9] << 1);
    assign state_x3[9] = state_x2[9] ^ state[9];

    // ----------------------------------------------------------------------
    // BYTE 10 (Tương ứng i=10)
    // ----------------------------------------------------------------------
    assign state[10]    = data_in[47:40];
    assign state_x2[10] = (state[10][7]) ? ((state[10] << 1) ^ mx) : (state[10] << 1);
    assign state_x3[10] = state_x2[10] ^ state[10];

    // ----------------------------------------------------------------------
    // BYTE 11 (Tương ứng i=11)
    // ----------------------------------------------------------------------
    assign state[11]    = data_in[39:32];
    assign state_x2[11] = (state[11][7]) ? ((state[11] << 1) ^ mx) : (state[11] << 1);
    assign state_x3[11] = state_x2[11] ^ state[11];

    // ----------------------------------------------------------------------
    // BYTE 12 (Tương ứng i=12)
    // ----------------------------------------------------------------------
    assign state[12]    = data_in[31:24];
    assign state_x2[12] = (state[12][7]) ? ((state[12] << 1) ^ mx) : (state[12] << 1);
    assign state_x3[12] = state_x2[12] ^ state[12];

    // ----------------------------------------------------------------------
    // BYTE 13 (Tương ứng i=13)
    // ----------------------------------------------------------------------
    assign state[13]    = data_in[23:16];
    assign state_x2[13] = (state[13][7]) ? ((state[13] << 1) ^ mx) : (state[13] << 1);
    assign state_x3[13] = state_x2[13] ^ state[13];

    // ----------------------------------------------------------------------
    // BYTE 14 (Tương ứng i=14)
    // ----------------------------------------------------------------------
    assign state[14]    = data_in[15:8];
    assign state_x2[14] = (state[14][7]) ? ((state[14] << 1) ^ mx) : (state[14] << 1);
    assign state_x3[14] = state_x2[14] ^ state[14];

    // ----------------------------------------------------------------------
    // BYTE 15 (Tương ứng i=15)
    // ----------------------------------------------------------------------
    assign state[15]    = data_in[7:0];
    assign state_x2[15] = (state[15][7]) ? ((state[15] << 1) ^ mx) : (state[15] << 1);
    assign state_x3[15] = state_x2[15] ^ state[15];

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