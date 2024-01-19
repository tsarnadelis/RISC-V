`timescale 1ns/1ps
module decoder(
input btnl,
input btnc,
input btnr,
output [3:0] alu_op
);

//internal nets
wire w1, w2, w3, w4, w5, w6, w7, w8, w9, w10, w11;

//alu_op[0]
not(w1, btnr);
and(w2, w1, btnl);
xor(w3, btnl, btnc);
and(w4, w3, btnr);
or(alu_op[0], w4, w2);

//alu_op[1]
and(w5, btnr, btnl);
not(w6, btnl);
not(w7, btnc);
and(w8, w6, w7);
or(alu_op[1], w5, w8);

//alu_op[2]
//and(w5, btnr, btnl) exists and is w5
xor(w9, btnr, btnl);
or(w10, w9, w5);
//not(w7, btnc) exists and is w7
and(alu_op[2], w10, w7);

//alu_op[3]
//not(w1, btnr) exists and is w1
and(w11, w1, btnc);
xnor(w12, btnr, btnc);
or(w13, w11, w12);
and(alu_op[3], w13, btnl);

endmodule
