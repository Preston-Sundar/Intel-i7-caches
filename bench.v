`include "set.v"

module testbench(
    input wire clk
);

// 8 ten bit regs
// reg [9:0] arr [9:0];

// wire q, r;
// Foo f(q, r);
// assign q = 1;

// integer i;
// integer j;

reg [128:0] block_n = 1;
wire set_enable;
assign set_enable = 1;


Set s(clk, set_enable, block_n);

assign set_enable = 0;

initial begin
//     arr[0] = 1 + 2;
//     arr[3] = 5 + 1;

//     for (i = 0; i < 10; i = i + 1) begin
//         for (j = 0; j < 10; j = j + 1) begin
//             $write("%d", arr[i][j]);
//         end
//         $display("");
//     end
    $display("Testbench!");
end

endmodule

testbench t(clock.val);
