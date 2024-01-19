`timescale 1ns/1ps
module alu
#(	parameter[3:0] 	LAND = 4'b0000,
			LOR  = 4'b0001,
			ADD  = 4'b0010,
			SUB  = 4'b0110,
			LESS = 4'b0111,
			LSHR = 4'b1000,
			LSHL = 4'b1001,
			ASHR = 4'b1010,
			LXOR = 4'b1101
)
	
(
input [31:0] op1,
input [31:0] op2,
input [3:0] alu_op,
output reg zero,
output reg [31:0] result
);

always @(op1, op2, alu_op)
begin

case(alu_op)
//logic and
LAND:result = op1 & op2;

//logic or
LOR: result = op1 | op2;

//addition
ADD: result = op1 + op2;

//subtraction
SUB: result = op1 - op2;

//less than
LESS: result = $signed(op1) < $signed(op2);

//logic shift right
LSHR: result = op1 >> op2[4:0];

//logic shift left
LSHL: result = op1 << op2[4:0];

//arithmetic shift right
ASHR: result = $unsigned($signed(op1) >>> op2[4:0]);

//logix xor
LXOR: result = op1 ^ op2;

//set default value to zero
default: result=0;

endcase

zero = ~|result ;

end



endmodule