`timescale 1ns/1ns


module tb_key_filter(
);

reg tb_clk_50mhz;
reg tb_rst_n;
reg tb_key_in;
wire tb_key_flag;
wire tb_key_state;

parameter CLK_NS = 20;

// 例化
key_filter #(.CNT_20MS(100)) key_filter_inst0(
	.clk_50mhz(tb_clk_50mhz),
	.rst_n(tb_rst_n),
	.key_in(tb_key_in),
	.key_flag(tb_key_flag),
	.key_state(tb_key_state)
);

// 时钟
always #(CLK_NS / 2) tb_clk_50mhz = ~tb_clk_50mhz;

// 初始化
initial begin
	tb_clk_50mhz = 1'b0;
	tb_rst_n = 1'b0;
	tb_key_in = 1'b1;
	#(CLK_NS * 200);
	
	tb_rst_n = 1'b1;
	#(CLK_NS * 500);
	press_key;
	#(CLK_NS * 500);
	press_key;
	#(CLK_NS * 500);
	press_key;
	#(CLK_NS * 500);
	
	$stop;
end

// 仿真任务(Task)
reg [15:0] rand_time;
task press_key(
);
	begin
		// 50次随机按下抖动(模拟抖动每次小于20ms)
		repeat(50) begin
			rand_time = {$random} % (CLK_NS * 90);
			#rand_time
			tb_key_in = ~tb_key_in;
		end
		
		// DOWN状态
		tb_key_in = 1'b0;
		#(CLK_NS * 500);
		
		// 50次随机释放抖动(模拟抖动每次小于20ms)
		repeat(50) begin
			rand_time = {$random} % (CLK_NS * 90);
			#rand_time
			tb_key_in = ~tb_key_in;
		end
		tb_key_in = 1'b1;
		#(CLK_NS * 500);
	end
endtask

endmodule
