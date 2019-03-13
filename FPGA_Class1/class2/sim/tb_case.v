`timescale 1ns/1ns


module tb_case(
);

reg tb_rst_n, tb_clk;
wire tb_flag;
wire [7:0] tb_data;
reg [9:0] tb_i_data;
reg [7:0] tb_i_addr;

initial
begin
	tb_rst_n = 0;
	tb_clk = 0;
	tb_i_data = 0;
	tb_i_addr = 0;
	#200
	tb_rst_n = 1;
end

initial
begin
	#500
	send_data(255);
end
	
	
always #10 tb_clk = ~tb_clk;

ex_case ex_case_inst(
	.rst_n(tb_rst_n),
	.clk(tb_clk),
	.flag(tb_flag),
	.data(tb_data),
	.i_data(tb_i_data),
	.i_addr(tb_i_addr)
);

// Task
task send_data(len);
	integer len;
	integer i;
	
	begin
		for (i = 0;i < len;i = i + 1)
		begin
			@(posedge clk);
			tb_i_addr <= i[7:0];
			tb_i_data <= i[7:0];
		end
		tb_i_addr <= 0;
		tb_i_data <= 0;
	end
endtask

endmodule
