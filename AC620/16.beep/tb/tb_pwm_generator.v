`timescale 1ns/1ns


module tb_pwm_generator(
);

reg tb_clk_50mhz;
reg tb_rst_n;
reg tb_en;
reg [31:0] tb_counter_arr;
reg [31:0] tb_counter_ccr;
wire tb_pwm;

parameter CLK_NS = 20;

// 例化
pwm_generator pwm_generator_inst0(
	.clk_50mhz(tb_clk_50mhz),
	.rst_n(tb_rst_n),
	.en(tb_en),
	.counter_arr(tb_counter_arr),
	.counter_ccr(tb_counter_ccr),
	.pwm(tb_pwm)
);

// 时钟
always #(CLK_NS / 2) tb_clk_50mhz = ~tb_clk_50mhz;

// 初始化
initial begin
	tb_clk_50mhz = 1'b0;
	tb_rst_n = 1'b0;
	tb_en = 1'b0;
	tb_counter_arr = 0;
	tb_counter_ccr = 0;
	#(CLK_NS * 20)
	
	tb_rst_n = 1'b1;
	#(CLK_NS * 20)
	
	tb_counter_arr = 999; // 50KHz
	tb_counter_ccr = 400; // 40%
	tb_en = 1'b1;
	#(CLK_NS * 5000)
	
	tb_en = 1'b0;
	tb_counter_arr = 499; // 100KHz
	tb_counter_ccr = 250; // 50%
	#(CLK_NS * 20)
	tb_en = 1'b1;
	#(CLK_NS * 5000)
	
	$stop;
end

endmodule
