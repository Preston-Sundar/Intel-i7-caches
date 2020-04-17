`include "set.v"

module testbench(
    input wire clk
);



reg [128:0] block_n = 1;
// wire set_enable;

reg [5:0] block_offset = 0;


reg [1:0] enable_reg = 1;
// assign set_enable = 1;


// take the input data
reg [63:0] write_data = 8;   

// specify the write (read) size
reg [1:0] data_size = 3; // 0: 8, 1: 16, 2: 32, 3: 64.

Set s(clk, enable_reg, block_n, block_offset, write_data, data_size);



initial begin
    $display("Testbench!");
    


end

endmodule

testbench t(clock.val);
