`timescale 1ns/1ns


module tb_uart_send(
);

reg tb_clk_50mhz;
reg tb_rst_n;
reg tb_en;
reg [2:0] tb_baud;
reg [7:0] tb_data;
wire tb_tx_state;
wire tb_tx_data;
wire tb_tx_done;

parameter CLK_NS = 20;

// 例化
uart_send uart_send_inst0(
	.clk_50mhz(tb_clk_50mhz),
	.rst_n(tb_rst_n),
	.en(tb_en),
	.baud(tb_baud),
	.data(tb_data),
	.tx_state(tb_tx_state),
	.tx_data(tb_tx_data),
	.tx_done(tb_tx_done)
);

// 时钟
always #(CLK_NS / 2) tb_clk_50mhz = ~tb_clk_50mhz;

// 初始化
initial begin
	tb_clk_50mhz = 1'b0;
	tb_rst_n = 1'b0;
	tb_en = 1'b0;
	tb_baud = 3'd0;
	tb_data = 8'd1011_1010;
	#(CLK_NS * 100)
	
	tb_rst_n = 1'b1;
	#(CLK_NS * 100)
	
	tb_baud = 3'd4;
	tb_en = 1'b1;
	#(CLK_NS)
	tb_en = 1'b0;
	@(posedge tb_tx_done)
	#(CLK_NS * 1000)
	tb_data = 8'b1000_0001;
	tb_en = 1'b1;
	#(CLK_NS)
	tb_en = 1'b0;
	@(posedge tb_tx_done)
	#(CLK_NS * 1000)
	
	$stop;
end

endmodule
