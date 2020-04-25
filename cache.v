/**
 * cache.v
 * The main implementation for our cache. We use a large memory bank that has all
 * the memory of the cache. Once we know which set needs to perform the reads and writes,
 * we pass a subset of our memory bank to the set module. The set then performs the specified
 * operation and the cache module manages forwarding and eviction (we think).
 */

`include "set.v"


module L1(
    input wire clk,

    // Once done with work, set this line to high so that
    // higher-level component can resume whatever.
    output reg [1:0] CPU_ENABLE,
    
    // set to low if there was a local miss
    // and need to forward instruction to next cache.
    // lower component will set to high when its done.
    input reg [1:0] ENABLE,


    input reg [1:0] READ_IN,

    // the write enable line
    input reg [1:0] write_enable_in,

    // the data to write to the membank
    input reg [63:0] write_data_in,

    // the address to read/write to       <-- IDK
    // 24 tag, 6 for set index, 6 block offset
    input reg [63:0] address_in, 

    // specify the data write/read size
    input reg [2:0] write_size_in,

    // the data coming in from the lower caches
    input reg [127:0] data_in,

    // cache line flush
    input reg [1:0] CLF,



    // THE OOUTPUTS

    // the data forwarded to the above cache (the CPU in our case)
    output reg [127:0] data_out,

    // forward the write enable line
    output reg [1:0] write_enable_out,

    // the data to be written into the lower cache
    output reg [63:0] write_data_out,

    // forward the read/write address 
    output reg [63:0] address_out,

    // forward the write size
    output reg [2:0] write_size_out,

    // forward CLF
    output reg [1:0] CLF_out,


    // for debugging, the current op number
    input reg [31:0] nops 


);


    // all the tag bits
    reg [23:0] tag_bits [511:0];

    // all the dirty and valid bits
    reg [1:0] valid_bits [511:0];

    // store the input address temp
    // declare registers to store the
    // calculated tag, block index
    reg [63:0] address_cpy;
    
    // physical tag
    reg [23:0] tag; // = address_cpy;                     // <-- IDk
    reg [5:0] block_offset = 0;
    reg [5:0] set_idx = 0;



    // define the registers used to control the set



    // output miss flags
    reg [1:0] set_miss_r;
    reg [1:0] set_miss_w;

    // if the read requested data is ready
    reg [1:0] data_ready;

    // data from the set
    reg [127:0] out_data;

    // used to enable the set
    reg [1:0] set_enable = 0;

    // if set to 1, then force evict to write block
    reg [1:0] force_write = 0;

    // set when set is done
    reg [1:0] op_done = 0;


    // the control stuff
    always @(posedge clk) begin

        set_enable = 0;

        if (READ_IN) begin
            
           

            // make copy of address for safety.
            address_cpy = address_in;

            // get the block offset from address.
            block_offset = address_in;

            // get the set index
            set_idx = (address_cpy >> 6);

            // get the tag
            tag = address_cpy >> 12;
           

            // if there is no data from the lower cache
            if (data_in == 0) begin

                $display("\nCACHE OPERATION (CPU) %d", nops);
                $display("  add cpy: %d, %b", address_cpy, address_cpy);
                $display("  B offset: %b", block_offset);
                $display("  S idx: %b", set_idx);
                $display("  tag: %b", tag);


                // pass instruction to the set module
                // set set enable
                set_enable = 1;

                $display("");



            // if there is data from lower
            end else if (data_in != 0) begin

                $display("\nCACHE OPERATION (Lower Cache) %d", nops);
                $display("  add cpy: %b", address_cpy);
                $display("  B offset: %b", block_offset);
                $display("  S idx: %b", set_idx);
                $display("  tag: %b", tag);


                set_enable = 1;
                force_write = 1;
                write_data_in = data_in;

                // clear the other set registers

            end

            force_write = 0;
            
            
        end

        else if (ENABLE) begin

            // set data out to data in 
            data_out = data_in;


            // then set CPU_ENABLE to high
            CPU_ENABLE = 1;
        end



    end


    always @(negedge clk) begin


        // once the issued set operation has been completed,
        // read its status and determine next cache operation.

        // if the set has data after a read op
        if (data_ready && READ_IN) begin

            $display("CACHE READ DATA FOR OPERATION %d", nops);
            $display("  data: %d", out_data);

            
            // now that we have the data from set
            // write to the data out
            data_out = out_data;

            data_ready = 0;
            out_data = 0;

            // set cpu enable, we have the requested read data
            CPU_ENABLE = 1;

        end


        // read or write miss on our databank
        else if ((set_miss_r || set_miss_w) && READ_IN) begin

            $display("CACHE OPERATION %d, WRITE MISS", nops);

            // write through the data to the lower component.
            write_data_out = write_data_in;
            address_out = address_in;
            write_enable_out = write_enable_in;
            write_size_out = write_size_in;

            READ_IN = 0;

        end


    end

    
    Set s(clk, set_enable, write_enable_in, block_offset, set_idx, write_data_in, 
    write_size_in, tag, nops, out_data, set_miss_w, set_miss_r, data_ready, force_write, op_done);

    // send stuff to that set


endmodule
