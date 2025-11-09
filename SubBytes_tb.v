// Code your testbench here
// or browse Examples
`timescale 1ns/1ps
module SubBytes_tb;
    parameter DATA_LEN = 128;
    reg clk;
    reg reset;
    reg valid_in;
    wire valid_out;
    reg [DATA_LEN-1 : 0] data_in;
    wire [DATA_LEN-1 : 0] data_out;

    SubBytes #(.DATA_LEN(DATA_LEN)) Sb (
            .clk(clk), 
            .reset(reset), 
            .valid_in(valid_in), 
            .data_in(data_in),
            .valid_out(valid_out),
            .data_out(data_out)
    );
    initial begin
        reset = 1;
        clk = 0;
        forever #5 clk = ~clk;  // Chu kỳ = 10ns (100MHz)
    end

    initial begin    
        data_in = 128'h00112233445566778899AABBCCDDEEFF; valid_in = 1;
        #10;
        data_in = 128'h0F1571C947D9E8590CB7ADD6AF7F6798;
        #10;
        data_in = 128'hA1B2C3D4E5F60718293A4B5C6D7E8F90; 
        #10;
        data_in = 128'h2B7E151628AED2A6ABF7158809CF4F3C; 
        #10; valid_in = 0;
        #30;
        $finish;
    end
    initial begin
        $monitor ("Time=%d   |   input=%h   |   valid_in=%b   |    output=%h  |   valid_out=%b",
                $time, data_in, valid_in, data_out, valid_out);        
    end

endmodule