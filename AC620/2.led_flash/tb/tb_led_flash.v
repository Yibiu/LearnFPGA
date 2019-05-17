`timescale 1ns/1ns


module tb_led_flash(
);

reg tb_clk_50mhz;
reg tb_rst_n;
wire [3:0] tb_leds;

parameter CLK_NS = 20;

// 例化
led_flash #(5) led_flash_inst0(
	.clk_50mhz(tb_clk_50mhz),
	.rst_n(tb_rst_n),
	.leds(tb_leds)
);

// 时钟
always #(CLK_NS / 2) tb_clk_50mhz = ~tb_clk_50mhz;

// 初始化
initial begin
	tb_clk_50mhz = 1'b0;
	tb_rst_n = 1'b0;
	#(CLK_NS * 10)
	
	tb_rst_n = 1'b1;
	#(CLK_NS * 1000)
	
	$stop;
end

endmodule
