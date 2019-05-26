`timescale 1ns/1ns


module tb_dac(
);

reg tb_clk_50mhz;
reg tb_rst_n;
reg tb_en;
reg [15:0] tb_data;
wire tb_dac_done;
wire tb_dac_cs_n;
wire tb_dac_din;
wire tb_dac_sclk;
wire tb_dac_state;

parameter CLK_NS = 20;

// 例化
dac dac_inst0(
	.clk_50mhz(tb_clk_50mhz),
	.rst_n(tb_rst_n),
	.en(tb_en),
	.data(tb_data),
	.dac_done(tb_dac_done),
	.dac_cs_n(tb_dac_cs_n),
	.dac_din(tb_dac_din),
	.dac_sclk(tb_dac_sclk),
	.dac_state(tb_dac_state)
);

// 时钟
always #(CLK_NS / 2) tb_clk_50mhz = ~tb_clk_50mhz;

// 初始化
initial begin
	tb_clk_50mhz = 1'b0;
	tb_rst_n = 1'b0;
	tb_en = 1'b0;
	tb_data = 16'd0;
	#(CLK_NS * 20)
	
	tb_rst_n = 1'b1;
	#(CLK_NS * 20)
	
	tb_data = 16'hcaaa;
	tb_en = 1'b1;
	#(CLK_NS)
	tb_en = 1'b0;
	//wait(tb_dac_done);
	#(CLK_NS * 100)
	
	tb_data = 16'h1234;
	tb_en = 1'b1;
	#(CLK_NS)
	tb_en = 1'b0;
	//wait(tb_dac_done);
	#(CLK_NS * 100)
	
	tb_data = 16'habcd;
	tb_en = 1'b1;
	#(CLK_NS)
	tb_en = 1'b0;
	//wait(tb_dac_done);
	#(CLK_NS * 100)
	
	$stop;
end

endmodule
