/**
* @brief:
* 四个LED每500ms闪烁一次，定时器的使用；
* FPGA-AC620时钟频率为50MHz；
* 简单时序逻辑实现，always块使用。
*
* 50MHz = 20ns
* 500ms =  500_000_000ns / 20ns = 25_000_000
* 2^24 < 25_000_000 < 2^25
*
* @resources:
* clk_50mhz -> PIN_E1
* rst_n -> PIN_E16
* leds[0] -> PIN_A2
* leds[1] -> PIN_B3
* leds[2] -> PIN_A4
* leds[3] -> PIN_A3
*
* IO Standard: 3.3-V LVTTL
* LED默认高电平，低电平亮。
*/
module led_flash(
	input wire clk_50mhz,
	input wire rst_n,
	output reg [3:0] leds
);

parameter CNT_500MS = 24_999_999;

// 计数器
reg [24:0] cnt;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		cnt <= 25'd0;
	else if (cnt == CNT_500MS)
		cnt <= 25'd0;
	else
		cnt <= cnt + 1'b1;

// LEDs闪烁
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		leds <= 4'b1111;
	else if (cnt == CNT_500MS)
		leds <= ~leds;

endmodule
