/**
* @brief:
* UART串口发送模块。
*/
module uart_send(
	input wire clk_50mhz,
	input wire rst_n,
	input wire en,
	input wire [2:0] baud,
	input wire [7:0] data,
	output reg tx_state,
	output reg tx_data,
	output reg tx_done
);


reg [3:0] state_cnt;


// 开始位检测,tx_state输出
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		tx_state <= 1'b0;
	else if (en)
		tx_state <= 1'b1;
	else if (state_cnt == 4'd10)
		tx_state <= 1'b0;
	else
		tx_state <= tx_state;


//
// 波特率计算和生成,当数据发送期间(state!=IDEL)生成波特率
// 序号baud    波特率bps    周期ns    分频计数值               50MHz系统时钟脉冲计数值
// 0           9600         104167    104167/sys_clk_period    5208-1
// 1           19200        52083     52083/sys_clk_period     2604-1
// 2           38400        26041     26041/sys_clk_period     1302-1
// 3           57600        17361     17361/sys_clk_period     868-1
// 4           115200       8680      8680/sys_clk_period      434-1
//
reg [12:0] bps_target;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		bps_target <= 13'd5207;
	else
		case(baud)
			3'd0:bps_target<=13'd5207;
			3'd1:bps_target<=13'd2603;
			3'd2:bps_target<=13'd1301;
			3'd3:bps_target<=13'd867;
			3'd4:bps_target<=13'd433;
			default:bps_target<=13'd5207;
		endcase

reg [12:0] bps_cnt;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		bps_cnt <= 13'd0;
	else if (tx_state) begin
		if (bps_cnt == bps_target)
			bps_cnt <= 13'd0;
		else
			bps_cnt <= bps_cnt + 1'b1;
	end
	else
		bps_cnt <= 13'd0;

always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		state_cnt <= 4'd0;
	else if (tx_state) begin
		if (bps_cnt == bps_target) begin
			if (state_cnt == 4'd10)
				state_cnt <= 4'd0;
			else
				state_cnt <= state_cnt + 1'b1;
		end
		else
			state_cnt <= state_cnt;
	end
	else
		state_cnt <= 4'd0;


// 状态迁移
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0) begin
		tx_data <= 1'b1;
		tx_done <= 1'b0;
	end
	else if (tx_state) begin
		case(state_cnt)
			4'd0:begin tx_data<=1'b0;tx_done<=1'b0;end
			4'd1:begin tx_data<=data[0];tx_done<=1'b0;end
			4'd2:begin tx_data<=data[1];tx_done<=1'b0;end
			4'd3:begin tx_data<=data[2];tx_done<=1'b0;end
			4'd4:begin tx_data<=data[3];tx_done<=1'b0;end
			4'd5:begin tx_data<=data[4];tx_done<=1'b0;end
			4'd6:begin tx_data<=data[5];tx_done<=1'b0;end
			4'd7:begin tx_data<=data[6];tx_done<=1'b0;end
			4'd8:begin tx_data<=data[7];tx_done<=1'b0;end
			4'd9:begin tx_data<=1'b1;tx_done<=1'b0;end
			4'd10:begin tx_data<=1'b1;tx_done<=1'b1;end
			default:begin tx_data<=1'b1;tx_done<=1'b0;end
		endcase
	end
	else begin
		tx_data <= 1'b1;
		tx_done <= 1'b0;
	end
	
endmodule

