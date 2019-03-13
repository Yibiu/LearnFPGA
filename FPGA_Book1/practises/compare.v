// Compare a and b
// == --> 1
// != --> 0
module compare(
	input wire a,
	input wire b,
	output wire equal
);

assign equal = (a == b) ? 1 : 0;

endmodule


module compare(
	input wire a,
	input wire b,
	output reg equal
);

always @(a or b)
	if (a == b)
		equal <= 1;
	else
		equal <= 0;

endmodule


