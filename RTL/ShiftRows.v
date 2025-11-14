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
genvar i;
generate
    for (i=0;i<=15;i=i+1 ) begin :STATE
        assign State[i] = data_in[(((15-i)*8)+7):((15-i)*8)];
    end
endgenerate

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
