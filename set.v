module Set(
    input wire clk,

    input reg [1:0] enable,
    input reg [2:0] write_enable,

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
    output reg [1:0] data_ready 

);


integer i;
integer j;
integer d;


integer bit_n;
integer bit_x;

integer block_i;

integer start_idx; // the start of the bits to write.
integer end_idx; // the end of the bits to write.

integer out_i;

integer block_num = -1;

reg [511:0] bit_mask;


// each set is 8-way associative
// 64 sets x [64 byte block x 8 blocks]
reg [511:0] bigbank [511:0];

reg [23:0] tag_bits [511:0];
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


            // calculate the part of membank to use given set index

            // bigbank[set_idx * 8] = 8;
            // bigbank[(set_idx * 8) + 1] = 3;
            // bigbank[(set_idx * 8) + 2] = 3;
            // bigbank[(set_idx * 8) + 3] = 3;


            // membank[0] = bigbank[set_idx * 8];
            // membank[1] = bigbank[(set_idx * 8) + 1];

            for (d = 0; d < 8; d = d + 1) begin
                membank[d] = bigbank[(set_idx * 8) + d];
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

            $display("");

            // calculate the block num
            for (block_i = 0; block_i < 8; block_i = block_i + 1) begin
                // if the bits are to be set to 0
                $display("%d == %d", tag, tag_bits[(set_idx * 8) + block_i]);
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
                    $display("membank (operation num %d, WRITE) :", n_ops);

                
                    // set the data
                    for (bit_n = 0; bit_n < 512; bit_n = bit_n + 1) begin
                        // if the bits are to be set to 0
                        if (bit_n >= start_idx && bit_n < end_idx) begin
                            bit_mask[bit_n] = 0;
                        end
                    end

                    $display("start idx %d", start_idx);
                    $display("end idx %d", end_idx);

                    membank[block_num] = membank[block_num] & bit_mask;
                    membank[block_num] = membank[block_num] | (write_data << start_idx);
                end else if (write_enable == 0) begin

                    $display("membank (operation num %d, READ) :", n_ops);

                    out_data = 0;
                    out_i = 0;

                    $display("\nstart: %d", start_idx);
                    $display("end: %d", end_idx);
                    // set the data
                    for (bit_x = start_idx; bit_x <= end_idx; bit_x = bit_x + 1) begin
                        
                        out_data[out_i] = membank[block_num][bit_x];
                        $write("%d", membank[block_num][bit_x]);

                        out_i = out_i + 1;

                    end



                    data_ready = 1;                    
                end else if (write_enable == 2) begin
                    $display("NO OP on Set");
                end



            end



            // reset mask
            bit_mask = 0;
            block_num = -1;


            for (i = 0; i < 8; i = i + 1) begin
                for (j = 511; j >= 0; j = j - 1) begin
                    $write("%d", membank[i][j]);
                end
                $display("");
            end

        
        end
    end 
endmodule