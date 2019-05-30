# 8位7段数码管驱动

[TOC]



## 一：理论

### 1.1 动态扫描数码管

共阳数码管，码值：

| 显示   | a    | b    | c    | d    | e    | f    | g    | h    | 段码    |
| ---- | ---- | ---- | ---- | ---- | ---- | :--- | ---- | ---- | ----- |
| 0    | 0    | 0    | 0    | 0    | 0    | 0    | 1    | 1    | 8'hc0 |
| 1    | 1    | 0    | 0    | 1    | 1    | 1    | 1    | 1    | 8'hf9 |
| 2    | 0    | 0    | 1    | 0    | 0    | 1    | 0    | 1    | 8'ha4 |
| 3    | 0    | 0    | 0    | 0    | 1    | 1    | 0    | 1    | 8'hb0 |
| 4    | 1    | 0    | 0    | 1    | 1    | 0    | 0    | 1    | 8'h99 |
| 5    | 0    | 1    | 0    | 0    | 1    | 0    | 0    | 1    | 8'h92 |
| 6    | 0    | 1    | 0    | 0    | 0    | 0    | 0    | 1    | 8'h82 |
| 7    | 0    | 0    | 0    | 1    | 1    | 1    | 1    | 1    | 8'hf8 |
| 8    | 0    | 0    | 0    | 0    | 0    | 0    | 0    | 1    | 8'h80 |
| 9    | 0    | 0    | 0    | 0    | 1    | 0    | 0    | 1    | 8'h90 |
| a    | 0    | 0    | 0    | 1    | 0    | 0    | 0    | 1    | 8'h88 |
| b    | 1    | 1    | 0    | 0    | 0    | 0    | 0    | 1    | 8'h83 |
| c    | 0    | 1    | 1    | 0    | 0    | 0    | 1    | 1    | 8'hc6 |
| d    | 1    | 0    | 0    | 0    | 0    | 1    | 0    | 1    | 8'ha1 |
| e    | 0    | 1    | 1    | 0    | 0    | 0    | 0    | 1    | 8'h86 |
| f    | 0    | 1    | 1    | 1    | 0    | 0    | 0    | 1    | 8'h8c |

数码管使用动态扫描显示，扫描频率1KHz，即每1ms切换到下一个数码管。数码管由：**位选sel+段选seg** 控制，位选选择当前显示的数码管，段选为要显示内容的码值。

```verilog
1ms = 1_000_000ns
1_000_000ns / 20ns = 50_000
2^15 < 50_000 < 2^16
```

模块：

![led_driver](./led_driver.jpg)

### 1.2 74HC595串转并

由于直接驱动数码管IO占用较多，故采用串转并模块间接驱动。采用的模块为74HC595。工作时序：

![74hc595_time](./74hc595_time.png)

SHCP上升沿时数据进入移位寄存器；STCP上升沿时数据从移位寄存器进入数据存储寄存器。实际使用时，STCP通常置低，SHCP上升沿时依次更新数据，数据更新完毕后STCP置高，在STCP的上升沿更新74hc595数据寄存器的数据：

![74hc595](./74hc595.bmp)

工作频率选择 **12.5MHz** ：

```verilog
12.5MHz --> 80ns
80ns / 20ns = 4
2^2 <= 4 < 2^3
```

模块：

![74hc595](./74hc595.jpg)

采用两个74HC595级联方式驱动8位7段数码管，低位输出位选sel，高位输出段选seg；级联时候DS为16位数据输入，高8位自动移入第二个74HC595：

![sel_seg](./sel_seg.png)







## 二：设计

### 2.1 数码管驱动

数码管动态扫描频率1KHz，计数值为50_000；故生成扫描时钟的反转周期为1/2计数值，即25_000。

```verilog
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
	else if (en) begin
		if (cnt == CNT_1KHZ)
			clk_1khz <= ~clk_1khz;
	end
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
		default:;
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
		default:;
	endcase
	
endmodule
```

- 首先生成数码管工作时钟clk_1khz，然后根据工作时钟操作；
- sel变化的同时seg产生变化；如果seg的语句块敏感列表写的是clk_1khz，则seg变化会滞后一个时钟周期。

### 2.2 74HC595驱动

74HC595工作频率为12.5MHz，计数值4；故生成74HC595工作时钟反转周期为1/2计数值，即2。

```verilog
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
```

- 首先生成74HC595工作时钟clk_12_5mhz，然后根据时钟工作；
- 状态迁移的敏感列表为clk_12_5mhz，因此会较cnt_edge的变化滞后一个时钟周期；但由于数据一直连续传输，因此并无太大影响；
- st_clk应该在传输完成时置高，程序中为了简化将置高提到传输刚开始时，同步的其实是上一次的数据传输；由于数据一直连续传输，因此并无太大影响。





## 三：测试

### 3.1 TestBench

guiguhgygo

```verilog
`timescale 1ns/1ns
 

module tb_mux2(
);

reg tb_a;
reg tb_b;
reg tb_sel;
wire tb_out;

// mux2例化
mux2 mux2_inst0(
	.a(tb_a),
	.b(tb_b),
	.sel(tb_sel),
	.out(tb_out)
);

// 初始化
initial begin
	tb_sel = 0;tb_a = 0;tb_b = 0;
	#100
	tb_sel = 0;tb_a = 0;tb_b = 1;
	#100
	tb_sel = 0;tb_a = 1;tb_b = 0;
	#100
	tb_sel = 0;tb_a = 1;tb_b = 1;
	#100
	tb_sel = 1;tb_a = 0;tb_b = 0;
	#100
	tb_sel = 1;tb_a = 0;tb_b = 1;
	#100
	tb_sel = 1;tb_a = 1;tb_b = 0;
	#100
	tb_sel = 1;tb_a = 1;tb_b = 1;
	#100

	$stop;
end

endmodule
```

### 3.2 波形





## 四：验证

基于AC620平台。

### 4.1 端口

输入(按键)+输出(LED)

```verilog
a	-->	key0(PIN_M16)
b	-->	key1(PIN_E15)
sel	-->	key2(PIN_E16)
out	-->	led0(PIN_A2)

IO Standard: 3.3V-LVTTL
```

### 4.2 结果

运行正确。

