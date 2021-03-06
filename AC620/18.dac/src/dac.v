/**
* @brief:
* ADC - tlv5618
*/
module dac(
	input wire clk_50mhz,
	input wire rst_n,
	input wire en,
	input wire [15:0] data,
	output wire dac_cs_n,
	output reg dac_state,
	output reg dac_sclk,
	output reg dac_din,
	output reg dac_done
);

parameter CNT_25MHZ = 1;

reg [1:0] cnt;
reg [5:0] state_cnt;

// state(begin and stop)
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		dac_state <= 1'b0;
	else if (en)
		dac_state <= 1'b1;
	else if (state_cnt == 6'd32 && cnt == CNT_25MHZ)
		dac_state <= 1'b0;
	else
		dac_state <= dac_state;
		
assign dac_cs_n = ~dac_state;

// 50MHz --> 25MHz
// 状态计数
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		cnt <= 2'd0;
	else if (dac_state) begin
		if (cnt == CNT_25MHZ)
			cnt <= 2'd0;
		else
			cnt <= cnt + 1'b1;
	end
	else
		cnt <= 2'd0;
		
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		state_cnt <= 6'd0;
	else if (dac_state) begin
		if (cnt == CNT_25MHZ) begin
			if (state_cnt == 6'd32)
				state_cnt <= 6'd0;
			else
				state_cnt <= state_cnt + 1'b1;
		end
		else
			state_cnt <= state_cnt;
	end
	else
		state_cnt <= 6'd0;

// 状态赋值
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0) begin
		dac_sclk <= 1'b0;
		dac_din <= 1'b1;
		dac_done <= 1'b0;
	end
	else if (dac_state) begin
		if (cnt == CNT_25MHZ)
			case(state_cnt)
				0:begin dac_sclk <= 1'b1;dac_din <= data[15];dac_done <= 1'b0;end
				1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31:begin dac_sclk <= 1'b0;end
				2:begin dac_sclk <= 1'b1;dac_din <= data[14];end
				4:begin dac_sclk <= 1'b1;dac_din <= data[13];end
				6:begin dac_sclk <= 1'b1;dac_din <= data[12];end
				8:begin dac_sclk <= 1'b1;dac_din <= data[11];end
				10:begin dac_sclk <= 1'b1;dac_din <= data[10];end
				12:begin dac_sclk <= 1'b1;dac_din <= data[9];end
				14:begin dac_sclk <= 1'b1;dac_din <= data[8];end
				16:begin dac_sclk <= 1'b1;dac_din <= data[7];end
				18:begin dac_sclk <= 1'b1;dac_din <= data[6];end
				20:begin dac_sclk <= 1'b1;dac_din <= data[5];end
				22:begin dac_sclk <= 1'b1;dac_din <= data[4];end
				24:begin dac_sclk <= 1'b1;dac_din <= data[3];end
				26:begin dac_sclk <= 1'b1;dac_din <= data[2];end
				28:begin dac_sclk <= 1'b1;dac_din <= data[1];end
				30:begin dac_sclk <= 1'b1;dac_din <= data[0];end
				32:begin dac_sclk <= 1'b0;dac_din <= 1'b1;dac_done <= 1'b1;end
				default:;
			endcase
	end
	else begin
		dac_din <= 1'b1;
		dac_sclk <= 1'b0;
		dac_done <= 1'b0;
	end

endmodule
