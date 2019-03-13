module ex_case(
	input wire rst_n,
	input wire clk,
	output reg flag,
	output reg [7:0] data,
	// task
	input wire [9:0] i_data,
	input wire [7:0] i_addr
);

reg [2:0] cnt;

always @(posedge clk or negedge rst_n)
	if (rst_n == 1'b0)
		cnt <= 3'd0;
	else
		cnt <= cnt + 1'b1;

always @(posedge clk or negedge rst_n)
	if (rst_n == 1'b0)
		data <= 8'd0;
	else
		case (cnt)
		3'd0:
			begin
				flag <= 1'b1;
				data <= 3'd7;
			end
		3'd1:
			begin
				flag <= 1'b1;
				data <= 3'd2;
			end
		3'd2:
			begin
				flag <= 1'b1;
				data <= 3'd5;
			end
		default:
			begin
				flag <= 1'b0;
				data <= 3'd0;
			end
		endcase

endmodule

