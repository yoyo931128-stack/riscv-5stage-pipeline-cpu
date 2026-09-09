module Hazard_Unit(PC_Write_H, IFID_RegWrite_H, HAZARD_Control, ID_Rs, ID_Rt, IDEX_Rd, IDEX_MemRead);
    output reg PC_Write_H;
    output reg IFID_RegWrite_H;
    output reg HAZARD_Control;

    input  [4:0] ID_Rs;
    input  [4:0] ID_Rt;
    input  [4:0] IDEX_Rd;      // Rt->Rd
    input        IDEX_MemRead;

    always @(*) begin 
        if (IDEX_MemRead == 1'b1 && (IDEX_Rd != 5'b00000) && (IDEX_Rd == ID_Rt || IDEX_Rd == ID_Rs)) begin
            PC_Write_H      = 1'b1;  // 1:latch PC (Stall)
            IFID_RegWrite_H = 1'b1;  // 1:latch IF/ID register
            HAZARD_Control  = 1'b1;  // 1:ID/EX control siginal clear (insert NOP)
        end else begin
            PC_Write_H      = 1'b0;
            IFID_RegWrite_H = 1'b0;
            HAZARD_Control  = 1'b0;
        end 
    end
endmodule