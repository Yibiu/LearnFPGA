`timescale 1ns/1ns


module tb_dfifo(
);

reg [15:0] tb_data;
reg tb_rdclk;
reg tb_rdreq;
reg tb_wrclk;
reg tb_wrreq;
wire [7:0] tb_q;
wire tb_rdempty;
wire [7:0] tb_rdusedw;
wire tb_wrfull;
wire [7:0] tb_wrusedw;

parameter WR_CLK_NS = 20;
parameter RD_CLK_NS = 10;

// 例化
dfifo dfifo_inst0(
	data(tb_data),
	rdclk(tb_rdclk),
	rdreq(tb_rdreq),
	wrclk(tb_wrclk),
	wrreq(tb_wrreq),
	q(tb_q),
	rdempty(tb_rdempty),
	rdusedw(tb_rdusedw),
	wrfull(tb_wrfull),
	wrusedw(tb_wrusedw)
);

// 时钟
always #(WR_CLK_NS / 2) tb_wrclk = ~tb_wrclk;
always #(RD_CLK_NS / 2) tb_rdclk = ~tb_rdclk;

// 初始化
integer i;
initial begin
	tb_data = 16'd0;
	tb_rdclk = 1'b0;
	tb_rdreq = 1'b0;
	tb_wrclk = 1'b0;
	tb_wrreq = 1'b0;
	#(WR_CLK_NS * 20)
	
	tb_wrreq = 1'b1;
	for (i=0;i<=255;i=i+1) begin
		tb_data = i + 1024;
		#(WR_CLK_NS);
	end
	tb_wrreq = 1'b0;
	#(WR_CLK_NS * 20)
	
	tb_rdreq = 1'b1;
	for (i=0;i<=511;i=i+1) begin
		#(RD_CLK_NS);
	end
	tb_rdreq = 1'b0;
	#(RD_CLK_NS * 20)
	
	$stop;
end

endmodule
