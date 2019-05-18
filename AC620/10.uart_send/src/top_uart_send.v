/**
* @brief:
* 按键按下，ISSP中的数据通过串口发送。
*
* @brief:
* clk_50mhz --> PIN_E1
* rst_n --> PIN_M16
* key_en --> PIN_E15
* tx_data --> PIN_A6
* tx_done --> PIN_A2
*/
module top_uart_send(
	input wire clk_50mhz,
	input wire rst_n,
	input wire key_en,
	output wire tx_data,
	output wire tx_done
);

wire key_flag;
wire key_state;
key_filter key_filter_inst0(
	.clk_50mhz(clk_50mhz),
	.rst_n(rst_n),
	.key_in(key_en),
	.key_flag(key_flag),
	.key_state(key_state)
);

wire [7:0] data;
issp issp_inst0(
	.probe(),
	.source(data)
);

wire send_en;
assign send_en = key_flag && !key_state;
uart_send uart_send_inst0(
	.clk_50mhz(clk_50mhz),
	.rst_n(rst_n),
	.en(send_en),
	.baud(3'd0),
	.data(data),
	.tx_data(tx_data),
	.tx_done(tx_done)
);

endmodule
