module datapath
#(	parameter [31:0] INITIAL_PC = 32'h00400000
)

(
input clk, rst,
input [31:0] instr, dReadData,
input PCSrc, ALUSrc, RegWrite, MemToReg,
input [3:0] ALUCtrl,
input loadPC,
output reg [31:0] PC,
output zero,
output [31:0] dAddress, dWriteData, WriteBackData
);

//internal nets
wire [31:0] readData1, readData2, writeData, result, branchOffset;
reg [31:0] op2, dataMemMuxOut, immGenOut;

//PC block, mux made with case statement
always @(posedge clk)
begin
if (rst) PC <= INITIAL_PC;
else if(loadPC)
	begin:PC_mux
		case(PCSrc)
		1'b0: PC <= PC + 32'h00000004;
		1'b1: PC <= PC + branchOffset;
		default: PC<=32'bx; //PC needs to be updated but PCSrc is not set
		endcase
	end
end
	

//register block, made according to schem.7 and manual
regfile regfile1 (.readData1(readData1), .readData2(readData2), .clk(clk),
		  .readReg1(instr[19:15]), .readReg2(instr[24:20]), .writeReg(instr[11:7]),
		  .writeData(dataMemMuxOut), .write(RegWrite));

//Immediate generation block
always @( * )
begin : opcode_case
	case(instr[6:0])
	7'b0010011: immGenOut = { {20{instr[31]}}, instr[31:20]}; // I-type
	7'b0000011: immGenOut = { {20{instr[31]}}, instr[31:20]}; // I-type, LW
	7'b0100011: immGenOut = { {20{instr[31]}}, instr[31:25], instr[11:7]}; // S-type SW
	7'b1100011: immGenOut = { {20{instr[31]}}, instr[31], instr[7], instr[30:25], instr[11:8]}; //B-type BEQ
	default: immGenOut = 32'bx; //command is not supported or doesnt need Immediate Generation
	endcase
end

//Branch Target block
assign branchOffset = immGenOut << 1;

//alu op2 mux block
always @( * ) 
begin:ALU_mux
	case(ALUSrc)
		1'b0: op2 = readData2;
		1'b1: op2 = immGenOut;
		default: op2 = 32'bx;
	endcase
end

//alu instantiation
alu alu1 (.result(result), .zero(zero), .op1(readData1), .op2(op2), .alu_op(ALUCtrl));

assign dAddress = result;

//data memory mux block
always @( * ) 
begin:DataMemory_mux
	case(MemToReg)
		1'b0: dataMemMuxOut = result;
		1'b1: dataMemMuxOut = dReadData;
		default: dataMemMuxOut = 32'bx;
	endcase
end

assign WriteBackData = dataMemMuxOut;
assign dWriteData = readData2;


endmodule
