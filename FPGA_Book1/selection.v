// 8 channel selection
module mux_8channel(
	input wire cs_n,
	input wire [2:0] sel,
	input wire [n-1:0] ch0,
	input wire [n-1:0] ch1,
	input wire [n-1:0] ch2,
	input wire [n-1:0] ch3,
	input wire [n-1:0] ch4,
	input wire [n-1:0] ch5,
	input wire [n-1:0] ch6,
	input wire [n-1:0] ch7,
	output wire [n-1:0] out
);

parameter n = 8;

always @(cs_n or sel or ch0 or ch1 or ch2 or ch3 or ch4 or ch5 or ch6 or ch7)
	begin
		if (cs_n == 1'b1)
			out <= 0;
		else
			case (sel)
			3'b000: out <= ch0;
			3'b001: out <= ch1;
			3'b010: out <= ch2;
			3'b011: out <= ch3;
			3'b100: out <= ch4;
			3'b101: out <= ch5;
			3'b110: out <= ch6;
			3'b111: out <= ch7;
			default: out <= 0;
			endcase
	end
	
endmodule
