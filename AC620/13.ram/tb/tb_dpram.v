`timescale 1ns/1ns


/**
* @brief:
* 双端口RAM读写IP核。
*/
module tb_dpram(
);

reg tb_clock;
reg [7:0] tb_data;
reg [7:0] tb_r_addr;
reg [7:0] tb_w_addr;
reg tb_wr_en;
wire [7:0] tb_q;

parameter CLK_NS = 20;

// 例化
dpram dpram0(
	.clock(tb_clock),
	.data(tb_data),
	.rdaddress(tb_r_addr),
	.wraddress(tb_w_addr),
	.wren(tb_wr_en),
	.q(tb_q)
);

// 时钟
always #(CLK_NS / 2) tb_clock = ~tb_clock;

// 初始化
integer i;
initial begin
	tb_data = 0;
	tb_r_addr = 0;
	tb_w_addr = 0;
	tb_wr_en = 0;
	#(CLK_NS * 20)
	
	tb_wr_en = 1;
	for (i=0;i<=15;i=i+1) begin
		data = 255 - i;
		tb_w_addr = i;
		#CLK_NS;
	end
	tb_wr_en = 0;
	#(CLK_NS * 20)
	for (i=0;i<=15;i=i+1) begin
		tb_r_addr = i;
		#CLK_NS;
	end
	#(CLK_NS * 20)
	
	$stop;
end

endmodule
