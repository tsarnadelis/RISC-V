`include "multicycle.v"
`include "ram.v"
`include "rom.v"
`timescale 1ns/1ps
module cpu_tb();

//internal nets
reg clk, rst;
wire MemRead, MemWrite; 
wire [31:0] instr, dReadData, PC, dAddress, dWriteData, WriteBackData;


//instruction mem instatiation
INSTRUCTION_MEMORY instrMem (.clk(clk), .addr(PC/*32->9 bits*/), .dout(instr));

//mylticycle instatiation
multicycle mc(.clk(clk), .rst(rst), .instr(instr), .dReadData(dReadData), .MemRead(MemRead),
	      .MemWrite(MemWrite), .PC(PC), .dAddress(dAddress), .dWriteData(dWriteData),
	      .WriteBackData(WriteBackData));

//data mem instatiation
DATA_MEMORY dataMem(.clk(clk), .we(MemWrite), .addr(dAddress/*32->9 bits*/), .din(dWriteData),
		    .dout(dReadData));
//ATTENTION: Missing input for control signal MemRead

//Reset generator
initial
begin : ResetGenerator
	    rst = 1'b1;
	#5  rst = 1'b0;

end

//Clock generator
initial
	clk = 1'b1;

always
begin
	#10 clk = ~clk;
end

//Simulation stopper
initial
#2300 $stop;

endmodule
