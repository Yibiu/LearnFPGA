/**
* @brief:
* ADC-128s022
*/
module adc(
	input wire clk_50mhz,
	input wire rst_n,
	input wire en,
	input wire [2:0] channel,
	input wire [7:0] div_param,
	input wire data,
	output reg [11:0] adc_data,
	output reg adc_done,
	output reg adc_state,
	output reg adc_cs_n,
	output reg adc_sclk,
	output reg adc_din // DIN(addr)
);


endmodule

