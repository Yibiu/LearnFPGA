# 二选一多路选择器

[TOC]



## 一：理论

二选一多路选择器：sel为高时选择a；sel为低时选择b；out为输出。

![mux2](./mux2.jpg)





## 二：设计

`assign` 语句的使用。`assign`语句及时生效，物理特性表征的是一条连接导线。

```verilog
module mux2(
	input wire a,
	input wire b,
	input wire sel,
	output wire out
);

assign out = (sel ? a : b);

endmodule
```





## 三：测试

### 3.1 TestBench

测试需遍历所有可能情况：

| sel  | a    | b    | out期望输出 |
| ---- | ---- | ---- | ----------- |
| 0    | 0    | 0    | 0           |
| 0    | 0    | 1    | 0           |
| 0    | 1    | 0    | 1           |
| 0    | 1    | 1    | 1           |
| 1    | 0    | 0    | 0           |
| 1    | 0    | 1    | 1           |
| 1    | 1    | 0    | 0           |
| 1    | 1    | 1    | 1           |

testbench测试：

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

