module WB_Stage(WB_RegWrite, WB_WriteData, WB_WriteReg_Out, MEMWB_WB, MEMWB_RamData, MEMWB_ALU_Result, MEMWB_PC_add4,MEMWB_CSR_Read_Data, MEMWB_WriteReg_In);

output        WB_RegWrite;
output [31:0] WB_WriteData;
output [4 :0] WB_WriteReg_Out;
// MEMWB_WB is expanded to 3 bits: [2] is RegWrite, [1:0] is WBSrc
input  [2 :0] MEMWB_WB;         
input  [31:0] MEMWB_RamData;
input  [31:0] MEMWB_ALU_Result;
input  [31:0] MEMWB_PC_add4;    // The return address for JAL/JALR
input  [31:0] MEMWB_CSR_Read_Data;
input  [4 :0] MEMWB_WriteReg_In;
assign WB_RegWrite     = MEMWB_WB[2];
assign WB_WriteReg_Out = MEMWB_WriteReg_In;
wire [1:0] WBSrc = MEMWB_WB[1:0];
//=======================================================
// 3-way Multiplexer for Write Back Data
// 2'b01 -> Memory Data (Load)
// 2'b10 -> PC + 4 (JAL, JALR)
// 2'b00 -> ALU Result (R-Type, I-Type)
//=======================================================
assign WB_WriteData = (WBSrc == 2'b00) ? MEMWB_ALU_Result :
                      (WBSrc == 2'b01) ? MEMWB_RamData    :
                      (WBSrc == 2'b10) ? MEMWB_PC_add4    :
                                         MEMWB_CSR_Read_Data;
endmodule