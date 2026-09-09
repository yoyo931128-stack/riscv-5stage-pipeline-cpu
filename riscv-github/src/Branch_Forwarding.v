module Branch_Forwarding(ForwardC, ForwardD, EXMEM_RegWrite, EXMEM_WriteReg, WB_RegWrite, WB_WriteReg, ID_Rs, ID_Rt);
    // 2'b10:  EX/MEM forward
    // 2'b01:  MEM/WB forward
    // 2'b00:  Register value
    output reg [1:0] ForwardC;
    output reg [1:0] ForwardD;
    
    input        EXMEM_RegWrite;
    input  [4:0] EXMEM_WriteReg;
    input        WB_RegWrite;
    input  [4:0] WB_WriteReg;
    input  [4:0] ID_Rs;
    input  [4:0] ID_Rt;

    always @(*) begin
        // ForwardC Logic (For Branch Rs1)
        ForwardC = 2'b00;
        if (EXMEM_RegWrite == 1'b1 && EXMEM_WriteReg != 5'd0 && EXMEM_WriteReg == ID_Rs)
            ForwardC = 2'b10;
        else if (WB_RegWrite == 1'b1 && WB_WriteReg != 5'd0 && WB_WriteReg == ID_Rs)
            ForwardC = 2'b01;
        
        // ForwardD Logic (For Branch Rs2)
        ForwardD = 2'b00;
        if (EXMEM_RegWrite == 1'b1 && EXMEM_WriteReg != 5'd0 && EXMEM_WriteReg == ID_Rt)
            ForwardD = 2'b10;
        else if (WB_RegWrite == 1'b1 && WB_WriteReg != 5'd0 && WB_WriteReg == ID_Rt)
            ForwardD = 2'b01;
    end
endmodule