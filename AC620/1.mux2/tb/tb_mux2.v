`timescale 1ns/1ns
 

module tb_mux2(
);

reg tb_a;
reg tb_b;
reg tb_sel;
wire tb_out;

// mux2例化
mux2 mux2_inst0(
	.a(tb_a),
	.b(tb_b),
	.sel(tb_sel),
	.out(tb_out)
);

// 初始化
initial begin
	tb_a = 0;tb_b = 0;tb_sel = 0;
	#100
	
	tb_a = 1;tb_b = 0;tb_sel = 0;
	#100

	tb_a = 0;tb_b = 1;tb_sel = 0;
	#100

	tb_a = 1;tb_b = 1;tb_sel = 0;
	#100

	tb_a = 0;tb_b = 0;tb_sel = 1;
	#100

	tb_a = 1;tb_b = 0;tb_sel = 1;
	#100

	tb_a = 0;tb_b = 1;tb_sel = 1;
	#100

	tb_a = 1;tb_b = 1;tb_sel = 1;
	#100

	$stop;
end

endmodule
