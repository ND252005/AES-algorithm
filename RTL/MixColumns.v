// module name: MixColums 

module MixColumns
     #(
    parameter DATA_W = 128
) (
    input clk,
    input reset,
    input valid_in,
    input [DATA_W-1:0] data_in,
    output reg valid_out,
    output reg [DATA_W-1:0] data_out
);

wire [7:0] State [0:15];
wire [7:0] State_x2 [0:15];
wire [7:0] State_x3 [0:15];

genvar i;
generate
    for (i = 0;i<=15; i=i+1) begin :MUL
         assign State[i] = data_in[(((15-i)*8)+7):((15-i)*8)];
         assign State_x2[i] = (State[i][7])?((State[i]<<1) ^ 8'h1b):(State[i]<<1);
         assign State_x3[i] = (State_x2[i]) ^ State[i];
    end
endgenerate
    
always @(posedge clk or negedge reset) begin
    if(!reset) begin
        valid_out <= 1'b0;
        data_out <= 'b0;
    end else begin
        if (valid_in) begin
            // cột 1
           data_out[(15*8)+7:(15*8)] <= State_x2[0] ^ State_x3[1] ^ State[2] ^ State[3];
           data_out[(14*8)+7:(14*8)] <= State[0] ^ State_x2[1] ^ State_x3[2] ^ State[3];
           data_out[(13*8)+7:(13*8)] <= State[0] ^ State[1] ^ State_x2[2] ^ State_x3[3];
           data_out[(12*8)+7:(12*8)] <= State_x3[0] ^ State[1] ^ State[2] ^ State_x2[3];
           //cột 2
           data_out[(11*8)+7:(11*8)] <= State_x2[4] ^ State_x3[5] ^ State[6] ^ State[7];
           data_out[(10*8)+7:(10*8)] <= State[4] ^ State_x2[5] ^ State_x3[6] ^ State[7];
           data_out[(9*8)+7:(9*8)] <= State[4] ^ State[5] ^ State_x2[6] ^ State_x3[7];
           data_out[(8*8)+7:(8*8)] <= State_x3[4] ^ State[5] ^ State[6] ^ State_x2[7];
           //cột 3
           data_out[(7*8)+7:(7*8)] <= State_x2[8] ^ State_x3[9] ^ State[10] ^ State[11];
           data_out[(6*8)+7:(6*8)] <= State[8] ^ State_x2[9] ^ State_x3[10] ^ State[11];
           data_out[(5*8)+7:(5*8)] <= State[8] ^ State[9] ^ State_x2[10] ^ State_x3[11];
           data_out[(4*8)+7:(4*8)] <= State_x3[8] ^ State[9] ^ State[10] ^ State_x2[11];
           //cột 4
           data_out[(3*8)+7:(3*8)] <= State_x2[12] ^ State_x3[13] ^ State[14] ^ State[15];
           data_out[(2*8)+7:(2*8)] <= State[12] ^ State_x2[13] ^ State_x3[14] ^ State[15];
           data_out[(1*8)+7:(1*8)] <= State[12] ^ State[13] ^ State_x2[14] ^ State_x3[15];
           data_out[(0*8)+7:(0*8)] <= State_x3[12] ^ State[13] ^ State[14] ^ State_x2[15];
        end
    end
    valid_out <= valid_in;
end
endmodule