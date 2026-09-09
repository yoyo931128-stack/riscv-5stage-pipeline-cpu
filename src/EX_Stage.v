module EX_Stage(EXMEM_WB, EXMEM_M, EXMEM_ALU_Result, EXMEM_RtData, EX_WriteReg, EXMEM_WriteReg, EXMEM_PC_add4,EXMEM_CSR_Write_Enable, EXMEM_CSR_Op, EXMEM_CSR_Write_Data,EXMEM_CSR_Address,
                Clk, Rst, IDEX_WB, IDEX_M, IDEX_EX, IDEX_ReadData1, IDEX_ReadData2, WB_WriteData, IDEX_ExtendData, IDEX_Rs, IDEX_Rt, IDEX_Rd, IDEX_PC_add4, WB_WriteReg, WB_RegWrite, EXMEM_Flush_E,IDEX_CSR_Write_Enable, IDEX_CSR_Imm_Sel, IDEX_CSR_Op);

output  [2 :0] EXMEM_WB;
output  [6 :0] EXMEM_M;         
output  [31:0] EXMEM_ALU_Result;
output  [31:0] EXMEM_RtData;
output  [4 :0] EX_WriteReg;   
output  [4 :0] EXMEM_WriteReg; 
output  [31:0] EXMEM_PC_add4;
output         EXMEM_CSR_Write_Enable;
output  [1 :0] EXMEM_CSR_Op;
output  [31:0] EXMEM_CSR_Write_Data;
output  [11:0] EXMEM_CSR_Address;
input          Clk;
input          Rst;
input   [2 :0] IDEX_WB;   
input   [6 :0] IDEX_M;          
input   [7 :0] IDEX_EX;   
input   [31:0] IDEX_ReadData1;
input   [31:0] IDEX_ReadData2;
input   [31:0] IDEX_ExtendData;
input   [4 :0] IDEX_Rs;
input   [4 :0] IDEX_Rt;
input   [4 :0] IDEX_Rd;
input   [31:0] IDEX_PC_add4;
input   [31:0] WB_WriteData;
input   [4 :0] WB_WriteReg;
input          WB_RegWrite;
input          EXMEM_Flush_E;
input          IDEX_CSR_Write_Enable;
input          IDEX_CSR_Imm_Sel;
input   [1 :0] IDEX_CSR_Op;
wire    [31:0] ALU_Result;
wire    [31:0] ALU_Data1;
wire    [31:0] ALU_Data2;
wire    [31:0] Forwarded_Data1; //Forwarding provisional result
wire    [31:0] Forwarded_Data2; 
wire    [1 :0] ForwardA;
wire    [1 :0] ForwardB;
wire    [3 :0] ALU_Action;
wire           ALUSrcB;         
wire           ALUSrcA;         //PC/rs1 
wire           EXMEM_RegWrite_Out;
wire    [31:0] EX_CSR_Write_Data;
//=======================================================
// Control Signals Decoding
// IDEX_EX is defined as {ALUSrcB(7), ALUSrcA(6), 2'b00, ALU_Action(3:0)}
//=======================================================
assign ALUSrcB    = IDEX_EX[7];
assign ALUSrcA    = IDEX_EX[6]; 
assign ALU_Action = IDEX_EX[3:0];

// RISC-V destination register is ALWAYS rd
assign EX_WriteReg = IDEX_Rd; 

// Extract RegWrite from EX/MEM stage for Forwarding Unit
assign EXMEM_RegWrite_Out = EXMEM_WB[2];

//=======================================================
// Forwarding Unit
//=======================================================
Forward M_Forward(ForwardA, ForwardB, EXMEM_RegWrite_Out, WB_RegWrite, EXMEM_WriteReg, WB_WriteReg, IDEX_Rs, IDEX_Rt);

//=======================================================
// MUX for Forwarded_Data1 (ForwardA Selection)
// ForwardA == 2'b10 -> Data from EX/MEM stage
// ForwardA == 2'b01 -> Data from MEM/WB stage
// ForwardA == 2'b00 -> Original read data
//=======================================================
assign Forwarded_Data1 = (ForwardA == 2'b10) ? EXMEM_ALU_Result :
                         (ForwardA == 2'b01) ? WB_WriteData :
                                               IDEX_ReadData1;
//  When CSR_Imm_Sel is 1, it means that instructions like csrrwi directly zero-extend IDEX_Rs as a 5-bit immediate 
// When CSR_Imm_Sel is 0, it means that instructions like csrrw are higher-order operations: they consume Forwarded_Data1
// -----------------------------------------------------------------
assign EX_CSR_Write_Data = (IDEX_CSR_Imm_Sel == 1'b1) ? {27'b0, IDEX_Rs} : Forwarded_Data1;
//=======================================================
// MUX for ALU_Data1 (ALUSrcA Selection)
// ALUSrcA == 1 -> Current PC (IDEX_PC_add4 - 4), used for AUIPC
// ALUSrcA == 0 -> Forwarded rs1 data
//=======================================================
assign ALU_Data1 = (ALUSrcA == 1'b1) ? (IDEX_PC_add4 - 32'h4) : Forwarded_Data1;

//=======================================================
// MUX for Forwarded_Data2 (ForwardB Selection)
// This resolves hazards for ALU Source 2 AND Store Instructions!
//=======================================================
assign Forwarded_Data2 = (ForwardB == 2'b10) ? EXMEM_ALU_Result :
                         (ForwardB == 2'b01) ? WB_WriteData :
                                               IDEX_ReadData2;

//=======================================================
// MUX for ALUSrcB (Immediate vs Forwarded Register Data)
//=======================================================
assign ALU_Data2 = (ALUSrcB == 1'b1) ? IDEX_ExtendData : Forwarded_Data2;

//=======================================================
// ALU Instantiation
//=======================================================
ALU M_ALU(ALU_Result, ALU_Action, ALU_Data1, ALU_Data2);

//=======================================================
// Pipeline Register: EX/MEM
//=======================================================
EXMEM_Reg M_EXMEM_Reg(
    .EXMEM_M(EXMEM_M),
    .EXMEM_WB(EXMEM_WB),
    .EXMEM_ALU_Result(EXMEM_ALU_Result),
    .EXMEM_RtData(EXMEM_RtData),         
    .EXMEM_WriteReg(EXMEM_WriteReg),
    .EXMEM_PC_add4(EXMEM_PC_add4),
    .EXMEM_CSR_Write_Enable(EXMEM_CSR_Write_Enable),
    .EXMEM_CSR_Op(EXMEM_CSR_Op),
    .EXMEM_CSR_Write_Data(EXMEM_CSR_Write_Data),
    .EXMEM_CSR_Address(EXMEM_CSR_Address), 
    .Clk(Clk), 
    .Rst(Rst),
    .IDEX_WB(IDEX_WB),
    .IDEX_M(IDEX_M),
    .ALU_Result(ALU_Result),
    .RtData(Forwarded_Data2),            
    .EX_WriteReg(EX_WriteReg),
    .IDEX_PC_add4(IDEX_PC_add4),
    .EXMEM_Flush_E(EXMEM_Flush_E),
    .IDEX_CSR_Write_Enable(IDEX_CSR_Write_Enable),
    .IDEX_CSR_Op(IDEX_CSR_Op),
    .EX_CSR_Write_Data(EX_CSR_Write_Data),
    .EX_CSR_Address(IDEX_ExtendData[11:0]) 
);   
endmodule