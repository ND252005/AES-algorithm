// module name: ShiftRows

`timescale 1 ns/1 ps
module ShiftRows
 #(
    parameter DATA_LEN = 128
)(
    input clk,
    input reset,               // tích cực mức thấp
    input valid_in,            // tín hiệu đầu vào hợp lệ
    input [DATA_LEN-1:0] data_in,
    output reg valid_out,      // tín hiệu đầu ra hợp lệ
    output reg [DATA_LEN-1:0] data_out
);

wire [7:0] State [0:15]; // mảng lưu các phần tử của mảng 2 chiều 4x4 với mỗi phần tử 8bits

// chia 8bits/1 phần tử của mảng hai chiều
// i = 0: Lấy byte cao nhất (Bits 127-120)
    assign State[0]  = data_in[127:120];

    // i = 1: Bits 119-112
    assign State[1]  = data_in[119:112];

    // i = 2: Bits 111-104
    assign State[2]  = data_in[111:104];

    // i = 3: Bits 103-96
    assign State[3]  = data_in[103:96];

    // i = 4: Bits 95-88
    assign State[4]  = data_in[95:88];

    // i = 5: Bits 87-80
    assign State[5]  = data_in[87:80];

    // i = 6: Bits 79-72
    assign State[6]  = data_in[79:72];

    // i = 7: Bits 71-64
    assign State[7]  = data_in[71:64];

    // i = 8: Bits 63-56
    assign State[8]  = data_in[63:56];

    // i = 9: Bits 55-48
    assign State[9]  = data_in[55:48];

    // i = 10: Bits 47-40
    assign State[10] = data_in[47:40];

    // i = 11: Bits 39-32
    assign State[11] = data_in[39:32];

    // i = 12: Bits 31-24
    assign State[12] = data_in[31:24];

    // i = 13: Bits 23-16
    assign State[13] = data_in[23:16];

    // i = 14: Bits 15-8
    assign State[14] = data_in[15:8];

    // i = 15: Lấy byte thấp nhất (Bits 7-0)
    assign State[15] = data_in[7:0];
    
always @(posedge clk or negedge reset)

if(!reset) begin
    valid_out <= 1'b0;
    data_out <= 'b0;
end else begin

   if(valid_in) begin
    data_out[127:96] <= {State[0], State[5], State[10], State[15]};
    data_out[95:64] <= {State[4], State[9], State[14], State[3]};
    data_out[63:32] <= {State[8], State[13], State[2], State[7]};
    data_out[31:0] <= {State[12], State[1], State[6], State[11]};
   end
   valid_out = valid_in;
end
endmodule
