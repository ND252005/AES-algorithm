module MixColums_tb ();
    
parameter DATA_W = 128;
reg clk;
reg reset;
reg valid_in;
reg [DATA_W-1:0] data_in;
wire valid_out;
wire [DATA_W-1:0] data_out;
MixColums #(
    .DATA_W(DATA_W)
) MIXC (
    .clk(clk),
    .reset(reset),
    .valid_in(valid_in),
    .data_in(data_in),
    .valid_out(valid_out),
    .data_out(data_out)
);
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end
initial begin
    reset = 0;
    valid_in = 0;
    data_in = 128'h000102030405060708090a0b0c0d0e0f;
    #12;
    reset = 1;
    #10;
    valid_in = 1;
    #10;
    valid_in = 0;
    #50;
    data_in = 128'hd4bf5d30e0b452aeb84111f11e2798e;
    valid_in = 1;
    #10;
    valid_in = 0;
    #50;
    $finish;
end

initial begin
    $monitor("At time %t, reset = %b, valid_in = %b, data_in = %h => valid_out = %b, data_out = %h", $time, reset, valid_in, data_in, valid_out, data_out);
end

endmodule