module Set(
    input wire clk,

    input reg [1:0] enable,

    // for now, specify which block to make one for now
    input reg [3:0] block_num,       // 4 blocks per set


    // input reg for block offset
    input reg [5:0] block_offset,

    // take the input data
    input reg [63:0] write_data,   

    // specify the write (read) size
    input reg [1:0] data_size // 0: 8, 1: 16, 2: 32, 3: 64.



);


integer test_c = 0;
integer i;
integer j;

integer bit_n;

integer start_idx; // the start of the bits to write.
integer end_idx; // the end of the bits to write.

reg [511:0] bit_mask;

// 4 blocks, each block is 64 bytes big.
reg [511:0] membank [3:0];


    always @(posedge clk) begin
        test_c = test_c + 1;
        if (enable & (test_c < 3)) begin

            // construct bit mask
            bit_mask = ~bit_mask;

            start_idx = (512 - (2**data_size * 8) - (block_offset * 8));
            end_idx =  (512 - (block_offset * 8));

            for (bit_n = 0; bit_n < 512; bit_n = bit_n + 1) begin

                // if the bits are to be set to 0
                if (bit_n >= start_idx && bit_n < end_idx) begin
                    bit_mask[bit_n] = 0;
                end
            end
            
    
            // set the data
            membank[block_num] = membank[block_num] & bit_mask;
            membank[block_num] = membank[block_num] | (write_data << start_idx);

            // 000000000|000000000|0000000000000
            
            // $display("data: %d", 1 >> (block_offset * 8));
            $display("membank:");

            for (i = 0; i < 4; i = i + 1) begin
                for (j = 0; j < 512; j = j + 1) begin
                    $write("%d", membank[i][j]);
                end

                $display("");
            end


            // test_c = 1;

        end
    end 

    

endmodule