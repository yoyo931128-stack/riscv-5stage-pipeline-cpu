module Cause(EXMEM_Flush_E, IDEX_Flush_E, IFID_Flush_E, PC_Exception_W, cause,
               Illegal_OP_W, External_interrupt_W, ECALL_W, EBREAK_W);

output reg        EXMEM_Flush_E;
output reg        IDEX_Flush_E;
output reg        IFID_Flush_E;
output reg        PC_Exception_W;
output reg [3:0]  cause; // Expanded to 4 bits for RISC-V mcause codes
input             ECALL_W;   
input             EBREAK_W;
input             Illegal_OP_W;
input             External_interrupt_W;

always @(*) begin
    // 1. Give Default Values to PREVENT Inferred Latches
    EXMEM_Flush_E  = 1'b0;
    IDEX_Flush_E   = 1'b0;
    IFID_Flush_E   = 1'b0;
    PC_Exception_W = 1'b0;
    cause          = 4'd0;
    // 2. Exception/Interrupt Priorities 
    if (External_interrupt_W == 1'b1) begin 
        EXMEM_Flush_E  = 1'b0;
        IDEX_Flush_E   = 1'b0;
        IFID_Flush_E   = 1'b1;  
        PC_Exception_W = 1'b1;
        cause          = 4'd11; 
    end
    else if (Illegal_OP_W == 1'b1) begin
        // Illegal_OP
        EXMEM_Flush_E  = 1'b0;
        IDEX_Flush_E   = 1'b1;  
        IFID_Flush_E   = 1'b1;  
        PC_Exception_W = 1'b1;  
        cause          = 4'd2;  //Illegal Instruction CODE: 2
    end
    else if (EBREAK_W == 1'b1) begin
        //EBREAK 
        EXMEM_Flush_E  = 1'b0;
        IDEX_Flush_E   = 1'b1;  
        IFID_Flush_E   = 1'b1;
        PC_Exception_W = 1'b1;  
        cause          = 4'd3;  //Breakpoint CODE: 3
    end
    else if (ECALL_W == 1'b1) begin
        // ECALL 
        EXMEM_Flush_E  = 1'b0;
        IDEX_Flush_E   = 1'b1; 
        IFID_Flush_E   = 1'b1;
        PC_Exception_W = 1'b1;  
        cause          = 4'd8;  //Environment Call CODE: 8
    end
end
endmodule
