`timescale 1ns/1ns


module tb_hc595_driver(
);

reg tb_clk_50mhz;
reg tb_rst_n;
reg tb_en;
reg [15:0] tb_data;
wire tb_ds;
wire tb_sh_clk;
wire tb_st_clk;

parameter CLK_NS = 20;

// 例化
hc595_driver hc595_driver_inst0(
	.clk_50mhz(tb_clk_50mhz),
	.rst_n(tb_rst_n),
	.en(tb_en),
	.data(tb_data),
	.ds(tb_ds),
	.sh_clk(tb_sh_clk),
	.st_clk(tb_st_clk)
);

// 时钟
always #(CLK_NS / 2) tb_clk_50mhz = ~tb_clk_50mhz;

// 初始化
initial begin
	tb_clk_50mhz = 1'b0;
	tb_rst_n = 1'b0;
	tb_en = 1'b0;
	tb_data = 16'h0000;
	#(CLK_NS * 10)
	
	tb_rst_n = 1'b1;
	#(CLK_NS * 10)
	
	tb_en = 1'b1;
	tb_data = 16'habcd;
	#(CLK_NS * 100)
	tb_data = 16'h8ff1;
	#(CLK_NS * 100)
	
	$stop;
end

endmodule
