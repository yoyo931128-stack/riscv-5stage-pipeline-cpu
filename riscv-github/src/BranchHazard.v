module BranchHazard(PC_Write_B, IFID_RegWrite_B, IDEX_Flush_B, PC_W_jr, PC_W_Branch, ID_Rs, ID_Rt, IDEX_RegWrite, IDEX_Rd, EXMEM_MemRead, EXMEM_WriteReg);
    output reg PC_Write_B;
    output reg IFID_RegWrite_B;
    output reg IDEX_Flush_B;
    input       PC_W_jr;
    input       PC_W_Branch; 
    input [4:0] ID_Rs;
    input [4:0] ID_Rt;
    input       IDEX_RegWrite; 
    input [4:0] IDEX_Rd;       
    input       EXMEM_MemRead; 
    input [4:0] EXMEM_WriteReg;

    always @(*) begin
        PC_Write_B      = 1'b0;
        IFID_RegWrite_B = 1'b0;
        IDEX_Flush_B    = 1'b0;
        // JALR(Rs1)
        if (PC_W_jr == 1'b1) begin
            if ((IDEX_RegWrite == 1'b1 && IDEX_Rd != 5'd0 && IDEX_Rd == ID_Rs) || 
                (EXMEM_MemRead == 1'b1 && EXMEM_WriteReg != 5'd0 && EXMEM_WriteReg == ID_Rs)) begin
                PC_Write_B      = 1'b1;
                IFID_RegWrite_B = 1'b1;
                IDEX_Flush_B    = 1'b1;
            end
        end
        // Branch(Rs1,Rs2)
        else if (PC_W_Branch == 1'b1) begin
            if ((IDEX_RegWrite == 1'b1 && IDEX_Rd != 5'd0 && (IDEX_Rd == ID_Rs || IDEX_Rd == ID_Rt)) || 
                (EXMEM_MemRead == 1'b1 && EXMEM_WriteReg != 5'd0 && (EXMEM_WriteReg == ID_Rs || EXMEM_WriteReg == ID_Rt))) begin
                PC_Write_B      = 1'b1;
                IFID_RegWrite_B = 1'b1;
                IDEX_Flush_B    = 1'b1;
            end
        end
    end
endmodule