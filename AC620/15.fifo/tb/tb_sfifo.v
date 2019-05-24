`timescale 1ns/1ns


module tb_sfifo(
);

reg tb_clock;
reg [15:0] tb_data;
reg tb_rdreq;
reg tb_sclr;
reg tb_wrreq;
wire tb_almost_empty;
wire tb_almost_full;
wire tb_empty;
wire tb_full;
wire [15:0] tb_q;
wire [7:0] tb_usedw;

parameter CLK_NS = 20;

// 例化
sfifoip sfifoip_inst0(
	clock(tb_clock),
	data(tb_data),
	rdreq(tb_rdreq),
	sclr(tb_sclr),
	wrreq(tb_wrreq),
	almost_empty(tb_almost_empty),
	almost_full(tb_almost_full),
	empty(tb_empty),
	full(tb_full),
	q(tb_q),
	usedw(tb_usedw)
);
	
// 时钟
always #(CLK_NS / 2) tb_clock = ~tb_clock;

// 初始化
integer i;
initial begin
	tb_clock = 1'b0;
	tb_data = 16'd0;
	tb_rdreq = 1'b0;
	tb_sclr = 1'b0;
	tb_wrreq = 1'b0;
	#(CLK_NS * 20)
	
	tb_wrreq = 1'b1;
	for (i=0;i<=255;i=i+1) begin
		tb_data = i;
		#(CLK_NS);
	end
	tb_wrreq = 1'b0;
	#(CLK_NS * 20)
	
	tb_rdreq = 1'b1;
	for (i=0;i<=255;i=i+1) begin
		#(CLK_NS);
	end
	tb_rdreq = 1'b0;
	#(CLK_NS * 20)
	
	$stop;
end

endmodule
