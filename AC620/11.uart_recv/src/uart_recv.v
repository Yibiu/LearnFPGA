/**
* @brief:
* UART接收模块。
* 部分细节见UART_SEND。
*/
module uart_recv(
	input wire clk_50mhz,
	input wire rst_n,
	input wire [2:0] baud,
	input wire data,
	output reg rx_state,
	output reg [7:0] rx_data,
	output reg rx_done
);


// START + DATA0~7 + STOP
// 16 cnt for every state
// 2^7 < 10 * 16 = 160 < 2^8
reg [7:0] state_cnt;


// 开始位检测
wire nedge;
reg cur_data;
reg last_data;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0) begin
		cur_data <= 1'b1;
		last_data <= 1'b1;
	end
	else begin
		cur_data <= data;
		last_data <= cur_data;
	end

assign nedge = (!cur_data) && last_data;

always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		rx_state <= 1'b0;
	else if (nedge)
		rx_state <= 1'b1;
	else if (state_cnt == 8'd156)
		rx_state <= 1'b0;
	else
		rx_state <= rx_state;


//
// 波特率计算和生成
// 序号baud    波特率bps    周期ns    分频计数值               50MHz系统时钟脉冲计数值   波特率16分频计数
// 0           9600         104167    104167/sys_clk_period    5208-1                    5208/16-1=324
// 1           19200        52083     52083/sys_clk_period     2604-1                    2604/16-1=161
// 2           38400        26041     26041/sys_clk_period     1302-1                    1302/16-1=80
// 3           57600        17361     17361/sys_clk_period     868-1                     868/16-1=53
// 4           115200       8680      8680/sys_clk_period      434-1                     434/16-1=26
//
reg [8:0] bps_target;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		bps_target <= 9'd324;
	else
		case(baud)
			3'd0:bps_target<=9'd324;
			3'd1:bps_target<=9'd161;
			3'd2:bps_target<=9'd80;
			3'd3:bps_target<=9'd53;
			3'd4:bps_target<=9'd26;
			default:bps_target<=9'd324;
		endcase

reg [8:0] bps_cnt;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		bps_cnt <= 9'd0;
	else if (rx_state) begin
		if (bps_cnt == bps_target)
			bps_cnt <= 9'd0;
		else
			bps_cnt <= bps_cnt + 1'b1;
	end
	else
		bps_cnt <= 9'd0;

always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		state_cnt <= 8'd0;
	else if (rx_state) begin
		if (bps_cnt == bps_target) begin
			if (state_cnt == 8'd156)
				state_cnt <= 8'd0;
			else
				state_cnt <= state_cnt + 1'b1;
		end
		else
			state_cnt <= state_cnt;
	end
	else
		state_cnt <= 8'd0;


// 状态迁移
reg [2:0] rx_start_r;
reg [2:0] rx_stop_r;
reg [2:0] rx_data_r [7:0];
always @(negedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0) begin
		rx_start_r <= 3'd0;
		rx_stop_r <= 3'd0;
		rx_data_r[0] <= 3'd0;
		rx_data_r[1] <= 3'd0;
		rx_data_r[2] <= 3'd0;
		rx_data_r[3] <= 3'd0;
		rx_data_r[4] <= 3'd0;
		rx_data_r[5] <= 3'd0;
		rx_data_r[6] <= 3'd0;
		rx_data_r[7] <= 3'd0;
	end
	else if (rx_state) begin
		if (bps_cnt == bps_target)
			case(state_cnt)
				0:
					begin
						rx_start_r <= 3'd0;
						rx_stop_r <= 3'd0;
						rx_data_r[0] <= 3'd0;
						rx_data_r[1] <= 3'd0;
						rx_data_r[2] <= 3'd0;
						rx_data_r[3] <= 3'd0;
						rx_data_r[4] <= 3'd0;
						rx_data_r[5] <= 3'd0;
						rx_data_r[6] <= 3'd0;
						rx_data_r[7] <= 3'd0;
					end
				6,7,8,9,10,11:rx_start_r<=rx_start_r+data;
				22,23,24,25,26,27:rx_data_r[0]<=rx_data_r[0]+data;
				38,39,40,41,42,43:rx_data_r[1]<=rx_data_r[1]+data;
				54,55,56,57,58,59:rx_data_r[2]<=rx_data_r[2]+data;
				70,71,72,73,74,75:rx_data_r[3]<=rx_data_r[3]+data;
				86,87,88,89,90,91:rx_data_r[4]<=rx_data_r[4]+data;
				102,103,104,105,106,107:rx_data_r[5]<=rx_data_r[5]+data;
				118,119,120,121,122,123:rx_data_r[6]<=rx_data_r[6]+data;
				134,135,136,137,138,139:rx_data_r[7]<=rx_data_r[7]+data;
				150,151,152,153,154,155:rx_stop_r<=rx_stop_r+data;
				default:
					begin
						rx_start_r <= rx_start_r;
						rx_stop_r <= rx_stop_r;
						rx_data_r[0] <= rx_data_r[0];
						rx_data_r[1] <= rx_data_r[1];
						rx_data_r[2] <= rx_data_r[2];
						rx_data_r[3] <= rx_data_r[3];
						rx_data_r[4] <= rx_data_r[4];
						rx_data_r[5] <= rx_data_r[5];
						rx_data_r[6] <= rx_data_r[6];
						rx_data_r[7] <= rx_data_r[7];
					end
			endcase
	end
	
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0) begin
		rx_data <= 8'd0;
		rx_done <= 1'b0;
	end
	else if (state_cnt == 8'd156) begin
			rx_data[0] <= rx_data_r[0][2];
			rx_data[1] <= rx_data_r[1][2];
			rx_data[2] <= rx_data_r[2][2];
			rx_data[3] <= rx_data_r[3][2];
			rx_data[4] <= rx_data_r[4][2];
			rx_data[5] <= rx_data_r[5][2];
			rx_data[6] <= rx_data_r[6][2];
			rx_data[7] <= rx_data_r[7][2];
			rx_done <= 1'b1;
	end
	else
		rx_done <= 1'b0;

endmodule

