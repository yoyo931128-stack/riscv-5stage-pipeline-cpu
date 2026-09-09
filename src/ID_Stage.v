module ID_Stage(
    PC_Sel, PC_Write, IR_Read, IFID_RegWrite, IFID_Flush_BJ, PC_BJ, IDEX_WB, IDEX_M, IDEX_EX,
    IDEX_ReadData1, IDEX_ReadData2, IDEX_ExtendData, IDEX_Rs, IDEX_Rt, IDEX_Rd, IDEX_PC_add4,IDEX_CSR_Write_Enable, IDEX_CSR_Imm_Sel, IDEX_CSR_Op, 
    Illegal_OP_W, ECALL_W, EBREAK_W,Clk, Rst, IFID_IR, IFID_PC_add4, WB_RegWrite, WB_WriteReg, WB_WriteData,
    EXMEM_WB, EXMEM_M, EXMEM_ALU_Result, EXMEM_WriteReg, IDEX_Flush_E);

// =======================================================
// Ports Declaration
// =======================================================
output        PC_Sel;
output        PC_Write;
output        IR_Read;
output        IFID_RegWrite;
output        IFID_Flush_BJ;
output [31:0] PC_BJ;
output [2 :0] IDEX_WB; 
output [6 :0] IDEX_M;         
output [7 :0] IDEX_EX;
output [31:0] IDEX_ReadData1;
output [31:0] IDEX_ReadData2;
output [31:0] IDEX_ExtendData;
output [4 :0] IDEX_Rs;
output [4 :0] IDEX_Rt;
output [4 :0] IDEX_Rd;
output [31:0] IDEX_PC_add4;
output        Illegal_OP_W;
output        ECALL_W;       
output        EBREAK_W;        
output        IDEX_CSR_Write_Enable;
output        IDEX_CSR_Imm_Sel;
output [1 :0] IDEX_CSR_Op;
input         Clk;
input         Rst;
input  [31:0] IFID_IR;
input  [31:0] IFID_PC_add4;
input         WB_RegWrite;
input  [4 :0] WB_WriteReg;
input  [31:0] WB_WriteData;

input  [2 :0] EXMEM_WB;
input  [6 :0] EXMEM_M;         
input  [31:0] EXMEM_ALU_Result;
input  [4 :0] EXMEM_WriteReg;
input         IDEX_Flush_E;

// =======================================================
// Wire Declarations
// =======================================================
wire   [31:0] ReadData1, ReadData2;
wire   [6 :0] ID_OPcode, ID_Funct7;
wire   [4 :0] ID_Rs, ID_Rt, ID_Rd;
wire   [2 :0] ID_Funct3;
wire   [11:0] ID_Funct12;     
wire          PC_W_Jump, PC_W_Branch, PC_W_jr, PC_W_jal;
wire   [2 :0] WB, ID_WB, ImmSel;
wire   [6 :0] M, ID_M;        
wire   [7 :0] EX, ID_EX;
wire   [17:0] ControlSignal;   //3(WB) + 7(M) + 8(EX) = 18 bits
wire          HAZARD_Control;
wire          IDEX_MemRead, IDEX_MemWrite;
wire   [31:0] Immediate_E, PC_Branch;
wire          Branch_Take; 
wire          PC_Write_B, PC_Write_H;
wire          IFID_RegWrite_H, IFID_RegWrite_B;
wire          IDEX_Flush, IDEX_Flush_B;
wire          ID_CSR_Write_Enable;
wire          ID_CSR_Imm_Sel;
wire   [1 :0] ID_CSR_Op;
// --- ID Forwarding Wires ---
wire   [1 :0] ForwardC, ForwardD;
wire   [31:0] Comp_Data1, Comp_Data2;
wire          IDEX_RegWrite  = IDEX_WB[2];
wire          EXMEM_RegWrite = EXMEM_WB[2];

wire          EXMEM_MemRead  = EXMEM_M[5]; 

// =======================================================
// RISC-V Instruction Decode
// =======================================================
assign ID_OPcode  = IFID_IR[6:0];    
assign ID_Rd      = IFID_IR[11:7];   
assign ID_Funct3  = IFID_IR[14:12];  
assign ID_Rs      = IFID_IR[19:15];  
assign ID_Rt      = IFID_IR[24:20];  
assign ID_Funct7  = IFID_IR[31:25];  
assign ID_Funct12 = IFID_IR[31:20];  

// =======================================================
// Invalid Register Filter (Prevents False Hazards)
// =======================================================
// U-Type (LUI, AUIPC) and J-Type (JAL) do not use rs1

wire rs1_valid = (ID_OPcode != 7'b0110111) && (ID_OPcode != 7'b1101111) && (ID_OPcode != 7'b0010111); 
// Only R-Type, S-Type, and B-Type use rs2
wire rs2_valid = (ID_OPcode == 7'b0110011) || (ID_OPcode == 7'b0100011) || (ID_OPcode == 7'b1100011); 

wire [4:0] safe_ID_Rs = rs1_valid ? ID_Rs : 5'b00000;
wire [4:0] safe_ID_Rt = rs2_valid ? ID_Rt : 5'b00000;

// =======================================================
// Pipeline & Control Assignments
// =======================================================

assign IDEX_MemRead  = IDEX_M[5]; 
assign IDEX_MemWrite = IDEX_M[4];

assign ID_WB         = ControlSignal[17:15];
assign ID_M          = ControlSignal[14:8];
assign ID_EX         = ControlSignal[7:0];

assign IDEX_Flush    = IDEX_Flush_B | IDEX_Flush_E;
assign IFID_RegWrite = (IFID_RegWrite_H | IFID_RegWrite_B);
assign PC_Write      = ~(PC_Write_H | PC_Write_B);
// =======================================================
// Branch and Jump Target Selection
// =======================================================
wire [31:0] JALR_Target;
assign JALR_Target = (Comp_Data1 + Immediate_E) & 32'hFFFF_FFFE;
assign PC_Sel = (PC_W_Jump | PC_W_jr) ? 1'b1 : (PC_W_Branch & Branch_Take) ? 1'b1 : 1'b0;


assign PC_BJ  = (PC_Sel==1'b1 && PC_W_jr==1'b1)     ? JALR_Target: // JALR: (rs1 + Imm) & ~1
                (PC_Sel==1'b1 && PC_W_Jump==1'b1)   ? PC_Branch :  // JAL: PC + Imm
                (PC_Sel==1'b1 && PC_W_Branch==1'b1) ? PC_Branch :  // Branch: PC + Imm
                32'h0000_0000;

assign IFID_Flush_BJ = (PC_Write_B==1'b0) ? (PC_Sel ? 1'b1 : 1'b0) : 1'b0;

// =======================================================
// ID Forwarding MUX for Branch/JALR
// =======================================================
assign Comp_Data1 = (ForwardC == 2'b10) ? EXMEM_ALU_Result :
                    (ForwardC == 2'b01) ? WB_WriteData : ReadData1;
                    
assign Comp_Data2 = (ForwardD == 2'b10) ? EXMEM_ALU_Result :
                    (ForwardD == 2'b01) ? WB_WriteData : ReadData2;

// =======================================================
// Module Instantiations
// =======================================================
Register_Unit     M_Register_Unit     (ReadData1, ReadData2, Clk, Rst, WB_RegWrite, safe_ID_Rs, safe_ID_Rt, WB_WriteReg, WB_WriteData);

Control_Unit      M_Control_Unit      (WB, M, EX, ImmSel, PC_W_jr, PC_W_jal, PC_W_Jump, PC_W_Branch, IR_Read, Illegal_OP_W, ECALL_W, EBREAK_W,ID_CSR_Write_Enable, ID_CSR_Imm_Sel, ID_CSR_Op, ID_OPcode, ID_Funct3, ID_Funct7[5], ID_Funct12);

wire Stall_Bubble = HAZARD_Control | PC_Write_B;
ControlSignal_MUX M_ControlSignal_MUX (ControlSignal, Stall_Bubble, WB, M, EX);

Hazard_Unit       M_Hazard_Unit       (PC_Write_H, IFID_RegWrite_H, HAZARD_Control, safe_ID_Rs, safe_ID_Rt, IDEX_Rd, IDEX_MemRead);

BranchHazard      M_BranchHazard      (PC_Write_B, IFID_RegWrite_B, IDEX_Flush_B, PC_W_jr, PC_W_Branch, safe_ID_Rs, safe_ID_Rt, IDEX_RegWrite, IDEX_Rd, EXMEM_MemRead, EXMEM_WriteReg);

ImmGen            M_ImmGen            (IFID_IR, ImmSel, Immediate_E);

ID_Add_I          M_ID_Add_I          (PC_Branch, IFID_PC_add4, Immediate_E);

Branch_Forwarding M_Branch_Forwarding (ForwardC, ForwardD, EXMEM_RegWrite, EXMEM_WriteReg, WB_RegWrite, WB_WriteReg, safe_ID_Rs, safe_ID_Rt);

Branch_Comparator M_Branch_Comparator (Comp_Data1, Comp_Data2, ID_Funct3, Branch_Take);

IDEX_Reg          M_IDEX_Reg          (IDEX_WB, IDEX_M, IDEX_EX, IDEX_ReadData1, IDEX_ReadData2, IDEX_ExtendData, IDEX_Rs, IDEX_Rt, IDEX_Rd, IDEX_PC_add4,IDEX_CSR_Write_Enable, IDEX_CSR_Imm_Sel, IDEX_CSR_Op,
                                       Clk, Rst, IDEX_Flush, ID_WB, ID_M, ID_EX,ID_CSR_Write_Enable, ID_CSR_Imm_Sel, ID_CSR_Op, ReadData1, ReadData2, Immediate_E, safe_ID_Rs, safe_ID_Rt, ID_Rd, IFID_PC_add4);
                
endmodule