module IF_Stage (IFID_PC_add4,IFID_IR,PC_add4, 
                  Clk,Rst,PC_Write,IFID_RegWrite,IFID_Flush_BJ,IFID_Flush_E,PC_Sel,PC_Exception_W,IR_Read,PC_BJ,PC_Exception);
output	[31:0]	IFID_PC_add4;
output	[31:0]	IFID_IR;
output [31:0] PC_add4;

input         Clk;
input   		   	Rst;
input   		   	PC_Write;
input   		   	IFID_RegWrite;
input   		   	IFID_Flush_BJ;
input         IFID_Flush_E;
input   		   	PC_Sel;
input         PC_Exception_W;
input        	IR_Read;
input 	[31:0]	PC_BJ;
input  [31:0] PC_Exception;

wire   [31:0]	IR;
wire  	[31:0]	PC_add4;
wire  	[31:0]	Next_PC;
wire  	[31:0]	PC;
wire          IFID_Flush;

assign IFID_Flush = IFID_Flush_BJ | IFID_Flush_E;

PC_Unit	         M_PC_Unit	(PC, Clk, Rst, PC_Write, Next_PC);
PC_Add4	         M_PC_Add4	(PC_add4, PC);
PC_Mux         	 M_PC_Mux	 (Next_PC, PC_add4, PC_BJ, PC_Exception, PC_Sel, PC_Exception_W);
IR_MEM	          M_IR_MAM	 (IR, Clk, Rst, IR_Read, PC);
IFID_Reg	        M_IFID_Reg	(IFID_PC_add4, IFID_IR, Clk, Rst, IFID_RegWrite, IFID_Flush, PC_add4, IR);

endmodule
