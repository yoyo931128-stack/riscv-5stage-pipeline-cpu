module MEM_Stage(MEMWB_WB, MEMWB_RamData, MEMWB_ALU_Result, WB_WriteReg, MEMWB_PC_add4,MEMWB_CSR_Read_Data,
                 Clk, Rst, EXMEM_WB, EXMEM_M, EXMEM_ALU_Result, EXMEM_RtData, EXMEM_WriteReg, EXMEM_PC_add4,CSR_Read_Data);

output  [2 :0] MEMWB_WB;          
output  [31:0] MEMWB_RamData;
output  [31:0] MEMWB_ALU_Result;
output  [4 :0] WB_WriteReg;
output  [31:0] MEMWB_PC_add4;     
output  [31:0] MEMWB_CSR_Read_Data;
input          Clk;
input          Rst;
input   [2 :0] EXMEM_WB;
input   [6 :0] EXMEM_M;        
input   [31:0] EXMEM_ALU_Result;
input   [31:0] EXMEM_RtData;
input   [4 :0] EXMEM_WriteReg;
input   [31:0] EXMEM_PC_add4;
input   [31:0] CSR_Read_Data;
wire           D_MEMRead;
wire           D_MEMWrite;
wire    [1 :0] D_MEMSize;       
wire           D_MEMUnsigned;   
wire    [31:0] RamData;
wire    [6 :0] DMEM_Address;
wire    [31:0] DMEM_WriteData;

//=======================================================
// 7-bit M ?[6]: Branch, [5]: MemRead, [4]: MemWrite, [3]: Unsigned, [2:1]: Size, [0]: Reserved
//=======================================================
assign      D_MEMRead      = EXMEM_M[5];
assign      D_MEMWrite     = EXMEM_M[4];
assign      D_MEMUnsigned  = EXMEM_M[3];
assign      D_MEMSize      = EXMEM_M[2:1];
assign      DMEM_Address   = EXMEM_ALU_Result[6:0];
assign      DMEM_WriteData = EXMEM_RtData;

Data_MEM    M_Data_MEM(RamData, Clk, Rst, D_MEMWrite, D_MEMRead, D_MEMSize, D_MEMUnsigned, DMEM_Address, DMEM_WriteData);

MEMWB_Reg   M_MEMWB_Reg(MEMWB_WB, MEMWB_RamData, MEMWB_ALU_Result, WB_WriteReg, MEMWB_PC_add4,MEMWB_CSR_Read_Data,
                        Clk, Rst, EXMEM_WB, RamData, EXMEM_ALU_Result, EXMEM_WriteReg, EXMEM_PC_add4,CSR_Read_Data);

endmodule