`timescale 1ns/100ps
`include "./half_clk.v"


module tb_half_clk(
);


reg tb_rst_n, tb_clk_in;
wire tb_clk_out;

initial
	begin
		tb_rst_n = 0;
		tb_clk_in = 0;
		#100
		tb_rst_n = 1;
	end
	
always #50 tb_clk_in = ~tb_clk_in;

half_clk half_clk_inst(
	.rst_n(tb_rst_n),
	.clk_in(tb_clk_in),
	.clk_out(tb_clk_out)
);

endmodule
