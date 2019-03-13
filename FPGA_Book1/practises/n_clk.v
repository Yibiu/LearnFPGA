// n clk
module n_clk(
	input wire rst_n,
	input wire clk_in,
	output reg clk_out
);

parameter n = 2;

reg count = 0;

always @(posedge clk_in)
	if (rst_n == 1'b0)
		count <= 1'b0;
	else
		count <= count + 1'b1;

always @(posedge clk_in)
	if (rst_n == 1'b0)
		clk_out = 1'b0;
	else if (count == n)
		clk_out = ~clk_out;


endmodule
