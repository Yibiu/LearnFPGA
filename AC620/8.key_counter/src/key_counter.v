/**
* @brief:
* 两个独立按键+4个LED灯。
* LED灯以二进制方式显示，按下按键0加1，按下按键1减1。
* 
* @resources:
* CLK_50MHz --> PIN_E1
* RST --> PIN_E16
* Key0 --> PIN_M16
* Key1 --> PIN_E15
* LEDs --> PIN_A2, PIN_B3, PIN_A4, PIN_A3
* 
* IO Standard:3.3V LVTTL
*/
module key_counter(
	input wire clk_50mhz,
	input wire rst_n,
	input wire key_plus,
	input wire key_minus,
	output wire [3:0] leds
);

// 例化
wire key_flag0, key_state0;
wire key_flag1, key_state1;
key_filter key_filter_inst0(
	.clk_50mhz(clk_50mhz),
	.rst_n(rst_n),
	.key_in(key_plus),
	.key_flag(key_flag0),
	.key_state(key_state0)
);

key_filter key_filter_inst1(
	.clk_50mhz(clk_50mhz),
	.rst_n(rst_n),
	.key_in(key_minus),
	.key_flag(key_flag1),
	.key_state(key_state1)
);

key_ctrl key_ctrl_inst0(
	.clk_50mhz(clk_50mhz),
	.rst_n(rst_n),
	.key_flag0(key_flag0),
	.key_state0(key_state0),
	.key_flag1(key_flag1),
	.key_state1(key_state1),
	.leds(leds)
);

endmodule
