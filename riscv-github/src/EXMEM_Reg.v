module EXMEM_Reg( EXMEM_M, EXMEM_WB, EXMEM_ALU_Result, EXMEM_RtData, EXMEM_WriteReg, EXMEM_PC_add4,EXMEM_CSR_Write_Enable, EXMEM_CSR_Op, EXMEM_CSR_Write_Data,EXMEM_CSR_Address,
                  Clk, Rst, IDEX_WB, IDEX_M, ALU_Result, RtData, EX_WriteReg, IDEX_PC_add4, EXMEM_Flush_E,IDEX_CSR_Write_Enable, IDEX_CSR_Op, EX_CSR_Write_Data, EX_CSR_Address);
                  
output reg [6 :0] EXMEM_M;          
output reg [2 :0] EXMEM_WB;         
output reg [31:0] EXMEM_ALU_Result;
output reg [31:0] EXMEM_RtData;
output reg [4 :0] EXMEM_WriteReg;
output reg [31:0] EXMEM_PC_add4;    
output reg        EXMEM_CSR_Write_Enable;
output reg [1 :0] EXMEM_CSR_Op;
output reg [31:0] EXMEM_CSR_Write_Data;
output reg [11:0] EXMEM_CSR_Address;
input         Clk;
input         Rst;
input  [6 :0] IDEX_M;               
input  [2 :0] IDEX_WB;              
input  [31:0] ALU_Result;
input  [31:0] RtData;
input  [4 :0] EX_WriteReg;
input  [31:0] IDEX_PC_add4;         
input         EXMEM_Flush_E;
input             IDEX_CSR_Write_Enable;
input  [1 :0]     IDEX_CSR_Op;
input  [31:0]     EX_CSR_Write_Data;
input  [11:0]     EX_CSR_Address;
always @(posedge Clk or posedge Rst) begin
    if (Rst == 1'b1) begin
        EXMEM_WB         <= 3'b000;
        EXMEM_M          <= 7'b0000000; 
        EXMEM_ALU_Result <= 32'h0000_0000;
        EXMEM_RtData     <= 32'h0000_0000;
        EXMEM_WriteReg   <= 5'b00000;
        EXMEM_PC_add4    <= 32'h0000_0000; 
        EXMEM_CSR_Write_Enable <= 1'b0;
        EXMEM_CSR_Op           <= 2'b00;
        EXMEM_CSR_Write_Data   <= 32'h0000_0000;
        EXMEM_CSR_Address      <= 12'h000;
    end
    else if (EXMEM_Flush_E == 1'b1) begin
        EXMEM_WB         <= 3'b000;
        EXMEM_M          <= 7'b0000000; 
        EXMEM_ALU_Result <= 32'h0000_0000;
        EXMEM_RtData     <= 32'h0000_0000;
        EXMEM_WriteReg   <= 5'b00000;
        EXMEM_PC_add4    <= 32'h0000_0000;
        EXMEM_CSR_Write_Enable <= 1'b0;
        EXMEM_CSR_Op           <= 2'b00;
        EXMEM_CSR_Write_Data   <= 32'h0000_0000; 
        EXMEM_CSR_Address      <= 12'h000;
    end
    else begin
        EXMEM_WB         <= IDEX_WB;
        EXMEM_M          <= IDEX_M;
        EXMEM_ALU_Result <= ALU_Result;
        EXMEM_RtData     <= RtData;
        EXMEM_WriteReg   <= EX_WriteReg;
        EXMEM_PC_add4    <= IDEX_PC_add4;  
        EXMEM_CSR_Write_Enable <= IDEX_CSR_Write_Enable;
        EXMEM_CSR_Op           <= IDEX_CSR_Op;
        EXMEM_CSR_Write_Data   <= EX_CSR_Write_Data;
        EXMEM_CSR_Address      <= EX_CSR_Address;
    end 
end
endmodule