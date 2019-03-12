module selection(
	input wire sel,
	input wire a,
	input wire b,
	output wire c
);

assign c = (sel == 1'b1 ? a : b);

endmodule