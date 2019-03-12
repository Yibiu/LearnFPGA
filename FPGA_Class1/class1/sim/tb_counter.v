`timescale 1ns/100ps

module tb_counter(
);

reg tb_clk, tb_rst_n;
wire [9:0] tb_cnt;

// 初始化模块(上电只执行一次)
initial
	begin
		tb_clk <= 0;
		tb_rst_n <= 1'b0;
		#200
		tb_rst_n <= 1'b1;
	end
	
always #10 tb_clk <= ~tb_clk;

// 模块例化
// 原始模块是输出信号，括号内必须是wire变量
counter counter_inst(
	.clk (tb_clk),
	.rst_n (tb_rst_n),
	.cnt (tb_cnt)
);


endmodule
