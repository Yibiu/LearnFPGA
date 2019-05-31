# UART发送模块

[TOC]



## 一：理论

UART（通用异步收发传输器）发送模块。UART为异步收发传输器，在发送数据时将并行数据转换为串行数据传输；在接收数据时，将串行数据转换为并行数据；这样可以节省IO口的使用且可以实现全双工传输和接收。常见接口有RS232、RS449、RS423、RS422和RS485等。由传输速度可以分为1200、2400、9600、19200、115200等波特率，波特率通常可以由时钟分频获得：

![baud_cnt](./baud_cnt.bmp)

传输时序：起始位(1) + 数据位(8) + 校验位(0/1) + 停止位(1/1.5/2)。常用时序为 **8N1** ，即：8数据位、无奇偶校验、一个停止位：

![baud_time](baud_time.bmp)

FPGA设计思路为：由 `en` 标识一次数据传输的开始，并使用 `state_cnt` 进行状态计数和变换，归根结底其实是 **线性序列机** 的设计方式，后续还有很多设计也是采用类似方法。详细时序：

![time](./time.bmp)





## 二：设计

设计针对发送的详细时序：首先en接收到高脉冲，则标识传输开始，置tx_state为高，tx_state标识整个传输过程；之后开启波特率计数，当波特率计数满时state_cnt进行状态切换，同时根据state_cnt的状态值对tx赋值。

```verilog
//
```

需要关注的有以下几个地方：

- 起始：起始时en先为高，下一个时钟上升沿时传输过程标识tx_state置高；再下一个时钟时开始波特率计数和tx赋值。

  ![start](./start.bmp)

- 中间过程：state_cnt变化之后下一个时钟tx的值才变化，基本无影响：

  ![middle](./media.bmp)

- 结束：结束发生在state_cnt计数由9跳变为0时；同时置传输标识tx_state为低表示传输过程结束，置tx_done为高标识一次传输结束；在下一个时钟上升沿时，由于tx_state已经为低，故tx恢复初始高电平状态，tx_done也恢复低电平；至此，一个完整传输过程结束。

  ![stop](./stop.bmp)

- 连续传输：对于连续传输，一般监测posedge tx_done，此时en置高开始新一轮传输。由上述分析可知程序可以正常运行。





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

