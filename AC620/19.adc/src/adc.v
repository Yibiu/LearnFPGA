/**
* @brief:
* ADC-128S022
* SCLK - 0.8~3.2MHz
*/
module adc(
	input wire clk_50mhz,
	input wire rst_n,
	input wire en,
	input wire [2:0] channel,
	input wire [7:0] div_param,
	input wire data,
	output reg adc_state,
	output wire adc_cs_n,
	output reg adc_sclk,
	output reg adc_din, // addr
	output reg [11:0] adc_data,
	output reg adc_done
);

reg [5:0] state_cnt;

// State(start/stop)
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		adc_state <= 1'b0;
	else if (en)
		adc_state <= 1'b1;
	else if (state_cnt == 6'd32)
		adc_state <= 1'b0;
	else
		adc_state <= adc_state;
		
assign adc_cs_n = ~adc_state;

// 50MHz --> 50MHz / div_param
// 状态计数
reg [7:0] cnt;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		cnt <= 8'd0;
	else if (adc_state) begin
		if (cnt == (div_param - 1'b1))
			cnt <= 8'd0;
		else
			cnt <= cnt + 1'b1;
	end
	else
		cnt <= 8'd0;
		
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		state_cnt <= 6'd0;
	else if (adc_state) begin
		if (cnt == (div_param - 1'b1)) begin
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
		
// 状态迁移
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0) begin
		adc_sclk <= 1'b1;
		adc_din <= 1'b1;
		adc_data <= 12'd0;
		adc_done <= 1'b0;
	end
	else if (adc_state)
		case(state_cnt)
			6'd0:begin adc_sclk<=1'b0; adc_din<=1'b0;adc_data<=12'd0;adc_done<=1'b0;end
			6'd1:begin adc_sclk<=1'b1;end
			6'd2:begin adc_sclk<=1'b0;end
			6'd3:begin adc_sclk<=1'b1;end
			6'd4:begin adc_sclk<=1'b0;adc_din<=channel[2];end
			6'd5:begin adc_sclk<=1'b1;end
			6'd6:begin adc_sclk<=1'b0;adc_din<=channel[1];end
			6'd7:begin adc_sclk<=1'b1;end
			6'd8:begin adc_sclk<= 1'b0; adc_din<=channel[0];end
			6'd9,6'd10,6'd12,6'd14,6'd16,6'd18,6'd20,6'd22,6'd24,6'd26,6'd28,6'd30:
				begin adc_sclk <= 1'b1;adc_data <= {adc_data[10:0], data};end
			6'd11,6'd13,6'd15,6'd17,6'd19,6'd21,6'd23,6'd25,6'd27,6'd29,6'd31:
				begin adc_sclk <= 1'b0;end
			6'd32:begin adc_sclk<=1'b1;adc_done<=1'b1;end
			default:;
		endcase
	else begin
		adc_sclk <= 1'b1;
		adc_din <= 1'b1;
		adc_data <= 12'd0;
		adc_done <= 1'b0;
	end

endmodule
