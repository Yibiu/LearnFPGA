`timescale 1ns/1ns


module tb_decoder3_8(
);

reg tb_a;
reg tb_b;
reg tb_c;
wire [7:0] tb_out;

// 例化
decoder3_8 decoder3_8_inst0(
	.a(tb_a),
	.b(tb_b),
	.c(tb_c),
	.out(tb_out)
);

// 初始化
initial begin
	tb_a = 0;tb_b = 0;tb_c = 0;
	#20
	tb_a = 0;tb_b = 0;tb_c = 1;
	#20
	tb_a = 0;tb_b = 1;tb_c = 0;
	#20
	tb_a = 0;tb_b = 1;tb_c = 1;
	#20
	tb_a = 1;tb_b = 0;tb_c = 0;
	#20
	tb_a = 1;tb_b = 0;tb_c = 1;
	#20
	tb_a = 1;tb_b = 1;tb_c = 0;
	#20
	tb_a = 1;tb_b = 1;tb_c = 1;
	#20
	
	$stop;
end

endmodule
