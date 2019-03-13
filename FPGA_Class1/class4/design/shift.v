module shift(
	input wire lvds_clk,
	input wire rst_n,
	input wire lvds_d,
	output reg [7:0] o_lvds_d
);

reg [7:0] shift_reg;
reg [2:0] cnt;
reg flag;

always @(posedge lvds_clk or negedge rst_n)
	if (rst_n == 1'b0)
		shift_reg <= 'd0;
	else
		shift_reg <= {shift_reg[6:0], lvds_d};

always @(posedge lvds_clk or negedge rst_n)
	if (rst_n == 1'b0)
		cnt <= 'd0;
	else
		cnt <= cnt + 1'b1;
		
always @(cnt)
	if (cnt == 3'b7)
		flag <= 1'b1;
	else
		flag <= 1'b0;
		
always @(posedge lvds_clk or negedge rst_n)
	if (rst_n == 1'b0)
		o_lvds_d <= 'd0;
	else if (flag == 1'b1)
		o_lvds_d <= shift_reg;

endmodule
