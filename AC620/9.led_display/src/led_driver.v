/**
* @brief:
* 8位数码管驱动。
* 内部自动循环扫描，动态显示数码管内容。
*
* 数码管扫描频率：1KHz：1ms
* 1_000_000ns / 20ns = 50_000.
* 产生1KHz的反转计数值为50_000 / 2 = 25_000.
*/
module led_driver(
	input wire clk_50mhz,
	input wire rst_n,
	input wire en,
	input wire [31:0] dis_data,
	output wire [7:0] sel,
	output reg [7:0] seg
);

parameter CNT_1KHZ = 24_999;

// 时钟模块：50Mhz -> 1KHz
reg [14:0] cnt;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		cnt <= 15'd0;
	else if (en) begin
		if (cnt == CNT_1KHZ)
			cnt <= 15'd0;
		else
			cnt <= cnt + 1'b1;
	end
	else
		cnt <= 15'd0;

reg clk_1khz;
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		clk_1khz <= 1'b0;
	else if (en)
		if (cnt == CNT_1KHZ)
			clk_1khz <= ~clk_1khz;
	else
		clk_1khz <= 1'b0;


// 移位寄存器模块
// 根据1KHz时钟移位循环选择数码管，这是动态显示的激励源
reg [7:0] sel_r;
always @(posedge clk_1khz or negedge rst_n)
	if (rst_n == 1'b0)
		sel_r <= 8'b0000_0001;
	else if (sel_r == 8'b1000_0000)
		sel_r <= 8'b0000_0001;
	else
		sel_r <= sel_r << 1;
		
assign sel = en ? sel_r : 8'b0000_0000;


// 数码管显示字符选择(seg_data)
// 从[31:0]的dis_data中选择当前sel对应的字符
// seg在sel改变时立即改变，最好是assign方式，这里使用always方式达到相同效果。
reg [3:0] seg_data;
always @(*)
	case(sel_r)
		8'b0000_0001:seg_data = dis_data[3:0];
		8'b0000_0010:seg_data = dis_data[7:4];
		8'b0000_0100:seg_data = dis_data[11:8];
		8'b0000_1000:seg_data = dis_data[15:12];
		8'b0001_0000:seg_data = dis_data[19:16];
		8'b0010_0000:seg_data = dis_data[23:20];
		8'b0100_0000:seg_data = dis_data[27:24];
		8'b1000_0000:seg_data = dis_data[31:28];
		default:seg_data = 4'b0000;
	endcase

// BCD码到数码管显示码译码
// 同样，译码希望是及时的，最好使用assign，这里使用always达到相同效果。
// 第一位是小数点，保留(1)。
always @(*)
	case(seg_data)
		4'b0000:seg = 8'b11000_000; // 0
		4'b0001:seg = 8'b11111_001; // 1
		4'b0010:seg = 8'b10100_100; // 2
		4'b0011:seg = 8'b10110_000; // 3
		4'b0100:seg = 8'b10011_001; // 4
		4'b0101:seg = 8'b10010_010; // 5
		4'b0110:seg = 8'b10000_010; // 6
		4'b0111:seg = 8'b11111_000; // 7
		4'b1000:seg = 8'b10000_000; // 8
		4'b1001:seg = 8'b10010_000; // 9
		4'b1010:seg = 8'b10001_000; // A
		4'b1011:seg = 8'b10000_011; // B
		4'b1100:seg = 8'b11000_110; // C
		4'b1101:seg = 8'b10100_001; // D
		4'b1110:seg = 8'b10000_110; // E
		4'b1111:seg = 8'b10001_110; // F
	endcase
	
endmodule
