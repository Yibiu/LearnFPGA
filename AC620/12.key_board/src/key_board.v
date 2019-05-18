/**
* @brief:
* 矩阵键盘驱动设计。
* 为了让flag有效时value有效，将value先于flag一个周期输出，即添加READY0和READY1两个完成状态。
*/
module key_board(
	input wire clk_50mhz,
	input wire rst_n,
	input wire [3:0] rows,
	output reg [3:0] cols,
	output reg key_flag,
	output reg [3:0] key_value,
);

parameter IDEL = 8'b0000_0001;
parameter FILTER = 8'b0000_0010;
parameter SCAN_COL0 = 8'b0000_0100;
parameter SCAN_COL1 = 8'b0000_1000;
parameter SCAN_COL2 = 8'b0001_0000;
parameter SCAN_COL3 = 8'b0010_0000;
parameter READY0 = 8'b0100_0000;
parameter READY1 = 8'b1000_0000;


// 50MHz -> 12.5KHz
// 计数周期：4000-1
// 时钟反转周期：4000/2-1=1999
reg [10:0] clk_cnt;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		clk_cnt <= 11'd0;
	else if (clk_cnt == 11'd1999)
		clk_cnt <= 11'd0;
	else
		clk_cnt <= clk_cnt + 1'b1;

reg clk_12_5khz;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		clk_12_5khz <= 1'b0;
	else if (clk_cnt == 11'd1999)
		clk_12_5khz <= ~clk_12_5khz;


// 计时器20ms
// 12.5KHz = 80_000ns
// 20_000_000ns / 80_000ns = 250
reg en_cnt;
reg [7:0] cnt;
always @(posedge clk_12_5khz or negedge rst_n)
	if (rst_n == 1'b0)
		cnt <= 8'd0;
	else if (en_cnt)
		if (cnt == 8'd249)
			cnt <= 8'd0;
		else
			cnt <= cnt + 1'b1;
	else
		cnt <= 8'd0;

reg full_cnt;
always @(posedge clk_12_5khz or negedge rst_n)
	if (rst_n == 1'b0)
		full_cnt <= 1'b0;
	else if (en_cnt)
		if (cnt == 8'd249)
			full_cnt <= 1'b1;
	else
		full_cnt <= 1'b0;


// 状态迁移
reg state;
reg row_r;
reg col_r;
always @(posedge clk_12_5khz or negedge rst_n)
	if (rst_n == 1'b0) begin
		state <= IDEL;
		cols <= 4'b0000;
	end
	else
		case(state)
			IDEL:
				begin
					cols <= 4'b0000;
					if (rows != 4'b1111) begin
						state <= FILTER;
						en_cnt <= 1'b1;
					end
				end
			FILTER:
				if (full_cnt) begin
					en_cnt <= 1'b0;
					if (!(rows & 4'b1000))
						row_r <= 4'd0;
					else if (!(rows & 4'b0100))
						row_r <= 4'd1;
					else if (!(rows & 4'b0010))
						row_r <= 4'd2;
					else
						row_r <= 4'd3;
					cols <= 4'b0111;
					state <= SCAN_COL0;
				end
				else if (rows == 4'b1111)
					en_cnt <= 1'b0;
					state <= IDEL;
				end
			SCAN_COL0:
				if (rows != 4'b1111) begin
					col_r <= 4'd0;
					state <= READY0;
				end
				else begin
					cols <= 4'b1011:
					state <= SCAN_COL1;
				end
			SCAN_COL1:
				if (rows != 4'b1111) begin
					col_r <= 4'd1;
					state <= READY0;
				end
				else begin
					cols <= 4'b1101:
					state <= SCAN_COL2;
				end
			SCAN_COL2:
				if (rows != 4'b1111) begin
					col_r <= 4'd2;
					state <= READY0;
				end
				else begin
					cols <= 4'b1110:
					state <= SCAN_COL3;
				end
			SCAN_COL3:
				if (rows != 4'b1111) begin
					col_r <= 4'd3;
					state <= READY0;
				end
				else begin
					state <= IDEL;
				end
			READY0:state<=READY1;
			READY1:state<=IDEL;
			default:state<=IDEL;
		endcase
		
// 输出
always @(posedge clk_12_5khz or negedge rst_n)
	if (rst_n == 1'b0)
		key_value <= 4'd0;
	else if (state == READY0)
		key_value <= row_r * 4'd4 + col_r;
		
always @(posedge clk_12_5khz or negedge rst_n)
	if (rst_n == 1'b0)
		key_flag <= 1'b0;
	else if (state == READY1)
		key_flag <= 1'b1;
	else
		key_flag <= 1'b0;

endmodule

