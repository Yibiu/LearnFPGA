/**
* @brief:
* PWM产生。
* PWM由频率填装值counter_arr和占空比填装值counter_ccr决定。
*
*                     fclk                                    fclk
* PWM频率：fpwm = -----------------    ---->    counter_arr = ----- - 1
*                  counter_arr + 1                            fpwm
*
*                  counter_ccr
* PWM占空比：PW = --------------    ---->    counter_ccr = PW x counter_arr
*                  counter_arr
*/
module pwm_generator(
	input wire clk_50mhz,
	input wire rst_n,
	input wire en,
	input wire [31:0] counter_arr,
	input wire [31:0] counter_ccr,
	output reg pwm
);

// PWM频率产生
reg [31:0] cnt;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		cnt <= 32'd0;
	else if (en) begin
		if (cnt >= counter_arr)
			cnt <= 32'd0;
		else
			cnt <= cnt + 1'b1;
	end
	else
		cnt <= 32'd0;

// PWM占空比产生
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		pwm <= 1'b0;
	else if (en) begin
		if (cnt < counter_ccr)
			pwm <= 1'b1;
		else
			pwm <= 1'b0;
	end
	else
		pwm <= 1'b0;

endmodule
