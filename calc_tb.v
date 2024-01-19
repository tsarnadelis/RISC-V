`timescale 1ns/1ps
`include "calc.v"
module calc_tb();

reg clk, btnc, btnl, btnu, btnr, btnd;
reg [15:0] sw;
wire [15:0] led;

//instantiate DUT
calc c1(.clk(clk), .btnc(btnc), .btnl(btnl), .btnu(btnu), .btnr(btnr), .btnd(btnd), .sw(sw), .led(led));

//Reset block
initial 
begin
#10  btnu=1;	//reset accumulator
#10  btnu=0;  	//accumulator normal mode
end

//Input value block
initial 
begin     
#30 btnl=0;btnc=1;btnr=1;sw=16'h1234;btnd=1;
#20 btnl=0;btnc=1;btnr=0;sw=16'h0ff0;
#20 btnl=0;btnc=0;btnr=0;sw=16'h324f;
#20 btnl=0;btnc=0;btnr=1;sw=16'h2d31;
#20 btnl=1;btnc=0;btnr=0;sw=16'hffff;
#20 btnl=1;btnc=0;btnr=1;sw=16'h7346;
#20 btnl=1;btnc=1;btnr=0;sw=16'h0004;
#20 btnl=1;btnc=1;btnr=1;sw=16'h0004;
#20 btnl=1;btnc=0;btnr=1;sw=16'hffff;
#40 $stop;
end 

//clock generator block
initial 
	clk=1'b0; //set initial value
always
begin
	#10 clk = ~clk;
end

endmodule
