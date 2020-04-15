module Set(
    input wire clk,

    input wire enable,

    // for now, specify which block to make one for now
    input reg [128:0] block_num


);

// dirty bit, valid bit, 24 bit tag, 128 blocks, 4 sets.

// 128 blocks, each block is 64 bits big.
reg [128:0] membank [64:0];


    always @(posedge clk) begin
        if (enable) begin

            // make specified block all one
            membank[block_num] = 1;
            $display("membank: %d", membank[block_num]);
        end
    end 

    

endmodule