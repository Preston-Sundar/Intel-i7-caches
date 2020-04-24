module Set(
    input wire clk,

    input reg [1:0] enable,
    input reg [1:0] write_enable,

    // for now, specify which block to make one for now
    // input reg [3:0] block_num,       // 4 blocks per set


    // input reg for block offset
    input reg [5:0] block_offset,

    // the set to read/write
    input reg [5:0] set_idx,

    // take the input data
    input reg [63:0] write_data,    

    // specify the write (read) size
    input reg [1:0] data_size, // 0: 8, 1: 16, 2: 32, 3: 64.
    input reg [23:0] tag,
    
    
    input reg [31:0] n_ops,



    output reg [127:0] out_data,  

    // 
    output reg [1:0] write_miss,
    output reg [1:0] read_miss,

    // flag if read data is ready
    output reg [1:0] data_ready,

    // if set to 1, then force evict to write block
    input reg [1:0] force_write

);


integer i;
integer j;
integer copy_idx;


integer bit_n;
integer bit_x;

integer block_i;

integer start_idx; // the start of the bits to write.
integer end_idx; // the end of the bits to write.

integer out_i;

integer block_num = -1;

reg [511:0] bit_mask;


// each set is 8-way associative
// 64 x 8 bits sets x [64 byte block x 8 blocks]
reg [511:0] bigbank [511:0];

// our tag bits for all blocks
reg [23:0] tag_bits [511:0];

// gotta do this
reg [1:0] valid_bits [511:0];

reg [511:0] membank [7:0];

// reg [7:0] test_b = 8;

integer c = 0;




    always @(posedge clk) begin

        tag_bits[0] = 15;
        tag_bits[1] = 16;
        tag_bits[2] = 17;
        tag_bits[3] = 18;

        if (enable) begin

            $display("SET OPERATION %d", n_ops);


            // calculate the part of membank to use given set index

            // bigbank[set_idx * 8] = 8;
            // bigbank[(set_idx * 8) + 1] = 3;
            // bigbank[(set_idx * 8) + 2] = 3;
            // bigbank[(set_idx * 8) + 3] = 3;


            // membank[0] = bigbank[set_idx * 8];
            // membank[1] = bigbank[(set_idx * 8) + 1];

            for (copy_idx = 0; copy_idx < 8; copy_idx = copy_idx + 1) begin
                membank[copy_idx] = bigbank[(set_idx * 8) + copy_idx];
            end        





            // $display("membank (operation num %d, WRITE: %d) :", n_ops, write_enable);

            // construct bit mask
            bit_mask = ~bit_mask;

            start_idx = (512 - (2**data_size * 8) - (block_offset * 8));
            end_idx = (512 - (block_offset * 8));


            // $display("test_b: %d", test_b);
            // for (c = 0; c < 8; c = c + 1) begin
            //     $write("%d", test_b[c]);
            // end

            $display("Tag matching:");

            // calculate the block num
            for (block_i = 0; block_i < 8; block_i = block_i + 1) begin
                // if the bits are to be set to 0
                $display("  %d == %d", tag, tag_bits[(set_idx * 8) + block_i]);
                if (tag == tag_bits[(set_idx * 8) + block_i]) begin
                    block_num = block_i;
                end
            end


            if (block_num == -1) begin


                if (write_enable == 1) begin
                    $display("Write Miss!");    
                    write_miss = 1;
                end else begin
                    $display("Read Miss!");
                    read_miss = 1;
                end

            end else begin
               
                
                if (write_enable == 1) begin
                    $display("WRITE for operation %d", n_ops);

                
                    // set the data
                    for (bit_n = 0; bit_n < 512; bit_n = bit_n + 1) begin
                        // if the bits are to be set to 0
                        if (bit_n >= start_idx && bit_n < end_idx) begin
                            bit_mask[bit_n] = 0;
                        end
                    end

                    // $display("start idx %d", start_idx);
                    // $display("end idx %d", end_idx);

                    membank[block_num] = membank[block_num] & bit_mask;
                    membank[block_num] = membank[block_num] | (write_data << start_idx);
                end else if (write_enable == 0) begin

                    $display("READ for operation %d", n_ops);

                    out_data = 0;
                    out_i = 0;

                    // $display("\nstart: %d", start_idx);
                    // $display("end: %d", end_idx);

                    // set the out data
                    for (bit_x = 0; bit_x <= 512; bit_x = bit_x + 1) begin
                        
                        if (bit_x >= start_idx && bit_x < end_idx) begin
                            out_data[out_i] = membank[block_num][bit_x];
                            // $write("poop %d\n", membank[block_num][bit_x]);
                            out_i = out_i + 1;
                        end
                    end

                    // set dat_ready to high, data can be read at neg edge
                    data_ready = 1;                    

                // otherwise its a force write
                end else if (force_write == 1) begin
                
                    


                end


            end



            // reset mask
            bit_mask = 0;
            block_num = -1;

            // write the membank back into the bigbank
            for (copy_idx = 0; copy_idx < 8; copy_idx = copy_idx + 1) begin
                bigbank[(set_idx * 8) + copy_idx] = membank[copy_idx];
            end  


            // debug print
            for (i = 0; i < 8; i = i + 1) begin
                for (j = 511; j >= 0; j = j - 1) begin
                    $write("%d", membank[i][j]);
                end
                $display("");
            end

        
        end
    end 
endmodule