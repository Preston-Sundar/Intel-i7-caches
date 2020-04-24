/**
 * cache.v
 * The main implementation for our cache. We use a large memory bank that has all
 * the memory of the cache. Once we know which set needs to perform the reads and writes,
 * we pass a subset of our memory bank to the set module. The set then performs the specified
 * operation and the cache module manages forwarding and eviction (we think).
 */

module L1_D(
    input wire clk,

    // Once done with work, set this line to high so that
    // higher-level component can resume whatever.
    output reg [1:0] CPU_ENABLE,
    
    // set to low if there was a local miss
    // and need to forward instruction to next cache.
    // lower component will set to high when its done.
    input reg [1:0] ENABLE,

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
    output reg [1:0] CLF_out


);

    // the BIG bank
    // each set is 8-way associative
    // 64 sets x [64 byte block x 8 blocks]
    reg [511:0] bigbank [511:0];

    // all the tag bits
    reg [23:0] tag_bits [511:0];

    // all the dirty and valid bits
    reg [1:0] valid_bits [511:0];


    // store the input address temp
    // declare registers to store the
    // calculated tag, block index
    reg [63:0] address_cpy = 0;
    // physical tag
    reg [24:0] tag = 0;
    reg [6:0] block_offset = 0;
    
    // make copy of address (safety)
    address_cpy = address_in;

    
    // determine the set index


    // Set s(clk, enable_reg, write_en, block_offset, write_data, 
    // data_size, tag, num_ops, out_data, miss_w, miss_r, data_ready);

    // send stuff to that set


endmodule