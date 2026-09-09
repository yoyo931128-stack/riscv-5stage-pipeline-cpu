module ALU(ALU_Result, ALU_Action, ALU_Data1, ALU_Data2);
    output reg [31:0] ALU_Result;
    // 4-bit control signal directly from ID/EX pipeline register
    input  [3:0]  ALU_Action; 
    input  [31:0] ALU_Data1;  // Source 1 (rs1 or forwarded data or PC)
    input  [31:0] ALU_Data2;  // Source 2 (rs2, forwarded data, or Immediate)

    //=======================================================
    // ALU Action Parameters (Must match Control_Unit exactly)
    //=======================================================
    parameter ALU_ADD    = 4'b0000;
    parameter ALU_SUB    = 4'b0001;
    parameter ALU_AND    = 4'b0010;
    parameter ALU_OR     = 4'b0011;
    parameter ALU_XOR    = 4'b0100;
    parameter ALU_SLL    = 4'b0101;
    parameter ALU_SRL    = 4'b0110;
    parameter ALU_SRA    = 4'b0111;
    parameter ALU_SLT    = 4'b1000;
    parameter ALU_PASS_B = 4'b1001; // Special action for LUI
    parameter ALU_SLTU   = 4'b1010; 

    // Extract shift amount from the lower 5 bits of ALU_Data2
    wire [4:0] shamt = ALU_Data2[4:0];

    always @(*) begin
        case(ALU_Action)
            ALU_ADD: begin    
                ALU_Result = ALU_Data1 + ALU_Data2;    
            end
            ALU_SUB: begin    
                ALU_Result = ALU_Data1 - ALU_Data2;
            end
            ALU_AND: begin    
                ALU_Result = ALU_Data1 & ALU_Data2;    
            end
            ALU_OR : begin    
                ALU_Result = ALU_Data1 | ALU_Data2;    
            end
            ALU_XOR: begin
                ALU_Result = ALU_Data1 ^ ALU_Data2;
            end
            ALU_SLL: begin    
                // RISC-V shifts Data1 (rs1) by shamt
                ALU_Result = ALU_Data1 << shamt;    
            end
            ALU_SRL: begin    
                // Logical right shift (fills with 0s)
                ALU_Result = ALU_Data1 >> shamt;    
            end
            ALU_SRA: begin
                // Arithmetic right shift (preserves sign bit)
                // $signed() is required for Verilog to use >>> correctly
                ALU_Result = $signed(ALU_Data1) >>> shamt;
            end
            ALU_SLT: begin
                // Set Less Than (Signed comparison)
                ALU_Result = ($signed(ALU_Data1) < $signed(ALU_Data2)) ? 32'h0000_0001 : 32'h0000_0000;
            end
            ALU_SLTU: begin
                // Set Less Than Unsigned (Unsigned comparison)
                ALU_Result = (ALU_Data1 < ALU_Data2) ? 32'h0000_0001 : 32'h0000_0000;
            end
            ALU_PASS_B: begin
                // Directly output Data2 (Used for LUI instruction)
                ALU_Result = ALU_Data2;
            end
            default: begin    
                ALU_Result = 32'h0000_0000;    
            end
        endcase
    end
endmodule