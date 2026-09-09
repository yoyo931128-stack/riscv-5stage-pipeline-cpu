module MEMWB_Reg(MEMWB_WB, MEMWB_RamData, MEMWB_ALU_Result, WB_WriteReg, MEMWB_PC_add4,MEMWB_CSR_Read_Data,
                 Clk, Rst, EXMEM_WB, RamData, EXMEM_ALU_Result, EXMEM_WriteReg, EXMEM_PC_add4,CSR_Read_Data);

output reg [2 :0] MEMWB_WB;
output reg [31:0] MEMWB_RamData;
output reg [31:0] MEMWB_ALU_Result;
output reg [4 :0] WB_WriteReg;
output reg [31:0] MEMWB_PC_add4; 
output reg [31:0] MEMWB_CSR_Read_Data;
input         Clk;
input         Rst;
input  [2 :0] EXMEM_WB;
input  [31:0] RamData;
input  [31:0] EXMEM_ALU_Result;
input  [4 :0] EXMEM_WriteReg;
input  [31:0] EXMEM_PC_add4; 
input  [31:0] CSR_Read_Data;
always @(posedge Clk or posedge Rst) begin
    if (Rst == 1'b1) begin
        MEMWB_WB         <= 3'b000;
        MEMWB_RamData    <= 32'h0000_0000;
        MEMWB_ALU_Result <= 32'h0000_0000;
        WB_WriteReg      <= 5'b00000;
        MEMWB_PC_add4    <= 32'h0000_0000;
        MEMWB_CSR_Read_Data <= 32'h0000_0000; 
    end
    else begin
        MEMWB_WB         <= EXMEM_WB;
        MEMWB_RamData    <= RamData;
        MEMWB_ALU_Result <= EXMEM_ALU_Result;
        WB_WriteReg      <= EXMEM_WriteReg;
        MEMWB_PC_add4    <= EXMEM_PC_add4;
        MEMWB_CSR_Read_Data <= CSR_Read_Data; 
    end
end
endmodule