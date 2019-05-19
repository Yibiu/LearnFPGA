/**
* @brief:
* TFT显示屏驱动，按行和场扫描。
*
* 5寸屏：800x480
* 扫描时钟33Mhz,总区域1056x524
* 33_000_000 Hz / (1056 x 524)= 59.64 Hz
*/
module tft_driver(
	input wire clk_33mhz,
	input wire rst_n,
	input wire [15:0] rgb,
	
	output wire tft_clk,				// TFT时钟
	output wire [11:0] tft_hcount,// TFT行扫描计数(针对有效区域)
	output wire [11:0] tft_vcount,// TFT场扫描计数(针对有效区域)
	output wire [15:0] tft_rgb, 	// TFT数据输出
	output wire tft_hs,				// TFT行扫描同步
	output wire tft_vs,				// TFT场扫描同步
	output wire tft_de,				// TFT有效区域标志
	output wire tft_owm				// TFT复位
);


localparam
	// 行扫描参数
	hs_end = 10'd1,
	hdat_begin = 10'd46,
	hdat_end = 10'd846,
	h_end = 12'd1056,
	// 场扫描参数
	vs_end = 10'd1,
	vdat_begin = 10'd24,
	vdat_end = 10'd504,
	v_end = 10'd524;


// TFT时钟
assign tft_clk = clk_33mhz;


// TFT复位
assign tft_owm = rst_n;


// TFT行扫描
reg [11:0] tft_hcount_r;
always @(posedge clk_33mhz or negedge rst_n)
	if (rst_n == 1'b0)
		tft_hcount_r <= 12'd0;
	else if (tft_hcount_r == h_end)
		tft_hcount_r <= 12'd0;
	else
		tft_hcount_r <= tft_hcount_r + 12'd1;


// TFT场扫描
reg [11:0] tft_vcount_r;
always @(posedge clk_33mhz or negedge rst_n)
	if (rst_n == 1'b0)
		tft_vcount_r <= 12'd0;
	else if (tft_hcount_r == h_end) begin
		if (tft_vcount_r == v_end)
			tft_vcount_r <= 12'd0;
		else
			tft_vcount_r <= tft_vcount_r + 12'd1;
	end


// 扫描各区域划分，及数据赋值
assign tft_hcount = tft_de ? (tft_hcount_r - hdat_begin) : 12'd0;
assign tft_vcount = tft_de ? (tft_vcount_r - vdat_begin) : 12'd0;

assign tft_hs = (tft_hcount_r > hs_end);
assign tft_vs = (tft_vcount_r > vs_end);
assign tft_de = ((tft_hcount_r >= hdat_begin) && (tft_hcount_r < hdat_end))
				&& ((tft_vcount_r >= vdat_begin) && (tft_vcount_r < vdat_end));

assign tft_rgb = tft_de ? rgb : 16'h0000;


endmodule
