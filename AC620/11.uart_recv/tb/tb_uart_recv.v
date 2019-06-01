`timescale 1ns/1ns


module tb_uart_recv(
);

reg tb_clk_50mhz;
reg tb_rst_n;
reg [2:0] tb_baud;
reg tb_data;
wire tb_rx_state;
wire [7:0] tb_rx_data;
wire tb_rx_done;

parameter CLK_NS = 20;

// 例化
uart_recv uart_recv_inst0(
	.clk_50mhz(tb_clk_50mhz),
	.rst_n(tb_rst_n),
	.baud(tb_baud),
	.data(tb_data),
	.rx_state(tb_rx_state),
	.rx_data(tb_rx_data),
	.rx_done(tb_rx_done)
);

// 时钟
always #(CLK_NS / 2) tb_clk_50mhz = ~tb_clk_50mhz;

// 初始化
initial begin
	tb_clk_50mhz = 1'b0;
	tb_rst_n = 1'b0;
	tb_baud = 3'd4;
	tb_data = 1'b1;
	#(CLK_NS * 100)
	
	tb_rst_n = 1'b1;
	#(CLK_NS * 100)
	// START
	tb_data = 1'b0;
	#(CLK_NS * 27 * 16)
	// DATA0 ~ DATA7
	tb_data = 1'b1;
	#(CLK_NS * 27 * 16)
	tb_data = 1'b0;
	#(CLK_NS * 27 * 16)
	tb_data = 1'b1;
	#(CLK_NS * 27 * 16)
	tb_data = 1'b0;
	#(CLK_NS * 27 * 16)
	tb_data = 1'b1;
	#(CLK_NS * 27 * 16)
	tb_data = 1'b0;
	#(CLK_NS * 27 * 16)
	tb_data = 1'b1;
	#(CLK_NS * 27 * 16)
	tb_data = 1'b0;
	#(CLK_NS * 27 * 16)
	// STOP
	tb_data = 1'b1;
	#(CLK_NS * 27 * 16)
	
	#(CLK_NS * 1000);
	
	$stop;
end

endmodule
