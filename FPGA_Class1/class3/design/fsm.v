module fsm(
	input wire clk,
	input wire rst_n,
	input wire A,
	output reg K1,
	output reg K2
);

parameter IDEL = 4'b0001;
parameter START = 4'b0010;
parameter STOP = 4'b0100;
parameter CLEAR = 4'b1000;

reg [3:0] state;

// State jump
always @(posedge clk or negedge rst_n)
	if (rst_n == 1'b0)
		state <= IDEL;
	else
		case (state)
		IDEL:
			if (A == 1'b1)
				state <= START;
		START:
			if (A == 1'b0)
				state <= STOP;
		STOP:
			if (A == 1'b1)
				state <= CLEAR;
		CLEAR:
			if (A == 1'b0)
				state <= IDEL;
		default:
			state <= IDEL;
		endcase

// Output K1
always @(posedge clk or negedge rst_n)
	if (rst_n == 1'b0)
		K1 <= 1'b0;
	else if (state == IDEL && A == 1'b1)
		K1 <= 1'b0;
	else if (state == CLEAR && A == 1'b0)
		K1 <= 1'b1;

// Output K2
always @(posedge clk or negedge rst_n)
	if (rst_n == 1'b0)
		K2 <= 1'b0;
	else if (state == STOP && A == 1'b1)
		K2 <= 1'b1;
	else if (state == CLEAR && A== 1'b0)
		K2 <= 1'b0;

endmodule
