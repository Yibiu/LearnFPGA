/**
* @brief:
* 按键消抖，使用状态机实现。
* FPGA频率50MHz，即周期20ns。
* 计数器20ms = 20_000_000ns。
* 20_000_000ns / 20ns = 1_000_000
* 2^19 < 1_000_000 < 2^20
*
* 按键默认状态为高，按下为低。
* flag:按键按下或释放标志；在FILTER0——>DOWN和FILTER1——>IDEL状态时为高。
* state：按键当前状态；IDEL和FILTER0为高，DOWN和FILTER1为低。
* 按键按下可由:flag && (!state)判定；按键释放可由：flag && state判定。
*/
module key_filter(
	input wire clk_50mhz,
	input wire rst_n,
	input wire key_in,
	output reg key_flag,
	output reg key_state
);

parameter IDEL = 4'b0001;
parameter FILTER0 = 4'b0010;
parameter DOWN = 4'b0100;
parameter FILTER1 = 4'b1000;

parameter CNT_20MS = 999_999;

reg [3:0] state;

// 对外部输入的异步信号进行同步处理
reg key_in_a, key_in_b;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0) begin
		key_in_a <= 1'b1;
		key_in_b <= 1'b1;
	end
	else begin
		key_in_a <= key_in;
		key_in_b <= key_in_a;
	end

// 上升沿下降沿判断
reg key_last, key_now;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0) begin
		key_last <= 1'b1;
		key_now <= 1'b1;
	end
	else begin
		key_now <= key_in_b;
		key_last <= key_now;
	end
wire pedge, nedge;
assign pedge = key_now & (!key_last);
assign nedge = (!key_now) & key_last;

// 计数器(消抖20ms)
reg en_cnt;
reg [19:0] cnt;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		cnt <= 20'd0;
	else if (en_cnt) begin
		if (cnt == CNT_20MS)
			cnt <= 20'd0;
		else
			cnt <= cnt + 1'b1;
	end
	else
		cnt <= 20'd0;

reg cnt_full;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		cnt_full <= 1'b0;
	else if (cnt == CNT_20MS)
		cnt_full <= 1'b1;
	else
		cnt_full <= 1'b0;

// 状态迁移
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0) begin
		state <= IDEL;
		en_cnt <= 1'b0;
	end
	else
		case(state)
			IDEL:
				if (nedge) begin
					state <= FILTER0;
					en_cnt <= 1'b1;
				end
			FILTER0:
				if (cnt_full) begin
					state <= DOWN;
					en_cnt <= 1'b0;
				end
				else if (pedge) begin
					state <= IDEL;
					en_cnt <= 1'b0;
				end
			DOWN:
				if (pedge) begin
					state <= FILTER1;
					en_cnt <= 1'b1;
				end
			FILTER1:
				if (cnt_full) begin
					state <= IDEL;
					en_cnt <= 1'b0;
				end
				else if (nedge) begin
					state <= DOWN;
					en_cnt <= 1'b0;
				end
			default:
				begin
					state <= IDEL;
					en_cnt <= 1'b0;
				end
		endcase

// 输出
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		key_state <= 1'b1;
	else if (state == IDEL)
		key_state <= 1'b1;
	else if (state == FILTER0) begin
		if (cnt_full)
			key_state <= 1'b0;
		else
			key_state <= 1'b1;
	end
	else if (state == DOWN)
		key_state <= 1'b0;
	else if (state == FILTER1) begin
		if (cnt_full)
			key_state <= 1'b1;
		else
			key_state <= 1'b0;
	end

always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		key_flag <= 1'b0;
	else if (state == FILTER0 && cnt_full)
		key_flag <= 1'b1;
	else if (state == FILTER1 && cnt_full)
		key_flag <= 1'b1;
	else
		key_flag <= 1'b0;

endmodule
