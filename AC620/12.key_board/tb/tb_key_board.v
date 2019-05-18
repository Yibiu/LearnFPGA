`timescale 1ns/1ns


module tb_key_board(
);

reg tb_clk_50mhz;
reg tb_rst_n;
reg [3:0] tb_rows;
wire [3:0] tb_cols;
wire tb_key_flag;
wire [3:0] tb_key_value;

parameter CLK_NS = 20;

// 例化
key_board key_board_inst0(
	.clk_50mhz(tb_clk_50mhz),
	.rst_n(tb_rst_n),
	.rows(tb_rows),
	.cols(tb_cols),
	.key_flag(tb_key_flag),
	.key_value(tb_key_value),
);

// 时钟
always #(CLK_NS / 2) tb_clk_50mhz = ~tb_clk_50mhz;

// 初始化
initial begin
	tb_clk_50mhz = 1'b0;
	tb_rst_n = 1'b0;
	tb_rows = 4'b1111;
	#(CLK_NS * 20)
	
	tb_rows = 4'b0111;
	tb_rst_n = 1'b1;
	#(CLK_NS * 5000_000)
	tb_rows = 4'b1011;
	#(CLK_NS * 5000_000)
	tb_rows = 4'b1101;
	#(CLK_NS * 5000_000)
	tb_rows = 4'b1110;
	#(CLK_NS * 5000_000)
	
	$(stop);
end

endmodule
