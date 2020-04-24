`include "cache.v"

module cachebench(
    input wire clk
);

    // Once done with work, set this line to high so that
    // higher-level component can resume whatever.
    reg [1:0] CPU_ENABLE;
    
    // set to low if there was a local miss
    // and need to forward instruction to next cache.
    // lower component will set to high when its done.
    reg [1:0] ENABLE = 1;

    // the write enable line
    reg [1:0] write_enable_in;

    // the data to write to the membank
    reg [63:0] write_data_in;

    // the address to read/write to       <-- IDK
    // 24 tag, 6 for set index, 6 block offset
    reg [63:0] address_in;

    // specify the data write/read size
    reg [2:0] write_size_in;

    // the data coming in from the lower caches
    reg [127:0] data_in;

    // cache line flush
    reg [1:0] CLF;

    // THE OUTPUTs

    // the data forwarded to the above cache (the CPU in our case)
    reg [127:0] data_out;

    // forward the write enable line
    reg [1:0] write_enable_out;

    // the data to be written into the lower cache
    reg [63:0] write_data_out;

    // forward the read/write address 
    reg [63:0] address_out;

    // forward the write size
    reg [2:0] write_size_out;

    // forward CLF
    reg [1:0] CLF_out;


L1_D l(clk, CPU_ENABLE, ENABLE, write_enable_in, write_data_in, 19999, write_size_in, data_in, CLF,
    data_out, write_enable_out, write_data_out, address_out, write_size_out, CLF_out);

initial begin
    $display("Cache Bench!");
end

always @(negedge clk) begin
    ENABLE = 1;
end


endmodule
cachebench c(clock.val);
