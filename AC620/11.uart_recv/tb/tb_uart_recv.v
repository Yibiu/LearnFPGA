`timescale 1ns/1ns


module tb_uart_recv(
);

reg tb_clk_50mhz;
reg tb_rst_n;
reg tb_en;
reg [2:0] tb_baud;
reg tb_data;
wire [7:0] tb_rx_data;
wire tb_rx_done;

parameter CLK_NS = 20;

// 例化
uart_recv uart_recv_inst0(
	.clk_50mhz(tb_clk_50mhz),
	.rst_n(tb_rst_n),
	.en(tb_en),
	.baud(tb_baud),
	.data(tb_data),
	.rx_data(tb_rx_data),
	.rx_done(tb_rx_done)
);

// 时钟
always #(CLK_NS / 2) tb_clk_50mhz = ~tb_clk_50mhz;

// 初始化
initial begin
	tb_clk_50mhz = 1'b0;
	tb_rst_n = 1'b0;
	tb_en = 1'b1;
	tb_baud = 3'b0;
	tb_data = 1'b0;
	#(CLK_NS * 10)
	
	tb_data = 1'b0;
	tb_rst_n = 1'b1;
	#(CLK_NS * 2603)
	tb_data = 1'b1;
	#(CLK_NS * 2603 * 4)
	tb_data = 1'b0;
	#(CLK_NS * 2603 * 2)
	tb_data = 1'b1;
	#(CLK_NS * 10000)
	
	$stop;
end

endmodule
