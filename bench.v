`include "set.v"

module testbench(
    input wire clk
);


// offset within the block
reg [5:0] block_offset = 0;

// emable line for set operation
reg [1:0] enable_reg = 1;


// take the input data
reg [63:0] write_data = 8;   

// specify the write (read) size
reg [1:0] data_size = 3; // 0: 8, 1: 16, 2: 32, 3: 64.

// tag
reg [23:0] tag = 15;

// debug, which op number
reg [31:0] num_ops;

// output miss flags
reg [1:0] miss_r;
reg [1:0] miss_w;

// write enable
reg [2:0] write_en = 1;

// if the read requested data is ready
reg [1:0] data_ready;

// data from the set
reg [127:0] out_data;

reg [511:0] membanks;

Set s(clk, enable_reg, membanks, write_en, block_offset, write_data, data_size, tag, num_ops, out_data, miss_w, miss_r, data_ready);




initial begin
    $display("Testbench!");
end

always @(negedge clk) begin

    num_ops = num_ops + 1;

    
    if (num_ops == 1) begin
        write_en = 1;
        tag = 16;
        block_offset = 0;
        write_data = 3;
        data_size = 0;
    end

    if (num_ops == 2) begin
        write_en = 1;
        tag = 25;
        block_offset = 0;
        write_data = 8;
        data_size = 0;
    end


    if (num_ops == 3) begin
        write_en = 0;
        tag = 15;
        block_offset = 0;
        data_size = 3;
    end

    if (num_ops == 4) begin // only does the reading No Op
        write_en = 2;
        $display("DATA: %d", out_data);
    end


    // if (num_ops == 5) begin     // force read miss
    //     write_en = 0;
    //     tag = 19;
    //     block_offset = 0;
    //     data_size = 3;
    // end

    // if (num_ops == 6) begin // only does the reading No Op
    //     write_en = 2;
    //     $display("DATA: %d", out_data);
    // end


    // if (num_ops == 7) begin     // force read miss
    //     write_en = 1;
    //     tag = 19;
    //     block_offset = 0;
    //     data_size = 3;
    // end

    // if (num_ops == 8) begin // only does the reading No Op
    //     write_en = 2;
    //     $display("DATA: %d", out_data);
    // end



    if (num_ops >= 4) begin
        enable_reg = 0;
    end
end



endmodule

testbench t(clock.val);
