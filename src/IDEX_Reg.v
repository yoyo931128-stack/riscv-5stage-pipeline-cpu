module IDEX_Reg(IDEX_WB, IDEX_M, IDEX_EX, IDEX_ReadData1, IDEX_ReadData2, IDEX_ExtendData, IDEX_Rs, IDEX_Rt, IDEX_Rd, IDEX_PC_add4,IDEX_CSR_Write_Enable, IDEX_CSR_Imm_Sel, IDEX_CSR_Op,
                Clk, Rst, IDEX_Flush, ID_WB, ID_M, ID_EX,ID_CSR_Write_Enable, ID_CSR_Imm_Sel, ID_CSR_Op, ID_ReadData1, ID_ReadData2, Immediate_E, ID_Rs, ID_Rt, ID_Rd, IFID_PC_add4);
                
output reg [2 :0] IDEX_WB;          
output reg [6 :0] IDEX_M;           
output reg [7 :0] IDEX_EX;          
output reg [31:0] IDEX_ReadData1;
output reg [31:0] IDEX_ReadData2;
output reg [31:0] IDEX_ExtendData;
output reg [4 :0] IDEX_Rs;          
output reg [4 :0] IDEX_Rt;          
output reg [4 :0] IDEX_Rd;          
output reg [31:0] IDEX_PC_add4;     
output reg        IDEX_CSR_Write_Enable;
output reg        IDEX_CSR_Imm_Sel;
output reg [1 :0] IDEX_CSR_Op;
input         Clk;
input         Rst;
input         IDEX_Flush;
input  [2 :0] ID_WB;                
input  [6 :0] ID_M;                 
input  [7 :0] ID_EX;
input  [31:0] ID_ReadData1;
input  [31:0] ID_ReadData2;
input  [31:0] Immediate_E;
input  [4 :0] ID_Rs;
input  [4 :0] ID_Rt;
input  [4 :0] ID_Rd;
input  [31:0] IFID_PC_add4;
input             ID_CSR_Write_Enable;
input             ID_CSR_Imm_Sel;
input  [1 :0]     ID_CSR_Op;
always @(posedge Clk or posedge Rst) begin
    if (Rst == 1'b1) begin
        IDEX_WB         <= 3'b000;  
        IDEX_M          <= 7'b0000000; 
        IDEX_EX         <= 8'b0000_0000;
        IDEX_ReadData1  <= 32'h0000_0000;
        IDEX_ReadData2  <= 32'h0000_0000;
        IDEX_ExtendData <= 32'h0000_0000;
        IDEX_Rs         <= 5'b00000;
        IDEX_Rt         <= 5'b00000;
        IDEX_Rd         <= 5'b00000;
        IDEX_PC_add4    <= 32'h0000_0000;
        IDEX_CSR_Write_Enable <= 1'b0;
        IDEX_CSR_Imm_Sel      <= 1'b0;
        IDEX_CSR_Op           <= 2'b00;
    end else begin
        if (IDEX_Flush == 1'b1) begin
            IDEX_WB         <= 3'b000; 
            IDEX_M          <= 7'b0000000; 
            IDEX_EX         <= 8'b0000_0000;
            IDEX_ReadData1  <= 32'h0000_0000;
            IDEX_ReadData2  <= 32'h0000_0000;
            IDEX_ExtendData <= 32'h0000_0000;
            IDEX_Rs         <= 5'b00000;
            IDEX_Rt         <= 5'b00000;
            IDEX_Rd         <= 5'b00000;
            IDEX_PC_add4    <= 32'h0000_0000;
            IDEX_CSR_Write_Enable <= 1'b0;
            IDEX_CSR_Imm_Sel      <= 1'b0;
            IDEX_CSR_Op           <= 2'b00;
        end else begin
            IDEX_WB         <= ID_WB;
            IDEX_M          <= ID_M;
            IDEX_EX         <= ID_EX;
            IDEX_ReadData1  <= ID_ReadData1;
            IDEX_ReadData2  <= ID_ReadData2;
            IDEX_ExtendData <= Immediate_E;
            IDEX_Rs         <= ID_Rs;
            IDEX_Rt         <= ID_Rt;
            IDEX_Rd         <= ID_Rd;
            IDEX_PC_add4    <= IFID_PC_add4;
            IDEX_CSR_Write_Enable <= ID_CSR_Write_Enable;
            IDEX_CSR_Imm_Sel      <= ID_CSR_Imm_Sel;
            IDEX_CSR_Op           <= ID_CSR_Op;
        end
    end
end
endmodule