module regfile(
input clk,
input [4:0] readReg1, readReg2, writeReg,
input [31:0] writeData,
input  write,
output reg [31:0] readData1, readData2
);

//internal nets
integer i;

//make 32 Registers of size 32 bits
reg [31:0] Registers [0:31];
	
initial 
begin
	for(i=0; i <= 31; i = i + 1)
	begin
		Registers[i] <= 0;
	end
end
	
// Write at posedge, read at negedge	
always @(posedge clk)
begin
	if (write) 
	begin
		Registers[writeReg] <= writeData;
	end
end
	
always @(negedge clk)
begin
	readData1 <= Registers[readReg1];
	readData2 <= Registers[readReg2];
end




endmodule
