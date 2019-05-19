/**
* @brief:
* TFT测试模块。测试TFT_Driver。
*
* 显示像素块：(有效区域800x480)
*  __________________________
* |    r0c0    |    r0c0     |
* |------------|-------------|
* |    r1c0    |    r1c1     |
* |------------|-------------|
* |    r2c0    |    r2c1     |
* |------------|-------------|
* |____r3c0____|____r3c1_____|
*
*
* @resources:
* clk_50mhz --> PIN_E1
* rst_n --> PIN_E16
*/
module tft(
	input wire clk_50mhz,
	input wire rst_n,
	
	output wire tft_clk,
	output wire [15:0] tft_rgb,
	output wire tft_hs,
	output wire tft_vs,
	output wire tft_de,
	output wire tft_owm
);


reg [15:0] dis_data;
wire [11:0] hcount;
wire [11:0] vcount;
wire clk_33mhz;


// 颜色定义
localparam 
	BLACK = 16'h0000,
	BLUE = 16'h001F,
	RED = 16'hF800,
	PURPPLE	= 16'hF81F,
	GREEN = 16'h07E0,
	CYAN = 16'h07FF,
	YELLOW = 16'hFFE0,
	WHITE = 16'hFFFF;

// 像素块颜色定义
localparam
	r0c0 = BLACK,
	r0c1 = BLUE,
	r1c0 = RED,
	r1c1 = PURPPLE,
	r2c0 = GREEN,
	r2c1 = CYAN,
	r3c0 = YELLOW,
	r3c1 = WHITE;


// PLL例化
tft_pll tft_pll_inst0(
	.inclk0(clk_50mhz),
	.c0(clk_33mhz)
);

// TFTDriver例化
tft_driver tft_driver_inst0(
	.clk_33mhz(clk_33mhz),
	.rst_n(rst_n),
	.rgb(dis_data),
	.tft_clk(tft_clk),
	.tft_hcount(hcount),
	.tft_vcount(vcount),
	.tft_rgb(tft_rgb),
	.tft_hs(tft_hs),
	.tft_vs(tft_vs),
	.tft_de(tft_de),
	.tft_owm(tft_owm)
);


// 显示数据赋值
wire r0_act = vcount >= 0 && vcount < 120;
wire r1_act = vcount >= 120 && vcount < 240;
wire r2_act = vcount >= 240 && vcount < 360;
wire r3_act = vcount >= 360 && vcount < 480;
wire c0_act = hcount >= 0 && hcount < 400;
wire c1_act = hcount >= 400 && hcount < 800;

wire r0c0_act = r0_act && c0_act;
wire r0c1_act = r0_act && c1_act;
wire r1c0_act = r1_act && c0_act;
wire r1c1_act = r1_act && c1_act;
wire r2c0_act = r2_act && c0_act;
wire r2c1_act = r2_act && c1_act;
wire r3c0_act = r3_act && c0_act;
wire r3c1_act = r3_act && c1_act;

always @(*)
	case({r3c1_act, r3c0_act, r2c1_act, r2c0_act,
			r1c1_act, r1c0_act, r0c1_act, r0c0_act})
		8'b0000_0001:dis_data = r0c0;
		8'b0000_0010:dis_data = r0c1;
		8'b0000_0100:dis_data = r1c0;
		8'b0000_1000:dis_data = r1c1;
		8'b0001_0000:dis_data = r2c0;
		8'b0010_0000:dis_data = r2c1;
		8'b0100_0000:dis_data = r3c0;
		8'b1000_0000:dis_data = r3c1;
		default:dis_data = r0c0;
	endcase

endmodule
