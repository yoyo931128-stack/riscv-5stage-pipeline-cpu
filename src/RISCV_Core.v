module RISCV_Core(Clk, Rst, External_interrupt_W);
  input         Clk;
  input         Rst;
  input         External_interrupt_W;

//=======================================================
// Wire Declarations
//=======================================================
  wire          PC_Write;
  wire          IFID_RegWrite;
  wire          IFID_Flush_BJ;
  wire          IFID_Flush_E;
  wire          IDEX_Flush_E;
  wire          EXMEM_Flush_E;
  wire          PC_Exception_W;
  wire  [3 :0]  cause;
  wire          PC_Sel;
  wire          IR_Read;
  wire  [31:0]  PC_BJ;
  wire  [31:0]  IFID_PC_add4;
  wire  [31:0]  IFID_IR;
  wire          WB_RegWrite;
  wire  [4 :0]  WB_WriteReg;
  wire  [31:0]  WB_WriteData;

  wire  [4 :0]  EX_WriteReg;
  wire  [4 :0]  EXMEM_WriteReg;
  wire  [4 :0]  MEMWB_WriteReg; 

// Pipeline Control Signals
  wire  [2 :0]  IDEX_WB;
  wire  [6 :0]  IDEX_M;
  wire  [7 :0]  IDEX_EX;
  wire  [2 :0]  EXMEM_WB;
  wire  [6 :0]  EXMEM_M;
  wire  [2 :0]  MEMWB_WB;

// Pipeline Data Signals
  wire  [31:0]  IDEX_ReadData1;
  wire  [31:0]  IDEX_ReadData2;
  wire  [31:0]  IDEX_ExtendData;
  wire  [4 :0]  IDEX_Rs;
  wire  [4 :0]  IDEX_Rt;
  wire  [4 :0]  IDEX_Rd;

  wire  [31:0]  EXMEM_ALU_Result;
  wire  [31:0]  EXMEM_RtData;
  wire  [31:0]  MEMWB_RamData;
  wire  [31:0]  MEMWB_ALU_Result;
  wire          Illegal_OP_W;
  wire          ECALL_W;        
  wire          EBREAK_W;        
  wire  [31:0]  PC_add4;
  wire  [31:0]  PC_EPC;

// Pipeline PC+4 Signals
  wire  [31:0]  IDEX_PC_add4;
  wire  [31:0]  EXMEM_PC_add4;    
  wire  [31:0]  MEMWB_PC_add4;
  wire  [31:0]  mtvec_out;
  wire  [31:0]  mepc_out;
  wire  [31:0]  mcause_out;
  wire         IDEX_CSR_Write_Enable;
  wire         IDEX_CSR_Imm_Sel;
  wire  [1 :0] IDEX_CSR_Op;

  wire         EXMEM_CSR_Write_Enable;
  wire  [1 :0] EXMEM_CSR_Op;
  wire  [31:0] EXMEM_CSR_Write_Data;
  wire  [11:0] EXMEM_CSR_Address;     
  wire  [31:0] CSR_Read_Data;        
  wire  [31:0] MEMWB_CSR_Read_Data;
//=======================================================
// CSR Read MUX
// Based on the current CSR address at the MEM level, dynamically select the corresponding privileged register value.
//=======================================================
  assign CSR_Read_Data = (EXMEM_CSR_Address == 12'h305) ? mtvec_out  : // mtvec ADDR
                         (EXMEM_CSR_Address == 12'h341) ? mepc_out   : // mepc ADDR
                         (EXMEM_CSR_Address == 12'h342) ? mcause_out : // mcause ADDR
                                                          32'h0000_0000;  
//=======================================================
// Module Instantiations 
//=======================================================

  IF_Stage M_IF_Stage (
    .IFID_PC_add4(IFID_PC_add4),
    .IFID_IR(IFID_IR),
    .PC_add4(PC_add4),
    .Clk(Clk),
    .Rst(Rst),
    .PC_Write(PC_Write),
    .IFID_RegWrite(IFID_RegWrite),
    .IFID_Flush_BJ(IFID_Flush_BJ),
    .IFID_Flush_E(IFID_Flush_E),
    .PC_Sel(PC_Sel),
    .PC_Exception_W(PC_Exception_W),
    .IR_Read(IR_Read),
    .PC_BJ(PC_BJ),
    .PC_Exception(mtvec_out)
  );

  ID_Stage M_ID_Stage (
    .PC_Sel(PC_Sel),
    .PC_Write(PC_Write),
    .IR_Read(IR_Read),
    .IFID_RegWrite(IFID_RegWrite),
    .IFID_Flush_BJ(IFID_Flush_BJ),
    .PC_BJ(PC_BJ),
    .IDEX_WB(IDEX_WB),
    .IDEX_M(IDEX_M),
    .IDEX_EX(IDEX_EX),
    .IDEX_ReadData1(IDEX_ReadData1),
    .IDEX_ReadData2(IDEX_ReadData2),
    .IDEX_ExtendData(IDEX_ExtendData),
    .IDEX_Rs(IDEX_Rs),
    .IDEX_Rt(IDEX_Rt),
    .IDEX_Rd(IDEX_Rd),
    .IDEX_PC_add4(IDEX_PC_add4),
    .IDEX_CSR_Write_Enable(IDEX_CSR_Write_Enable),
    .IDEX_CSR_Imm_Sel(IDEX_CSR_Imm_Sel),
    .IDEX_CSR_Op(IDEX_CSR_Op),
    .Illegal_OP_W(Illegal_OP_W),
    .ECALL_W(ECALL_W),       
    .EBREAK_W(EBREAK_W),     
    .Clk(Clk),               
    .Rst(Rst),               
    .IFID_IR(IFID_IR),
    .IFID_PC_add4(IFID_PC_add4),
    .WB_RegWrite(WB_RegWrite),
    .WB_WriteReg(WB_WriteReg),
    .WB_WriteData(WB_WriteData),
    .EXMEM_WB(EXMEM_WB),
    .EXMEM_M(EXMEM_M),
    .EXMEM_ALU_Result(EXMEM_ALU_Result),
    .EXMEM_WriteReg(EXMEM_WriteReg),
    .IDEX_Flush_E(IDEX_Flush_E)
  );

  EX_Stage M_EX_Stage (
    .EXMEM_WB(EXMEM_WB),
    .EXMEM_M(EXMEM_M),
    .EXMEM_ALU_Result(EXMEM_ALU_Result),
    .EXMEM_RtData(EXMEM_RtData),
    .EX_WriteReg(EX_WriteReg),
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
    .IDEX_EX(IDEX_EX),
    .IDEX_ReadData1(IDEX_ReadData1),
    .IDEX_ReadData2(IDEX_ReadData2),
    .WB_WriteData(WB_WriteData),
    .IDEX_ExtendData(IDEX_ExtendData),
    .IDEX_Rs(IDEX_Rs),
    .IDEX_Rt(IDEX_Rt),
    .IDEX_Rd(IDEX_Rd),
    .IDEX_PC_add4(IDEX_PC_add4),
    .WB_WriteReg(WB_WriteReg),
    .WB_RegWrite(WB_RegWrite),
    .EXMEM_Flush_E(EXMEM_Flush_E),
    .IDEX_CSR_Write_Enable(IDEX_CSR_Write_Enable),
    .IDEX_CSR_Imm_Sel(IDEX_CSR_Imm_Sel),
    .IDEX_CSR_Op(IDEX_CSR_Op)
  );

  MEM_Stage M_MEM_Stage(
    .MEMWB_WB(MEMWB_WB),
    .MEMWB_RamData(MEMWB_RamData),
    .MEMWB_ALU_Result(MEMWB_ALU_Result),
    .WB_WriteReg(MEMWB_WriteReg), 
    .MEMWB_PC_add4(MEMWB_PC_add4),
    .MEMWB_CSR_Read_Data(MEMWB_CSR_Read_Data),
    .Clk(Clk),
    .Rst(Rst),
    .EXMEM_WB(EXMEM_WB),
    .EXMEM_M(EXMEM_M),
    .EXMEM_ALU_Result(EXMEM_ALU_Result),
    .EXMEM_RtData(EXMEM_RtData),
    .EXMEM_WriteReg(EXMEM_WriteReg),
    .EXMEM_PC_add4(EXMEM_PC_add4),
    .CSR_Read_Data(CSR_Read_Data)
  );

  WB_Stage M_WB_Stage(
    .WB_RegWrite(WB_RegWrite), 
    .WB_WriteData(WB_WriteData), 
    .WB_WriteReg_Out(WB_WriteReg), 
    .MEMWB_WB(MEMWB_WB), 
    .MEMWB_RamData(MEMWB_RamData), 
    .MEMWB_ALU_Result(MEMWB_ALU_Result), 
    .MEMWB_PC_add4(MEMWB_PC_add4),
    .MEMWB_CSR_Read_Data(MEMWB_CSR_Read_Data),
    .MEMWB_WriteReg_In(MEMWB_WriteReg) 
  );

  EPC M_EPC(
    .PC_EPC(PC_EPC), 
    .PC_add4(PC_add4), 
    .IFID_PC_add4(IFID_PC_add4), 
    .IDEX_PC_add4(IDEX_PC_add4), 
    .Illegal_OP_W(Illegal_OP_W), 
    .External_interrupt_W(External_interrupt_W),
    .ECALL_W(ECALL_W),   
    .EBREAK_W(EBREAK_W)   
  );

  Cause M_Cause(
    .EXMEM_Flush_E(EXMEM_Flush_E), 
    .IDEX_Flush_E(IDEX_Flush_E), 
    .IFID_Flush_E(IFID_Flush_E), 
    .PC_Exception_W(PC_Exception_W), 
    .cause(cause), 
    .Illegal_OP_W(Illegal_OP_W), 
    .External_interrupt_W(External_interrupt_W),
    .ECALL_W(ECALL_W),   
    .EBREAK_W(EBREAK_W) 
  );

  CSR_Reg M_CSR(
    .Clk(Clk),
    .Rst(Rst),
    .Exception_W(PC_Exception_W),
    .Trap_Cause(cause),
    .Trap_PC(PC_EPC),
    .CSR_Write_Enable(EXMEM_CSR_Write_Enable),
    .CSR_Address(EXMEM_CSR_Address),
    .CSR_Write_Data(EXMEM_CSR_Write_Data),
    .CSR_Op(EXMEM_CSR_Op), 
    .mtvec_out(mtvec_out),
    .mepc_out(mepc_out),
    .mcause_out(mcause_out)
  );
                                        
endmodule