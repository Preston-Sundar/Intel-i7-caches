`include "cache.v"

module cachebench(
    input wire clk
);

    // Once done with work, set this line to high so that
    // higher-level component can resume whatever.
    reg [1:0] CPU_ENABLE;// low: it can operate, above is disabled
                         
    // set to low if there was a local miss
    // and need to forward instruction to next cache.
    // lower component will set to high when its done.
    reg [1:0] ENABLE;

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

    // for debugging
    reg [31:0] nops = 0; 
    reg [31:0] max_ops = 4; 


    // there is op
    reg[1:0] READ_IN;




L1 l(clk, CPU_ENABLE, ENABLE, READ_IN, write_enable_in, write_data_in, address_in, write_size_in, data_in, CLF,
    data_out, write_enable_out, write_data_out, address_out, write_size_out, CLF_out, nops);

initial begin
    $display("Cache Bench!");
end

reg [1:0] test_enable = 1;

always @(posedge clk) begin

    if (test_enable) begin

    if (nops == 0) begin
        address_in = 4096; // test, block offset = 0, set index = 0, tag is 4.
        write_enable_in = 1;
        write_data_in = 8;
        READ_IN = 1;
    end

    if (nops == 1) begin
        address_in = 8192; // test, block offset = 0, set index = 0, tag is 4.
        write_enable_in = 1;
        write_data_in = 8;
        READ_IN = 1;
    end


    if (nops == 2) begin
        address_in = 12288; // test, block offset = 0, set index = 0, tag is 4.
        write_enable_in = 1;
        write_data_in = 8;
        READ_IN = 1;
    end



    if (nops == 3) begin
        address_in = 34234234; // test, block offset = 0, set index = 0, tag is 4.
        write_enable_in = 1;
        write_data_in = 8;
        READ_IN = 1;
    end

    if (nops == max_ops) begin
        READ_IN = 0;
        nops = -1;
        test_enable = 0;
    end else begin

        nops = nops + 1;
    end

    end // test enable

end


endmodule
cachebench c(clock.val);
