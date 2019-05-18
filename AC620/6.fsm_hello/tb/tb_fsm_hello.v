`timescale 1ns/1ns


module tb_fsm_hello(
);

reg tb_clk_50mhz;
reg tb_rst_n;
reg [7:0] tb_data;
wire tb_led;

parameter CLK_NS = 20;

// 例化
fsm_hello fsm_hello_inst0(
	.clk_50mhz(tb_clk_50mhz),
	.rst_n(tb_rst_n),
	.data(tb_data),
	.led(tb_led)
);

// 时钟
always #(CLK_NS / 2) tb_clk_50mhz = ~tb_clk_50mhz;

// 初始化
initial begin
	tb_clk_50mhz = 1'b0;
	tb_rst_n = 1'b0;
	tb_data = "A";
	#(CLK_NS * 10)
	
	tb_rst_n = 1'b1;
	#(CLK_NS * 10)
	
	repeat(20) begin
		tb_data = "I";
		#(CLK_NS)
		tb_data = "A";
		#(CLK_NS)
		tb_data = "M";
		#(CLK_NS)
		tb_data = "X";
		#(CLK_NS)
		tb_data = "i";
		#(CLK_NS)
		tb_data = "a";
		#(CLK_NS)
		tb_data = "o";
		#(CLK_NS)
		tb_data = "M";
		#(CLK_NS)
		tb_data = "e";
		#(CLK_NS)
		tb_data = "i";
		#(CLK_NS)
		tb_data = "g";
		#(CLK_NS)
		tb_data = "e";
		#(CLK_NS)
		tb_data = "H";
		#(CLK_NS)
		tb_data = "E";
		#(CLK_NS)
		tb_data = "M";
		#(CLK_NS)
		tb_data = "I";
		#(CLK_NS)
		tb_data = "H";
		#(CLK_NS)
		tb_data = "E";
		#(CLK_NS)
		tb_data = "L";
		#(CLK_NS)
		tb_data = "L";
		#(CLK_NS)
		tb_data = "O";
		#(CLK_NS)
		tb_data = "H";
		#(CLK_NS)
		tb_data = "e";
		#(CLK_NS)
		tb_data = "l";
		#(CLK_NS)
		tb_data = "l";
		#(CLK_NS)
		tb_data = "o";
		#(CLK_NS)
		tb_data = "l";
		#(CLK_NS);
	end
	
	$stop;
end

endmodule
