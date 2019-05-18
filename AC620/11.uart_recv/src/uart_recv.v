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
	output reg [7:0] rx_data,
	output reg rx_done
);

parameter IDEL = 11'b000_0000_0001;
parameter START = 11'b000_0000_0010;
parameter DATA0 = 11'b000_0000_0100;
parameter DATA1 = 11'b000_0000_1000;
parameter DATA2 = 11'b000_0001_0000;
parameter DATA3 = 11'b000_0010_0000;
parameter DATA4 = 11'b000_0100_0000;
parameter DATA5 = 11'b000_1000_0000;
parameter DATA6 = 11'b001_0000_0000;
parameter DATA7 = 11'b010_0000_0000;
parameter STOP = 11'b100_0000_0000;

reg [10:0] state;


//
// 开始位检测
// 只有在IDEL状态才开始检测
// pluse为Start脉冲
//
wire pluse;
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

assign pluse = (!cur_data) & last_data;

always @(*)
	if (pluse && state == IDEL)
		state <= START;


//
// 波特率计算和生成
// 序号baud    波特率bps    周期ns    分频计数值               50MHz系统时钟脉冲计数值   50MHz系统时钟转bps_clk计数值
// 0           9600         104167    104167/sys_clk_period    5208-1                    5208/2-1=2603
// 1           19200        52083     52083/sys_clk_period     2604-1                    2604/2-1=1301
// 2           38400        26041     26041/sys_clk_period     1302-1                    1302/2-1=650
// 3           57600        17361     17361/sys_clk_period     868-1                     868/2-1=433
// 4           115200       8680      8680/sys_clk_period      434-1                     434/2-1=216
//
reg [11:0] bps_target;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		bps_target <= 12'd2603;
	else
		case(baud)
			3'd0:bps_target<=12'd2603;
			3'd1:bps_target<=12'd1301;
			3'd2:bps_target<=12'd650;
			3'd3:bps_target<=12'd433;
			3'd4:bps_target<=12'd216;
			default:bps_target<=12'd2603;
		endcase

reg [11:0] bps_cnt;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		bps_cnt <= 12'd0;
	else if (en && state != IDEL) begin
		if (bps_cnt == bps_target)
			bps_cnt <= 12'd0;
		else
			bps_cnt <= bps_cnt + 1'b1;
	end
	else
		bps_cnt <= 16'd0;

reg bps_clk;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		bps_clk <= 1'b0;
	else if (en && state != IDEL)
		if (bps_cnt == bps_target)
			bps_clk <= ~bps_clk;
	else
		bps_clk <= 1'b0;


// 状态变迁
always @(negedge bps_clk or negedge rst_n)
	if (rst_n == 1'b0)
		state <= IDEL;
	else
		case(state)
			START:state<=DATA0;
			DATA0:state<=DATA1;
			DATA1:state<=DATA2;
			DATA2:state<=DATA3;
			DATA3:state<=DATA4;
			DATA4:state<=DATA5;
			DATA5:state<=DATA6;
			DATA6:state<=DATA7;
			DATA7:state<=STOP;
			STOP:state<=IDEL;
			default:state<=IDEL;
		endcase

// 输出
always @(posedge bps_clk or negedge rst_n)
	if (rst_n == 1'b0)
		rx_data <= 8'b1111_1111;
	else
		case(state)
			START:rx_data<=8'b1111_1111;
			DATA0:rx_data[0]<=data;
			DATA1:rx_data[1]<=data;
			DATA2:rx_data[2]<=data;
			DATA3:rx_data[3]<=data;
			DATA4:rx_data[4]<=data;
			DATA5:rx_data[5]<=data;
			DATA6:rx_data[6]<=data;
			DATA7:rx_data[7]<=data;
			STOP:rx_data<=rx_data;
			default:rx_data<=rx_data;
		endcase

always @(posedge bps_clk or negedge rst_n)
	if (rst_n == 1'b0)
		rx_done <= 1'b0;
	else if (state == STOP)
		rx_done <= 1'b1;
	else
		rx_done <= 1'b0;

endmodule

