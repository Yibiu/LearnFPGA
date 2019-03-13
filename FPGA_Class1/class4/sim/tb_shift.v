`timescale 1ns/1ns


module tb_shift(
);

reg tb_lvds_clk, tb_rst_n;
reg tb_lvds_d;
reg [7:0] tb_o_lvds_d;
reg [0:0] mem1x16 [15:0]; // 1bit, 0~16

initial
begin
	tb_lvds_clk = 0;
	tb_rst_n = 1;
	#100
	tb_rst_n = 0;
end

initial
begin
	$readmemb("./data.txt", mem1x16);
end

initial
begin
	#100
	send_data();
end

task send_data();
	integer i;
	for (i = 0;i <= 255;i = i + 1)
	begin
		@(posedge tb_lvds_clk)
		tb_lvds_d = mem1x16[i[3:0]]
	end
endtask

shift shift_inst(
	.lvds_clk(tb_lvds_clk),
	.rst_n(tb_rst_n),
	.lvds_d(tb_lvds_d),
	.o_lvds_d(tb_o_lvds_d)
);

endmodule
