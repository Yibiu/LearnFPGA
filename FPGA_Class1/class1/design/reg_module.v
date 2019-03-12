module reg_module(
	input wire clk,
	input wire rst_n,
	input wire [7:0] d, // 输入必须是wire
	output reg [7:0] q	// 输出可以是wire，也可以是reg
);

// 异步触发器
always @(posedge clk or negedge rst_n) // 沿触发一定都是用<=赋值
	if (rst_n == 1'b0)
		q <= 8'h00;
	else
		q <= d;

// 同步触发器
always @(posedge clk)
	if (rst_n == 1'b0)
		q <= 8'h00;
	else
		q <= d;
		
endmodule
