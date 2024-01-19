`timescale 1ns/1ps
`include "alu.v"
`include "decoder.v"
module calc(
input clk, btnc, btnl, btnu, btnr, btnd,
input[15:0] sw,
output[15:0] led
);

//internal nets
wire zero;
wire [3:0] alu_op;
wire [15:0] accu_out;
wire [31:0] op1, op2, result;


//sign extend sw
assign op2 = {{16{sw[15]}} , sw};

//instantiate decoder
decoder d1(.btnl(btnl), .btnc(btnc), .btnr(btnr), .alu_op(alu_op) );

//instantiate alu
alu a1(.op1(op1), .op2(op2), .alu_op(alu_op), .zero(zero), .result(result) );

//instantiate accumulator
accumulator acc1(.clk(clk), .btnu(btnu), .btnd(btnd), .accu_in(result[15:0]), .accu_out(accu_out) );

//connect accumulator to leds
assign led = accu_out[15:0];

//sign extend accu_out
assign op1 = { {16{accu_out[15]}} , accu_out};


endmodule

module accumulator(
input clk, btnu, btnd,
input [15:0] accu_in,
output reg [15:0] accu_out
);

always @(posedge clk)
begin
	if (btnu) accu_out <= 0;
	else if (btnd) accu_out <= accu_in;
		
end

endmodule