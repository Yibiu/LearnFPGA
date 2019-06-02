`timescale 1ns/1ns


module tb_adc(
);

reg tb_clk_50mhz;
reg tb_rst_n;
reg tb_en;
reg [2:0] tb_channel;
reg [7:0] tb_div_param;
reg tb_adc_dout;
wire tb_adc_cs_n;
wire tb_adc_state;
wire tb_adc_sclk;
wire tb_adc_din;
wire [11:0] tb_adc_data;
wire tb_adc_done;

parameter CLK_NS = 20;

// 例化
adc adc_inst0(
	.clk_50mhz(tb_clk_50mhz),
	.rst_n(tb_rst_n),
	.en(tb_en),
	.channel(tb_channel),
	.div_param(tb_div_param),
	.adc_dout(tb_adc_dout),
	.adc_cs_n(tb_adc_cs_n),
	.adc_state(tb_adc_state),
	.adc_sclk(tb_adc_sclk),
	.adc_din(tb_adc_din),
	.adc_data(tb_adc_data),
	.adc_done(tb_adc_done)
);

// 时钟
always #(CLK_NS / 2) tb_clk_50mhz = ~tb_clk_50mhz;

// 初始化
initial begin
	tb_clk_50mhz = 1'b0;
	tb_rst_n = 1'b0;
	tb_en = 1'b0;
	tb_channel = 3'd0;
	tb_div_param = 8'd0;
	tb_adc_dout = 1'b0;
	#(CLK_NS * 20)
	
	tb_rst_n = 1'b1;
	#(CLK_NS * 20)
	
	tb_channel = 3'd5;
	tb_div_param = 8'd13;
	tb_adc_dout = 1'b1;
	tb_en = 1'b1;
	#(CLK_NS);
	tb_en = 1'b0;
	
	//wait(tb_adc_done);
	#(CLK_NS * 1000)
	
	$stop;
end

endmodule
