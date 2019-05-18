`timescale 1ns/1ns


module tb_led_driver(
);

reg tb_clk_50mhz;
reg tb_rst_n;
reg tb_en;
reg [31:0] tb_dis_data;
wire [7:0] tb_sel;
wire [7:0] tb_seg;

parameter CLK_NS = 20;

// 例化
led_driver #(.CNT_1KHZ(10)) led_driver_inst0(
	.clk_50mhz(tb_clk_50mhz),
	.rst_n(tb_rst_n),
	.en(tb_en),
	.dis_data(tb_dis_data),
	.sel(tb_sel),
	.seg(tb_seg)
);

// 时钟
always #(CLK_NS / 2) tb_clk_50mhz = ~tb_clk_50mhz;

// 初始化
initial begin
	tb_clk_50mhz = 1'b0;
	tb_rst_n = 1'b0;
	tb_en = 1'b1;
	tb_dis_data = 32'h12345678;
	#(CLK_NS * 100)
	
	tb_rst_n = 1'b1;
	#(CLK_NS * 100)
	tb_dis_data = 32'h87654321;
	#(CLK_NS * 100);
	tb_dis_data = 32'h89abcdef;
	#(CLK_NS * 100);
	
	$stop;
end

endmodule
