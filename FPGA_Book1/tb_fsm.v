`timescale 1ns/1ns

module tb_fsm(
);

reg tb_clk, tb_rst_n, tb_A;
wire tb_K1, tb_K2;

initial
	begin
		tb_clk = 0;
		tb_rst_n = 0;
		tb_A = 0;
		#20
		tb_rst_n = 1;
	end
	
always #50 tb_clk = ~tb_clk;
	
always @(posedge tb_clk)
	begin
		#30
		tb_A = {$random} % 2;
		#(3 * 50 + 10)
	end

fms fms_inst(
	.clk(tb_clk),
	.rst_n(tb_rst_n),
	.A(tb_A),
	.K1(tb_K1),
	.K2(tb_K2)
);

endmodule
