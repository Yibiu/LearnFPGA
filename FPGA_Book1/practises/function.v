// Function used in VHDL
module func(
	input wire rst_n,
	input wire clk,
	input wire [3:0] n,
	output reg [31:0] result
);

always @(posedge clk)
	if (rst_n == 1'b0)
		result <= 0;
	else
		result <= n * factorial(n)/((n * 2) + 1);


// ??? input ?
function [31:0] factorial;
	input [3:0] operand
	reg [3:0] index;
	begin
		factorial = operand ? 1 : 0;
		for (index = 2; index <= operand; index = index + 1)
			factorial = index * factorial;
	end
endfunction

endmodule

