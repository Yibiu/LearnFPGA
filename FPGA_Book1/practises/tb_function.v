`timescale 1ns/100ps
`include "./function.v"


module tb_function(
);

reg tb_rst_n, tb_clk;
reg [3:0] tb_n;
wire [31:0] tb_result;

reg i;

initial
	begin
		tb_rst_n = 1'b0;
		tb_clk = 1'b0;
		tb_n = 1'b0;
		#100
		tb_rst_n = 1'b1;
		#10
		for (i = 0;i <= 15; i = i + 1)
			begin
				#200
				n = i;
			end
	end
	
always #50 tb_clk = ~tb_clk;

func func_inst(
	.rst_n(tb_rst_n),
	.clk(tb_clk),
	.n(tb_n),
	.result(tb_result)
);

endmodule


