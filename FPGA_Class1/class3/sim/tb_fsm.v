`timescale 1ns/1ns


module tb_fsm(
);

reg tb_clk, tb_rst_n;
reg tb_A;
reg tb_K1, tbK2;

initial
begin
	tb_clk = 0;
	tb_rst_n = 0;
	#100
	tb_rst_n = 1;
end

initial
begin
	in_data();
end

always #10 tb_clk = ~tb_clk;

task in_data();
	integer i;
	begin
		for (i = 0;i < 1024;i = i + 1)
		begin
			@(posedge tb_clk);
			if (i < 50)
				tb_A <= 0;
			else if (i < 200)
				tb_A <= 1;
			else if (i < 700)
				tb_A <= 0;
			else if (i < 800)
				tb_A <= 1;
			else if (i < 900)
				tb_A <= 0;
			else
				tb_A <= 1;
		end
	end
endtask

fsm fsm_inst(
	.clk(tb_clk),
	.rst_n(tb_rst_n),
	.A(tb_A),
	.K1(tb_K1),
	.K2(tb_K2)
);
	
endmodule
