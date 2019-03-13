// Half clk
module half_clk(
	input wire rst_n,
	input wire clk_in,
	output reg clk_out
);

always @(posedge clk_in)
	if (rst_n == 1'b0)
		clk_out = 1'b0;
	else
		clk_out = ~clk_out;

endmodule
