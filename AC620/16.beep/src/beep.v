/**
* @brief:
* 利用PWM控制蜂鸣器。
* 每500ms切换一次音调。
* 500_000_000ns / 20ns = 25_000_000.
*
* @resources:
* clk_50mhz --> PIN_E1
* rst_n --> PIN_E16
* bp --> PIN_L16
*
* IO Standard: 3.3V-LVTTL
*/
module beep(
	input wire clk_50mhz,
	input wire rst_n,
	output wire bp
);

parameter CNT_500MS = 24_999_999;

reg [31:0] counter_arr;
wire [31:0] counter_ccr;

// PWM频率计数变量
localparam
	// 低音
	L1 = 191130,
	L2 = 170241,
	L3 = 151698,
	L4 = 143183,
	L5 = 127550,
	L6 = 113635,
	L7 = 101234,
	// 中音
	M1 = 95546,
	M2 = 85134,
	M3 = 75837,
	M4 = 71581,
	M5 = 63775,
	M6 = 56817,
	M7 = 50617,
	// 高音
	H1 = 47823,
	H2 = 42563,
	H3 = 37921,
	H4 = 35793,
	H5 = 31887,
	H6 = 28408,
	H7 = 25309;

// 500ms计时
reg [24:0] cnt;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		cnt <= 25'd0;
	else if (cnt == CNT_500MS)
		cnt <= 25'd0;
	else
		cnt <= cnt + 1'b1;

// 21个状态按500ms间隔依次切换
reg [4:0] pitch_state;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		pitch_state <= 5'd0;
	else if (cnt == CNT_500MS) begin
		if (pitch_state == 5'd20)
			pitch_state <= 5'd0;
		else
			pitch_state <= pitch_state + 1'b1;
	end
	else
		pitch_state <= pitch_state;

// PWM频率计数值
always @(*)
	case(pitch_state)
		5'd0:counter_arr = L1;
		5'd1:counter_arr = L2;
		5'd2:counter_arr = L3;
		5'd3:counter_arr = L4;
		5'd4:counter_arr = L5;
		5'd5:counter_arr = L6;
		5'd6:counter_arr = L7;
		5'd7:counter_arr = M1;
		5'd8:counter_arr = M2;
		5'd9:counter_arr = M3;
		5'd10:counter_arr = M4;
		5'd11:counter_arr = M5;
		5'd12:counter_arr = M6;
		5'd13:counter_arr = M7;
		5'd14:counter_arr = H1;
		5'd15:counter_arr = H2;
		5'd16:counter_arr = H3;
		5'd17:counter_arr = H4;
		5'd18:counter_arr = H5;
		5'd19:counter_arr = H6;
		5'd20:counter_arr = H7;
		default:counter_arr = L1;
	endcase

// PWM占空比计数值，始终为50%
assign counter_ccr = counter_arr >> 1;

// PWM例化
pwm_generator pwm_generator_inst0(
	.clk_50mhz(clk_50mhz),
	.rst_n(rst_n),
	.en(1'b1),
	.counter_arr(counter_arr),
	.counter_ccr(counter_ccr),
	.pwm(bp)
);

endmodule

