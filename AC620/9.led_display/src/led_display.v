/**
* @brief:
* 数码管显示。
* ISSP --> led_driver --> 74hc959_driver --> 74HC595 --> 数码管
*
* @reource:
* clk_50mhz --> PIN_E1
* rst_n --> PIN_E16
* ds --> PIN_E6
* sh_clk --> PIN_F6
* st_clk --> PIN_B4
*/
module led_display(
	input wire clk_50mhz,
	input wire rst_n,
	output wire ds,
	output wire sh_clk,
	output wire st_clk
);

wire [31:0] dis_data;
wire [7:0] sel;
wire [7:0] seg;


// ISSP例化
hex_data hex_data_inst0(
	.probe(),
	.source(dis_data)
);


// LED驱动例化
led_driver led_driver_inst0(
	.clk_50mhz(clk_50mhz),
	.rst_n(rst_n),
	.en(1'b1),
	.dis_data(dis_data),
	.sel(sel),
	.seg(seg)
);


// HC959例化
hc595_driver hc595_driver_inst0(
	.clk_50mhz(clk_50mhz),
	.rst_n(rst_n),
	.en(1'b1),
	.data({seg, sel}),
	.ds(ds),
	.sh_clk(sh_clk),
	.st_clk(st_clk)
);

endmodule
