`timescale 1ns/1ns


module tb_rom(
);

reg tb_clock;
reg [7:0] tb_addr;
wire [7:0] tb_q;

parameter CLK_NS = 20;

// 例化
rom rom_inst0(
	.clock(tb_clock),
	.address(tb_addr),
	.q(tb_q)
);

// 时钟
always #(CLK_NS / 2) tb_clock = ~tb_clock;

// 初始化
integer i;
initial begin
	tb_clock = 0;
	tb_addr = 0;
	#CLK_NS
	for (i=0;i<2550;i=i+1) begin
		tb_addr = i;
		#CLK_NS
		addr = addr + 1;
	end
	#(CLK_NS * 50)
	
	$stop;
end

endmodule
