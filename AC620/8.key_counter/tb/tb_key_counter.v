`timescale 1ns/1ns


module tb_key_counter(
);

reg tb_clk_50mhz;
reg tb_rst_n;
reg tb_key_plus;
reg tb_key_minus;
wire [3:0] tb_leds;

parameter CLK_NS = 20;

// 例化
key_counter key_counter_inst0(
	.clk_50mhz(tb_clk_50mhz),
	.rst_n(tb_rst_n),
	.key_plus(tb_key_plus),
	.key_minus(tb_key_minus),
	.leds(tb_leds)
);

// 时钟
always #(CLK_NS / 2) tb_clk_50mhz = ~tb_clk_50mhz;

// 初始化
initial begin
	tb_clk_50mhz = 1'b0;
	tb_rst_n = 1'b0;
	tb_key_plus = 1'b1;
	tb_key_minus = 1'b1;
	#(CLK_NS * 10)
	
	tb_rst_n = 1'b1;
	#(CLK_NS * 1000)
	
	press_key(tb_key_plus);
	#(CLK_NS * 1000);
	press_key(tb_key_plus);
	#(CLK_NS * 1000);
	press_key(tb_key_plus);
	#(CLK_NS * 1000);
	press_key(tb_key_minus);
	#(CLK_NS * 1000);
	press_key(tb_key_minus);
	#(CLK_NS * 1000);
	press_key(tb_key_minus);
	#(CLK_NS * 1000);
	
	$stop;
end

// 模拟按键(Task)
reg [15:0] rand_time;
task press_key;
	input key;
	begin
		// 50次随机按下抖动(每次不大于20ms)
		repeat(50) begin
			rand_time = {$random} % (CLK_NS * 90);
			#rand_time
			key = ~key;
		end
		
		// DOWN状态
		key = 1'b0;
		#(CLK_NS * 500);
		
		// 50次随机释放抖动(每次不大于20ms)
		repeat(50) begin
			rand_time = {$random} % (CLK_NS * 90);
			#rand_time
			key = ~key;
		end
		key = 1'b1;
		#(CLK_NS * 500);
	end
endtask

endmodule
