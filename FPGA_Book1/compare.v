// n bit compare
module compare_nbit(
	input wire [n-1:0] X,
	input wire [n-1:0] Y,
	output reg x_g_y,
	output reg x_l_y,
	output reg x_e_y
);

parameter n = 8;

always @(X or Y)
	begin
		if (X > Y)
			x_g_y = 1;
		else
			x_g_y = 0;
		
		if (X < Y)
			x_l_y = 1;
		else
			x_l_y = 0;
			
		if (X == Y)
			x_e_y = 1;
		else
			x_e_y = 0;
	end
endmodule