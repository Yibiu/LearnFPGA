module fsm(
	input wire clk,
	input wire rst_n,
	input wire A,
	output reg K1,
	output reg K2
);

parameter IDEL = 3'b000;
parameter START = 3'b001;
parameter STOP = 3'b010;
parameter CLEAR = 3'b100;

reg [2:0] state;

// State jump
always @(posedge clk)
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
always @(posedge clk)
	if (rst_n == 1'b0)
		K1 <= 1'b0;
	else
		case (state)
		IDEL:
			if (A == 1'b1)
				K1 <= 0;
		START:
		STOP:
		CLEAR:
			if (A == 1'b0)
				K1 <= 1'b1;
		default:
			K1 <= 1'b0;
		default:
		endcase

// Output K2
always @(posedge clk)
	if (rst_n == 1'b0)
		K2 <= 1'b0;
	else
		case (state)
		IDEL:
		START:
		STOP:
			if (A == 1'b0)
				K2 <= 1;
		CLEAR:
			if (A == 1'b0)
				K2 <= 1'b0;
		default:
			K1 <= 1'b0;
		default:
		endcase
endmodule

