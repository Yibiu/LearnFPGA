/**
* @brief:
* 按键消抖后的LED控制输出。
* key_flag表示产生了稳定的按下或者释放跳变；
* key_state是按键的稳定状态；
* 按键按下:key_flag && (!key_state),持续一个脉冲;按键释放:key_flag && key_state.
*
* 注：开发板上是低电平亮，可以根据需要反转。
*/
module key_ctrl(
	input wire clk_50mhz,
	input wire rst_n,
	input wire key_flag0,
	input wire key_state0,
	input wire key_flag1,
	input wire key_state1,
	output wire [3:0] leds
);

reg [3:0] leds_r;

// LEDS输出
// Key0和Key1应该并行判断，但考虑到几乎不同时按这两个按键这里就使用if...else...
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		leds_r <= 4'b0000;
	else if (key_flag0 && !key_state0)
		leds_r <= leds_r + 1'b1;
	else if (key_flag1 && !key_state1)
		leds_r <= leds_r - 1'b1;

// 根据需要反转
assign leds = ~leds_r;

endmodule
