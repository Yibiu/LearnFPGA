/**
* @brief:
* BCD码：0~9 -> 0000~1001
*/
module bcd_counter(
	input wire clk_50mhz,
	input wire rst_n,
	input wire cin,
	output reg cout,
	output reg [3:0] q
);

// 计数器
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		q <= 4'd0;
	else if (cin == 1'b1) begin
		if (q == 4'd9)
			q <= 4'd0;
		else
			q <= q + 1'b1;
	end
	
// 进位信号
always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		cout <= 1'b0;
	else if (cin == 1'b1 && q == 4'd9)
		cout <= 1'b1;
	else
		cout <= 1'b0;

endmodule
