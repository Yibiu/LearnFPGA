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
	
	press_plus;
	#(CLK_NS * 1000);
	press_plus;
	#(CLK_NS * 1000);
	press_plus;
	#(CLK_NS * 1000);
	press_minus;
	#(CLK_NS * 1000);
	press_minus;
	#(CLK_NS * 1000);
	press_minus;
	#(CLK_NS * 1000);
	
	$stop;
end

// 模拟按键plus(Task)
reg [15:0] rand_plus;
task press_plus;
	begin
		// 50次随机按下抖动(每次不大于20ms)
		repeat(50) begin
			rand_plus = {$random} % (CLK_NS * 90);
			#rand_plus
			tb_key_plus = ~tb_key_plus;
		end
		
		// DOWN状态
		tb_key_plus = 1'b0;
		#(CLK_NS * 500);
		
		// 50次随机释放抖动(每次不大于20ms)
		repeat(50) begin
			rand_plus = {$random} % (CLK_NS * 90);
			#rand_plus
			tb_key_plus = ~tb_key_plus;
		end
		tb_key_plus = 1'b1;
		#(CLK_NS * 500);
	end
endtask

// 模拟按键minus(Task)
reg [15:0] rand_minus;
task press_minus;
	begin
		// 50次随机按下抖动(每次不大于20ms)
		repeat(50) begin
			rand_minus = {$random} % (CLK_NS * 90);
			#rand_minus
			tb_key_minus = ~tb_key_minus;
		end
		
		// DOWN状态
		tb_key_minus = 1'b0;
		#(CLK_NS * 500);
		
		// 50次随机释放抖动(每次不大于20ms)
		repeat(50) begin
			rand_minus = {$random} % (CLK_NS * 90);
			#rand_minus
			tb_key_minus = ~tb_key_minus;
		end
		tb_key_minus = 1'b1;
		#(CLK_NS * 500);
	end
endtask

endmodule
