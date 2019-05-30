/**
* @brief:
* 74HC595串转并模块驱动,使得数码管位选和段选数据符合595工作时序。
* sh_clk为器件工作时钟，st_clk为刷新脉冲时钟。
*
* 12.5MHz: 80ns
* 80ns / 20ns = 4;
* 计数反转周期2.
*
* 并转串,将{sel, seg}以串口形式输出给74HC959。
*
* sel/seg --> 本模块 --> 74HC595 --> 数码管。
*/
module hc595_driver(
	input wire clk_50mhz,
	input wire rst_n,
	input wire en,
	input wire [15:0] data,
	output reg ds,
	output reg sh_clk,
	output reg st_clk
);

parameter CNT_12_5MHZ = 1;

// 工作时钟：50MHz -> 12.5 MHz
reg [1:0] cnt;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		cnt <= 2'd0;
	else if (en) begin
		if (cnt == CNT_12_5MHZ)
			cnt <= 2'd0;
		else
			cnt <= cnt + 1'b1;
	end
	else
		cnt <= 2'd0;

reg clk_12_5mhz;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		clk_12_5mhz <= 1'b0;
	else if (cnt == CNT_12_5MHZ)
		clk_12_5mhz <= ~clk_12_5mhz;
	else
		clk_12_5mhz <= clk_12_5mhz;


// 利用12.5Mhz进行计数，计数产生sh_clk和st_clk，并控制数据赋值
reg [4:0] cnt_edge;
always @(posedge clk_12_5mhz or negedge rst_n)
	if (rst_n == 1'b0)
		cnt_edge <= 5'd0;
	else if (cnt_edge == 5'd31)
		cnt_edge <= 5'd0;
	else
		cnt_edge <= cnt_edge + 1'b1;

always @(posedge clk_12_5mhz or negedge rst_n)
	if (rst_n == 1'b0) begin
		sh_clk <= 1'b0;
		st_clk <= 1'b0;
		ds <= 1'b0;
	end
	else
		case(cnt_edge)
			5'd0:begin sh_clk<=1'b0;st_clk<=1'b1;ds<=data[15];end
			5'd1:begin sh_clk<=1'b1;st_clk<=1'b0;end
			5'd2:begin sh_clk<=1'b0;ds<=data[14];end
			5'd3:begin sh_clk<=1'b1;end
			5'd4:begin sh_clk<=1'b0;ds<=data[13];end
			5'd5:begin sh_clk<=1'b1;end
			5'd6:begin sh_clk<=1'b0;ds<=data[12];end
			5'd7:begin sh_clk<=1'b1;end
			5'd8:begin sh_clk<=1'b0;ds<=data[11];end
			5'd9:begin sh_clk<=1'b1;end
			5'd10:begin sh_clk<=1'b0;ds<=data[10];end
			5'd11:begin sh_clk<=1'b1;end
			5'd12:begin sh_clk<=1'b0;ds<=data[9];end
			5'd13:begin sh_clk<=1'b1;end
			5'd14:begin sh_clk<=1'b0;ds<=data[8];end
			5'd15:begin sh_clk<=1'b1;end
			5'd16:begin sh_clk<=1'b0;ds<=data[7];end
			5'd17:begin sh_clk<=1'b1;end
			5'd18:begin sh_clk<=1'b0;ds<=data[6];end
			5'd19:begin sh_clk<=1'b1;end
			5'd20:begin sh_clk<=1'b0;ds<=data[5];end
			5'd21:begin sh_clk<=1'b1;end
			5'd22:begin sh_clk<=1'b0;ds<=data[4];end
			5'd23:begin sh_clk<=1'b1;end
			5'd24:begin sh_clk<=1'b0;ds<=data[3];end
			5'd25:begin sh_clk<=1'b1;end
			5'd26:begin sh_clk<=1'b0;ds<=data[2];end
			5'd27:begin sh_clk<=1'b1;end
			5'd28:begin sh_clk<=1'b0;ds<=data[1];end
			5'd29:begin sh_clk<=1'b1;end
			5'd30:begin sh_clk<=1'b0;ds<=data[0];end
			5'd31:begin sh_clk<=1'b1;end
			default:;
		endcase
		
endmodule
