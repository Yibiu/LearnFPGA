/**
* @brief:
* IIC
* Support single byte/multi bytes
* 400KHz <--> 2_500ns
* 2_500ns / 20ns = 125
*
* 将scl时钟4分频。
* Task总是提前一次计数结束。
*/
module iic(
	input wire clk_50mhz,
	input wire rst_n,
	input wire [2:0] dev_addr,
	
	input wire [1:0] addr_num,
	input wire [15:0] addr_addr,
	input wire wr_en,
	input wire [5:0] wr_num,
	input wire [7:0] wr_data,
	output wire wr_update, // update data
	
	input wire rd_en,
	input wire [5:0] rd_num,
	output wire [7:0] rd_data,
	output wire rd_update, // data available
	
	output wire iic_scl,
	inout wire iic_sda,
	output reg [1:0] done // 2'b00: normal; 2'b01: done without error; 2'b11: done with error
);


parameter CNT_400KHZ = 125;


//
// Write:
// 1. STRAT + CTRL_WRITE + ADDR0 + WRITE_DATA + STOP
// 2. START + CTRL_WRITE + ADDR1 + ADDR0 + WRITE_DATA + STOP
// 
// Read:
// 1. START + CTRL_READ + ADDR0 + CTRL_READ + READ_DATA + STOP
// 2. START + CTRL_READ + ADDR1 + ADDR0 + CTRL_READ + READ_DATA + STOP
//
parameter IDEL = 9'b0_0000_0001;
parameter START = 9'b0_0000_0010;
parameter CTRL_WRITE = 9'b0_0000_0100;
parameter CTRL_READ = 9'b0_0000_1000;
parameter ADDR0 = 9'b0_0001_0000;
parameter ADDR1 = 9'b0_0010_0000;
parameter WRITE_DATA = 9'b0_0100_0000;
parameter READ_DATA = 9'b0_1000_0000;
parameter STOP = 9'b1_0000_0000;

reg [8:0] state;

parameter CNT_TARGET_START = 3;
parameter CNT_TARGET_CTRL_WRITE = 36;
parameter CNT_TARGET_CTRL_READ = 36;
parameter CNT_TARGET_ADDR0 = 36;
parameter CNT_TARGET_ADDR1 = 36;
parameter CNT_TARGET_WRITE_DATA = 36;
parameter CNT_TARGET_READ_DATA = 36;
parameter CNT_TARGET_STOP = 3;

reg [5:0] state_cnt_target;
reg [5:0] state_cnt;
reg [7:0] state_data;
reg ack;


// SCL middle and edge cnt
// flag high in (scl / 4)
reg [4:0] scl_cnt;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		scl_cnt <= 5'd0;
	else if (state != IDEL) begin
		if (scl_cnt == ((CNT_400KHZ >> 2) - 1))
			scl_cnt <= 5'd0;
		else
			scl_cnt <= scl_cnt + 1'b1;
	end
	else
		scl_cnt <= 5'd0;
		
reg scl_flag;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		scl_flag <= 1'b0;
	else if (scl_cnt == ((CNT_400KHZ >> 2) - 1))
		scl_flag <= 1'b1;
	else
		scl_flag <= 1'b0;


// Task - Start
task task_start;
	begin
		case(state_cnt)
			0:begin iic_scl<=1'b1;iic_sda<=1'b1;end
			1:begin iic_scl<=1'b1;iic_sda<=1'b0;end
			2:begin iic_scl<=1'b0;iic_sda<=1'b0;end
			default:;
		endcase
		state_cnt <= state_cnt + 1'b1;
	end
endtask

// Task - Write
task task_write_byte;
	begin
		case(state_cnt)
			// IIC_SDA
			0:begin iic_scl<=1'b0;iic_sda<=state_data[7];end
			4:begin iic_sda<=state_data[6];end
			8:begin iic_sda<=state_data[5];end
			12:begin iic_sda<=state_data[4];end
			16:begin iic_sda<=state_data[3];end
			20:begin iic_sda<=state_data[2];end
			24:begin iic_sda<=state_data[1];end
			28:begin iic_sda<=state_data[0];end
			34:begin ack<=iic_sda;end
			// IIC_SCL
			1,5,9,13,17,21,25,29,33:begin iic_scl<=1'b1;end
+	
		3,7,11,15,19,23,27,31,35:begin iic_scl<=1'b0;end
			default:;
		endcase
		state_cnt <= state_cnt + 1'b1;
	end
endtask

// Task - Read
task task_read_byte;
	begin
		case(state_cnt)
			// IIC_SDA
			2:begin state_data[0]<=iic_sda;end
			6:begin state_data[1]<=iic_sda;end
			10:begin state_data[2]<=iic_sda;end
			14:begin state_data[3]<=iic_sda;end
			18:begin state_data[4]<=iic_sda;end
			22:begin state_data[5]<=iic_sda;end
			26:begin state_data[6]<=iic_sda;end
			30:begin state_data[7]<=iic_sda;end
			34:begin ack<=iic_sda;end
			// IIC-SCL
			0:begin iic_scl<=1'b0;end
			1,5,9,13,17,21,25,29,33:begin iic_scl<=1'b1;end
			3,7,11,15,19,23,27,31,35:begin iic_scl<=1'b0;end
			default:;
		endcase
		state_cnt <= state_cnt + 1'b1;
	end
endtask

// Task - Stop
task task_stop;
	begin
		case(state_cnt)
			0:begin iic_scl<=1'b0;iic_sda<=1'b0;end
			1:begin iic_scl<=1'b1;iic_sda<=1'b0;end
			2:begin iic_scl<=1'b1;iic_sda<=1'b1;end
			default:;
		endcase
		state_cnt <= state_cnt + 1'b1;
	end
endtask


// 状态迁移
reg rdwr_r;
reg ctrl_r;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0) begin
		state <= IDEL;
		state_cnt_target <= 0;
		state_cnt <= 1'b0;
		state_data <= 8'd0;
		rdwr_r <= 1'b0;
		ctrl_r <= 1'b0;
	end
	else begin
		case(state)
			IDEL:
				begin
					if (wr_en) begin
						state_cnt_target <= CNT_TARGET_START;
						state_cnt <= 1'b0;
						state <= START;
						rdwr_r <= 1'b1;
					end
					else if (rd_en) begin
						state_cnt_target <= CNT_TARGET_START;
						state_cnt <= 1'b0;
						state <= START;
						rdwr_r <= 1'b0;
					end
					ctrl_r <= 1'b0;
				end
			START:
				begin
					if (scl_flag) begin
						if (state_cnt == state_cnt_target - 1) begin
							if (rdwr_r) begin
								state_cnt_target <= CNT_TARGET_CTRL_WRITE;
								state_cnt <= 1'b0;
								state_data <= {4'b1010,dev_addr,1'b0};
								state <= CTRL_WRITE;
							end
							else begin
								state_cnt_target <= CNT_TARGET_CTRL_READ;
								state_cnt <= 1'b0;
								state_data <= {4'b1010,dev_addr,1'b1};
								state <= CTRL_READ;
							end
						end
						task_start;
					end
				end
			CTRL_WRITE:
				begin
					if (scl_flag) begin
						if (state_cnt == state_cnt_target - 1) begin
							if (addr_num == 2'd2) begin
								state_cnt_target <= CNT_TARGET_ADDR1;
								state_cnt <= 1'b0;
								state_data <= addr_addr[15:8];
								state <= ADDR1;
							end
							else begin
								state_cnt_target <= CNT_TARGET_ADDR0;
								state_cnt <= 1'b0;
								state_data <= addr_addr[7:0];
								state <= ADDR0;
							end
						end
						task_write_byte;
					end
				end
			CTRL_READ:
				begin
					if (scl_flag) begin
						if (state_cnt == state_cnt_target - 1) begin
							if (addr_num == 2'd2) begin
								state_cnt_target <= CNT_TARGET_ADDR1;
								state_cnt <= 1'b0;
								state_data <= addr_addr[15:8];
								state <= ADDR1;
							end
							else begin
								state_cnt_target <= CNT_TARGET_ADDR0;
								state_cnt <= 1'b0;
								state_data <= addr_addr[7:0];
								state <= ADDR0;
							end
							ctrl_r <= ~ctrl_r;
						end
						task_read_byte;
					end
				end
			ADDR0:
				begin
				end
			ADDR1:
				begin
				end
			WRITE_DATA:
				begin
				end
			READ_DATA:
				begin
				end
			STOP:
				begin
				end
			default:;
		endcase
	end

endmodule

