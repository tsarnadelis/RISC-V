`include "datapath.v"
`timescale 1ns/1ps
module multicycle
#(	parameter [31:0] INITIAL_PC = 32'h00400000
)

(
input clk, rst, 
input [31:0] instr, dReadData,
output reg MemRead, MemWrite,
output [31:0] PC, dAddress, dWriteData, WriteBackData
);

//internal ALU parameters, used for simplicity
localparam[3:0]	LAND = 4'b0000,
		LOR  = 4'b0001,
		ADD  = 4'b0010,
		SUB  = 4'b0110,
		LESS = 4'b0111,
		LSHR = 4'b1000,
		LSHL = 4'b1001,
		ASHR = 4'b1010,
		LXOR = 4'b1101;

//internal nets
wire zero;
reg ALUSrc, RegWrite, MemToReg, PCSrc, loadPC;
reg [3:0] ALUCtrl;


//datapath instantiation
datapath #(INITIAL_PC) datapath1(.PC(PC), .zero(zero), .dAddress(dAddress), .dWriteData(dWriteData), .WriteBackData(WriteBackData),
			       .clk(clk), .rst(rst), .instr(instr), .dReadData(dReadData), .PCSrc(PCSrc),
			       .ALUSrc(ALUSrc), .RegWrite(RegWrite), .MemToReg(MemToReg), .ALUCtrl(ALUCtrl), .loadPC(loadPC));

//FSM block
//   state parameters
reg [2:0] state, next_state;
parameter [2:0] IF  = 3'b001,
		ID  = 3'b010,
		EX  = 3'b011,
		MEM = 3'b100,
		WB  = 3'b101;

//   state memory
always @ ( posedge clk )
begin:STATE_MEMORY
	if(rst) 
		state <= IF;
	else 
		state <= next_state;
end

//   next state logic
always @ ( state )
begin:NEXT_STATE_LOGIC
	case(state)
	IF: next_state = ID; 
	ID: next_state = EX;
	EX: next_state = MEM;
	MEM: next_state = WB;
	WB: next_state = IF;
	default: next_state=3'bxxx;//error, state doesnt exist
	endcase
end

//ALUCtrl block
always @( instr )
begin : ALUCtrl_block
//              ----funct7--------funct3--------opcode--
	casex( { instr[31:25] , instr[14:12] , instr[6:0] } )
	17'bxxxxxxx_xxx_0000011: ALUCtrl = ADD; 	//LW 
	17'bxxxxxxx_xxx_0100011: ALUCtrl = ADD; 	//SW
	17'bxxxxxxx_xxx_1100011: ALUCtrl = SUB; 	//BEQ
	17'bxxxxxxx_000_0010011: ALUCtrl = ADD; 	//ADDI
	17'bxxxxxxx_010_0010011: ALUCtrl = LESS;	//SLTI
	17'bxxxxxxx_100_0010011: ALUCtrl = LXOR; 	//XORI
	17'bxxxxxxx_110_0010011: ALUCtrl = LOR;		//ORI
	17'bxxxxxxx_111_0010011: ALUCtrl = LAND;	//ANDI
	17'bxxxxxxx_001_0010011: ALUCtrl = LSHL;	//SLLI
	17'b0000000_101_0010011: ALUCtrl = LSHR;	//SRLI
	17'b0100000_101_0010011: ALUCtrl = ASHR; 	//SRAI
	17'b0000000_000_0110011: ALUCtrl = ADD; 	//ADD
	17'b0100000_000_0110011: ALUCtrl = SUB; 	//SUB
	17'bxxxxxxx_001_0110011: ALUCtrl = LSHL; 	//SLL
	17'bxxxxxxx_010_0110011: ALUCtrl = LESS;	//SLT
	17'bxxxxxxx_100_0110011: ALUCtrl = LXOR;	//XOR
	17'b0000000_101_0110011: ALUCtrl = LSHR;	//SRL
	17'b0100000_101_0110011: ALUCtrl = ASHR; 	//SRA
	17'bxxxxxxx_110_0110011: ALUCtrl = LOR; 	//OR
	17'bxxxxxxx_111_0110011: ALUCtrl = LAND;	//AND
	default: ALUCtrl = 4'bx;
	endcase
end

//ALUSrc block
always @( instr )
begin : ALUSrc_block
	case(instr[6:0]) //switch opcode
	7'b0000011: ALUSrc = 1'b1; 	//LW 
	7'b0100011: ALUSrc = 1'b1; 	//SW
	7'b0010011: ALUSrc = 1'b1; 	//Immediate functions
	default: ALUSrc = 1'b0;
	endcase
end
	
//MemRead MemWrite block
always @( state )
begin
	if ( state == MEM ) begin
		case(instr[6:0]) //switch opcode
		7'b0000011: MemRead = 1'b1; //LW 
		7'b0100011: MemWrite = 1'b1; //SW
		default:
			begin
				MemRead = 1'b0; //LW 
				MemWrite = 1'b0; //SW
			end
		endcase
	end else begin
		MemRead = 1'b0; //LW 
		MemWrite = 1'b0; //SW
	end
end

//RegWrite block
//Commands that dont write back to the registers are BEQ and SW
always @( instr, state )
begin : RegWrite_block
	if( state == WB )begin
		                //----BEQ---                  -----SW---
		if( instr[6:0] == 7'b1100011 || instr[6:0] == 7'b0100011 ) RegWrite = 1'b0;
		else RegWrite = 1'b1;
		end
	else RegWrite = 1'b0;
end

//MemToReg block
always @( instr )
begin : MemToReg_block
	if( instr[6:0] == 7'b0000011 ) MemToReg = 1'b1; // LW set MemToReg high
	else MemToReg = 1'b0;
end

//loadPC block
always @( state )
begin : loadPC_block
	if( state == WB ) loadPC = 1'b1; // set loadPC high in WB state
	else loadPC = 1'b0;
end

//PCSrc block
always @( instr, zero )
begin : PCSrc_block
	if( (instr[6:0] == 7'b1100011) /*BEQ*/ && zero) PCSrc = 1'b1;
	else PCSrc = 1'b0;
end
endmodule
