`timescale 1ns/1ns


module tb_counter(
);

reg tb_cin;
reg tb_clk;
wire tb_cout;
wire [3:0] tb_q;

parameter CLK_NS = 20;

// 例化
counter counter_inst0(
	.cin(tb_cin),
	.clock(tb_clk),
	.cout(tb_cout),
	.q(tb_q)
);

// 时钟
always #(CLK_NS / 2) tb_clk = ~tb_clk;

// 初始化
initial begin
	tb_clk = 1'b0;
	
	repeat(20) begin
		tb_cin = 1'b0;
		#(CLK_NS * 5)
		tb_cin = 1'b1;
		#(CLK_NS)
		tb_cin = 1'b0;
	end
	#(CLK_NS * 100)
	
	$stop;
end

endmodule
