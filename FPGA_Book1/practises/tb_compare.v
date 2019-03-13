`timescale 1ns/1ns
`include "./compare.v"


module tb_compare(
);

reg tb_a, tb_b;
wire tb_equal;

initial
	begin
		a = 0;
		b = 0;
		#100
		a = 0;
		b = 1;
		#100
		a = 1;
		b = 1;
		#100
		a = 1;
		b = 0;
		#100
		a = 0;
		b = 0;
	end

compare compare_inst(
	.a(tb_a),
	.b(tb_b),
	.equal(tb_equal)
);

endmodule