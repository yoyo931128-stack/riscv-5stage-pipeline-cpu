module Forward(ForWardA, ForWardB, EXMEM_RegWrite, WB_RegWrite, EXMEM_WriteReg, WB_WriteReg, IDEX_Rs, IDEX_Rt);

output reg [1:0] ForWardA;
output reg [1:0] ForWardB;

input        EXMEM_RegWrite;
input        WB_RegWrite;
input  [4:0] EXMEM_WriteReg;
input  [4:0] WB_WriteReg;
input  [4:0] IDEX_Rs;   // Equivalent to rs1 in RISC-V
input  [4:0] IDEX_Rt;   // Equivalent to rs2 in RISC-V

// Use @(*) to automatically generate combinational logic sensitivity list
always @(*) begin
    
    // Default values: No forwarding, use original register data
    ForWardA = 2'b00;
    ForWardB = 2'b00;

    //=======================================================
    // ForwardA Logic (For Source Register 1 / rs1)
    //=======================================================
    // EX Hazard: Highest priority
    if (EXMEM_RegWrite == 1'b1 && EXMEM_WriteReg != 5'd0 && EXMEM_WriteReg == IDEX_Rs) begin
        ForWardA = 2'b10;
    end 
    // MEM Hazard: Lower priority (only forward if EX Hazard doesn't match)
    else if (WB_RegWrite == 1'b1 && WB_WriteReg != 5'd0 && WB_WriteReg == IDEX_Rs) begin
        ForWardA = 2'b01;
    end

    //=======================================================
    // ForwardB Logic (For Source Register 2 / rs2)
    //=======================================================
    // EX Hazard: Highest priority
    if (EXMEM_RegWrite == 1'b1 && EXMEM_WriteReg != 5'd0 && EXMEM_WriteReg == IDEX_Rt) begin
        ForWardB = 2'b10;
    end 
    // MEM Hazard: Lower priority
    else if (WB_RegWrite == 1'b1 && WB_WriteReg != 5'd0 && WB_WriteReg == IDEX_Rt) begin
        ForWardB = 2'b01;
    end

end
endmodule