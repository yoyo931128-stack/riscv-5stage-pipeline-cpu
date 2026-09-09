module Control_Unit(WB,M,EX,ImmSel,PC_W_jalr,PC_W_jal,PC_W_Jump,PC_W_Branch,IR_Read,Illegal_OP_W,ECALL_W,EBREAK_W,CSR_Write_Enable, CSR_Imm_Sel, CSR_Op,opcode,funct3,funct7_5,funct12);
    output reg [2:0] WB;        // [2]: RegWrite, [1:0]: WBSrc (00: ALU, 01: Mem, 10: PC+4)
    output reg [6:0] M;        // [6]: Branch, [5]: MemRead, [4]: MemWrite, [3]: Unsigned, [2:1]: Size (00:Byte, 01:Halfword, 10:Word), [0]: Reserved
    output reg [7:0] EX;        // [7]: ALUSrcB (0:rs2, 1:Imm), [6]: ALUSrcA (0:rs1, 1:PC), [5:4]: Reserved, [3:0]: ALU_Action
    output reg [2:0] ImmSel;     // Immediate Generation Select
    output reg       PC_W_jalr;  // JALR flag
    output reg       PC_W_jal;    // JAL flag
    output reg       PC_W_Jump;  // Jump flag for both JAL/JALR
    output reg       PC_W_Branch; // Branch flag
    output reg       IR_Read;    // Instruction Read Enable
    output reg       Illegal_OP_W;// Illegal Opcode Exception flag
    output reg       ECALL_W;     // Environment Call (ECALL) flag
    output reg       EBREAK_W;    // Environment Break (EBREAK) flag
    output reg       CSR_Write_Enable; 
    output reg       CSR_Imm_Sel;      // 0: from rs1, 1: from 5-bit immediate
    output reg [1:0] CSR_Op;
    input      [6:0] opcode;     
    input      [2:0] funct3;     
    input            funct7_5;    // Bit 5 of funct7 (used for SUB/SRA)
    input     [11:0] funct12;      // Upper 12 bits (used for SYS instructions like ECALL/EBREAK)


//=======================================================
// RISC-V RV32I Opcodes
//=======================================================
parameter R_TYPE  = 7'b0110011; // add, sub, and, or, slt, sltu...
parameter I_TYPE  = 7'b0010011; // addi, andi, ori, slti, sltiu...
parameter LOAD    = 7'b0000011; // lw, lh, lb, lhu, lbu
parameter STORE   = 7'b0100011; // sw, sh, sb
parameter BRANCH  = 7'b1100011; // beq, bne, blt, bge, bltu, bgeu
parameter JAL     = 7'b1101111; // jal
parameter JALR    = 7'b1100111; // jalr
parameter LUI     = 7'b0110111; // lui
parameter AUIPC   = 7'b0010111; // auipc
parameter SYS     = 7'b1110011; // ecall, ebreak, fence

//=======================================================
// Immediate Generation Select (ImmSel)
//=======================================================
parameter IMM_I = 3'd0;
parameter IMM_S = 3'd1;
parameter IMM_B = 3'd2;
parameter IMM_J = 3'd3;
parameter IMM_U = 3'd4;

//=======================================================
// ALU Action Definitions
//=======================================================
parameter ALU_ADD  = 4'b0000;
parameter ALU_SUB  = 4'b0001;
parameter ALU_AND  = 4'b0010;
parameter ALU_OR   = 4'b0011;
parameter ALU_XOR  = 4'b0100;
parameter ALU_SLL  = 4'b0101;
parameter ALU_SRL  = 4'b0110;
parameter ALU_SRA  = 4'b0111;
parameter ALU_SLT  = 4'b1000; // Signed less than
parameter ALU_PASS_B = 4'b1001; // Pass Data2 (used for LUI)
parameter ALU_SLTU = 4'b1010; // Unsigned less than

reg [3:0] alu_action_temp;

always @(*) begin
    // ---------------------------------------------------
    // 1. Default Values (Prevents Inferred Latches)
    // ---------------------------------------------------
    WB           = 3'b000;
    M            = 7'b0000000;  
    EX           = 8'b00000000; 
    ImmSel       = IMM_I; 
    PC_W_jalr    = 1'b0;
    PC_W_jal     = 1'b0;
    PC_W_Jump    = 1'b0;
    PC_W_Branch  = 1'b0;
    IR_Read      = 1'b1;
    Illegal_OP_W = 1'b0;
    ECALL_W      = 1'b0;
    EBREAK_W     = 1'b0;
    alu_action_temp = ALU_ADD;
    CSR_Write_Enable = 1'b0;
    CSR_Imm_Sel      = 1'b0;
    CSR_Op           = 2'b00;
    // ---------------------------------------------------
    // 2. Opcode Decoding
    // ---------------------------------------------------
    case(opcode)
        7'b0000000: begin
            // NOP / Bubble (Default values apply)
        end
        
        R_TYPE: begin  
            WB = 3'b100; // RegWrite=1, WBSrc=00(ALU)
            case(funct3)
                3'b000: alu_action_temp = (funct7_5) ? ALU_SUB : ALU_ADD;
                3'b111: alu_action_temp = ALU_AND;
                3'b110: alu_action_temp = ALU_OR;
                3'b100: alu_action_temp = ALU_XOR;
                3'b001: alu_action_temp = ALU_SLL;
                3'b101: alu_action_temp = (funct7_5) ? ALU_SRA : ALU_SRL;
                3'b010: alu_action_temp = ALU_SLT;
                3'b011: alu_action_temp = ALU_SLTU; // SLTU (Unsigned)
                default: alu_action_temp = ALU_ADD;
            endcase
            // EX = {ALUSrcB(0), ALUSrcA(0), 2'b00, ALU_Action}
            EX = {1'b0, 1'b0, 2'b00, alu_action_temp}; 
        end
        
        I_TYPE: begin  
            WB     = 3'b100; // RegWrite=1, WBSrc=00(ALU)
            ImmSel = IMM_I; 
            case(funct3)
                3'b000: alu_action_temp = ALU_ADD;  // ADDI
                3'b111: alu_action_temp = ALU_AND;  // ANDI
                3'b110: alu_action_temp = ALU_OR;   // ORI
                3'b100: alu_action_temp = ALU_XOR;  // XORI
                3'b001: alu_action_temp = ALU_SLL;  // SLLI
                3'b101: alu_action_temp = (funct7_5) ? ALU_SRA : ALU_SRL; // SRAI / SRLI
                3'b010: alu_action_temp = ALU_SLT;  // SLTI
                3'b011: alu_action_temp = ALU_SLTU; // SLTIU (Unsigned)
                default: alu_action_temp = ALU_ADD;
            endcase
            // EX = {ALUSrcB(1), ALUSrcA(0), 2'b00, ALU_Action}
            EX = {1'b1, 1'b0, 2'b00, alu_action_temp}; 
        end
        
       LOAD: begin  
            ImmSel = IMM_I;
            case(funct3)
                3'b000: begin M = 7'b0_1_0_0_00_0; WB = 3'b101; EX = {1'b1, 1'b0, 2'b00, ALU_ADD}; end // LB
                3'b001: begin M = 7'b0_1_0_0_01_0; WB = 3'b101; EX = {1'b1, 1'b0, 2'b00, ALU_ADD}; end // LH
                3'b010: begin M = 7'b0_1_0_0_10_0; WB = 3'b101; EX = {1'b1, 1'b0, 2'b00, ALU_ADD}; end // LW
                3'b100: begin M = 7'b0_1_0_1_00_0; WB = 3'b101; EX = {1'b1, 1'b0, 2'b00, ALU_ADD}; end // LBU
                3'b101: begin M = 7'b0_1_0_1_01_0; WB = 3'b101; EX = {1'b1, 1'b0, 2'b00, ALU_ADD}; end // LHU
                default:begin M = 7'b0_1_0_0_10_0; WB = 3'b101; EX = {1'b1, 1'b0, 2'b00, ALU_ADD}; end
            endcase
        end
        
       STORE: begin  
            WB     = 3'b000; // RegWrite=0
            ImmSel = IMM_S;
            EX     = {1'b1, 1'b0, 2'b00, ALU_ADD};
            
            // M = {Branch, MemRead, MemWrite, Unsigned, Size[1:0], 1'b0}
            case(funct3)
                3'b000: M = 7'b0_0_1_0_00_0; // SB 
                3'b001: M = 7'b0_0_1_0_01_0; // SH 
                3'b010: M = 7'b0_0_1_0_10_0; // SW 
                default: M = 7'b0_0_1_0_10_0; 
            endcase
        end
        
        BRANCH: begin  
            M           = 7'b1_0_0_0_00_0; // Branch=1
            ImmSel      = IMM_B;
            PC_W_Branch = 1'b1;
            EX          = {1'b0, 1'b0, 2'b00, ALU_ADD}; 
        end

        LUI: begin
            WB     = 3'b100; // RegWrite=1, WBSrc=00(ALU)
            ImmSel = IMM_U;
            // EX[7] ALUSrcB = 1 (Imm)
            // ALU_PASS_B directly outputs Data2 (the immediate)
            EX     = {1'b1, 1'b0, 2'b00, ALU_PASS_B}; 

        end

        AUIPC: begin 
            WB     = 3'b100; // RegWrite=1, WBSrc=00(ALU)
            ImmSel = IMM_U;
            // EX[7] ALUSrcB = 1 (Imm)
            // EX[6] ALUSrcA = 1 (PC)
            // ALU performs PC + Imm
            EX     = {1'b1, 1'b1, 2'b00, ALU_ADD}; 
        end

        JAL: begin
            WB        = 3'b110; // RegWrite=1, WBSrc=10(PC+4)
            ImmSel    = IMM_J;
            PC_W_jal  = 1'b1;
            PC_W_Jump = 1'b1;
            EX        = {1'b0, 1'b0, 2'b00, ALU_ADD}; 
        end

        JALR: begin
            WB        = 3'b110; // RegWrite=1, WBSrc=10(PC+4)
            ImmSel    = IMM_I;
            PC_W_jalr = 1'b1;
            PC_W_Jump = 1'b1;   // Trigger jump logic
            EX        = {1'b1, 1'b0, 2'b00, ALU_ADD}; 
        end
        
        SYS: begin
            if (funct3 == 3'b000) begin
                // 1. Non-CSR traditional system interrupt instructions (ECALL, EBREAK)
                EX = {1'b0, 1'b0, 2'b00, ALU_ADD}; 
                case(funct12)
                    12'h000: ECALL_W  = 1'b1;
                    12'h001: EBREAK_W = 1'b1;
                    default: Illegal_OP_W = 1'b1; 
                endcase
            end
            else begin
                // 2. Standard Zicsr Extended Instruction Set (6 instructions in total)
                // Setting the WB signal to 3'b111 means: Enable general-purpose register write-back (RegWrite=1),
                // and MUX selects the newly added 4th channel (WBSrc=2'b11), storing the old CSR data into rd.
                WB               = 3'b111; 
                CSR_Write_Enable = 1'b1;  
                
                // csrrw(001)/csrrs(010)/csrrc(011)   -> funct3[2] = 0 (rs1)
                // csrrwi(101)/csrrsi(110)/csrrci(111) -> funct3[2] = 1 (5-bit immediate)
                CSR_Imm_Sel      = funct3[2]; 
                
                // 2'b01: Write, 2'b10: Set, 2'b11: Clear
                CSR_Op           = funct3[1:0]; 
                
                // CSR instructions do not perform their main operations through the regular ALU.
                EX               = {1'b0, 1'b0, 2'b00, ALU_ADD}; 
            end
        end
        
        default: begin   
            Illegal_OP_W = 1'b1; // Illegal Opcode Exception
        end
    endcase
end
endmodule