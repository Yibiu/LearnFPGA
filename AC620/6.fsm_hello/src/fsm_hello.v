/**
* @brief:
* Hello序列检测器，FSM状态机
*/
module fsm_hello(
	input wire clk_50mhz,
	input wire rst_n,
	input wire [7:0] data,
	output reg led
);

parameter BYTE_H = 5'b0_0001;
parameter BYTE_e = 5'b0_0010;
parameter BYTE_la = 5'b0_0100;
parameter BYTE_lb = 5'b0_1000;
parameter BYTE_o = 5'b1_0000;

reg [4:0] state;

// 状态机迁移
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		state <= BYTE_H;
	else
		case(state)
			BYTE_H:
				if (data == "H")
					state <= BYTE_e;
				else
					state <= BYTE_H;
			BYTE_e:
				if (data == "e")
					state <= BYTE_la;
				else
					state <= BYTE_H;
			BYTE_la:
				if (data == "l")
					state <= BYTE_lb;
				else
					state <= BYTE_H;
			BYTE_lb:
				if (data == "l")
					state <= BYTE_o;
				else
					state <= BYTE_H;
			BYTE_o:
				if (data == "o")
					state <= BYTE_H;
				else
					state <= BYTE_H;
			default:state <= BYTE_H;
		endcase

// 输出
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		led <= 1'b0;
	else if (state == BYTE_o && data == "o")
		led <= ~led;
	else
		led <= led;

endmodule
