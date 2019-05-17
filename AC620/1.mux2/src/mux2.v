/**
* @brief:
* 二选一多路选择器
* assign组合逻辑设计示例
*
* @reources:
* a -> key0(PIN_M16)
* b -> key1(PIN_E15)
* sel -> key2(PIN_E16)
* out -> led(PIN_A2)
*
* IO Standard: 3.3LVTTL
*/
module mux2(
	input wire a,
	input wire b,
	input wire sel,
	output wire out
);

assign out = (sel ? a : b);

endmodule
