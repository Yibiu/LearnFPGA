/**
* @brief:
* ROM的IP核根据时钟自动读取内容,读取地址递增。
*/
module rom_top(
	input wire clk_50mhz,
	input wire rst_n,
	output wire [7:0] q
);

reg [7:0] addr;

rom rom_inst0(
	.clock(clk_50mhz),
	.address(addr),
	.q(q)
);

always @(posedge clk_50mhz or negedge rst_n)
	if (rst_n == 1'b0)
		addr <= 8'd0;
	else
		addr <= addr + 1'b1;

endmodule

