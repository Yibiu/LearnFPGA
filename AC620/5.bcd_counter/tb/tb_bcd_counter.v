`timescale 1ns/1ns


module tb_bcd_counter(
);

reg tb_clk_50mhz;
reg tb_rst_n;
reg tb_cin;
wire tb_cout;
wire [3:0] tb_q;

parameter CLK_NS = 20;

// 例化
bcd_counter bcd_counter_inst0(
	.clk_50mhz(tb_clk_50mhz),
	.rst_n(tb_rst_n),
	.cin(tb_cin),
	.cout(tb_cout),
	.q(tb_q)
);

// 时钟
always #(CLK_NS / 2) tb_clk_50mhz = ~tb_clk_50mhz;

// 初始化
initial begin
	tb_clk_50mhz = 1'b0;
	tb_rst_n = 1'b0;
	tb_cin = 1'b0;
	#(CLK_NS * 5)
	
	tb_rst_n = 1'b1;
	#(CLK_NS * 5)
	
	repeat(30) begin
		tb_cin = 1'b1;
		#(CLK_NS)
		tb_cin = 1'b0;
		#(CLK_NS * 5);
	end
	#(CLK_NS * 100)
	
	$stop;
end

endmodule
