// 4bit multiplication
module multiplication_4bit(
	input wire [3:0] X,
	input wire [3:0] Y,
	output wire [7:0] product
);

assign product = X * Y;
endmodule


// 8bit multiplication
module multiplication_8bit(
	input wire [7:0] X,
	input wire [7:0] Y,
	output wire [15:0] product
);

assign product = X * Y;
endmodule

