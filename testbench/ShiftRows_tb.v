`timescale 1 ns/1 ps

module ShiftRows_tb();

parameter DATA_LEN = 128;

//Tín hiệu
reg clk;
reg reset;
reg valid_in;
reg [DATA_LEN-1 : 0] data_in;
wire valid_out;
wire [DATA_LEN-1 : 0] data_out;

ShiftRows #(
    .DATA_LEN(DATA_LEN)
) test (
    .clk(clk),
    .reset(reset),
    .valid_in(valid_in),
    .data_in(data_in),
    .valid_out(valid_out),
    .data_out(data_out)
);

//Tạo xung clk
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    //Khởi tạo
    reset = 0;
    valid_in = 0;
    data_in = 0;

    //reset
    #10;
    reset = 1;

    #10;
    data_in =  128'h0123456789ABCDEFFEDCBA9876543210;
    valid_in = 1;

    #20;
     data_in =  128'h00112233445566778899AABBCCDDEEFF;
    valid_in = 1;

    #20;
    valid_in = 0;

    #20;
    $finish;
end

always @(posedge clk) begin
    if (valid_out) begin
        $display ("Time=%0t ns | data_out = %h", $time, data_out);
    end
end
endmodule