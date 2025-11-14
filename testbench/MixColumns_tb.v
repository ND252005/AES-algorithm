`timescale 1 ns/1 ps

module MixColumns_tb ();
    parameter DATA_LEN = 128;
    reg clk;
    reg reset;
    reg valid_in;
    reg [DATA_LEN-1:0] data_in;
    wire valid_out;
    wire [DATA_LEN-1:0] data_out; 

    initial begin
        clk = 0;
        reset = 1;
        forever #5 clk = ~clk;
    end

    MixColumns #(
        .DATA_LEN(DATA_LEN)
    ) mxcl (
        .clk(clk),
        .reset(reset),
        .valid_in(valid_in),
        .data_in(data_in),
        .valid_out(valid_out),
        .data_out(data_out)
    );


    initial begin
        $monitor ("Time=%d   |   input=%h   |   valid_in=%b   |    output=%h  |   valid_out=%b",
                $time, data_in, valid_in, data_out, valid_out);
    end

    initial begin    
        data_in = 128'h00112233445566778899AABBCCDDEEFF; valid_in = 1;
        #30;
        data_in = 128'h0F1571C947D9E8590CB7ADD6AF7F6798;
        #30;
        data_in = 128'hA1B2C3D4E5F60718293A4B5C6D7E8F90; 
        #30;
        data_in = 128'h2B7E151628AED2A6ABF7158809CF4F3C; 
        #10; valid_in = 0;
        #30;
        $finish;
    end


endmodule