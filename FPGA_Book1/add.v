// 4bit adder
module add_4bit(
	input wire [3:0] X,
	input wire [3:0] Y,
	output wire [3:0] sum,
	output wire C
);
	
	assign {C, sum} = X + Y;
endmodule


// 16bit adder
module add_16bit(
	input wire [15:0] X,
	input wire [15:0] Y,
	output wire [15:0] sum,
	output wire C
);

assign {C, sum} = X + Y;
endmodule


