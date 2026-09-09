module EPC(PC_EPC, PC_add4, IFID_PC_add4, IDEX_PC_add4, Illegal_OP_W, External_interrupt_W, ECALL_W, EBREAK_W);
output reg [31:0] PC_EPC;
input  [31:0] PC_add4;
input  [31:0] IFID_PC_add4;
input  [31:0] IDEX_PC_add4;
input         Illegal_OP_W;
input         External_interrupt_W;
input         ECALL_W;   
input         EBREAK_W; 
always @(*) begin
    PC_EPC = 32'h0000_0000;
    // =======================================================
    // For any "synchronization exception" (Illegal OP / EBREAK / ECALL),
    // the value written by mepc must always be the physical PC 
    // =======================================================
    if (Illegal_OP_W == 1'b1 || EBREAK_W == 1'b1 || ECALL_W == 1'b1) begin
        PC_EPC = IFID_PC_add4 - 32'h4; 
    end
    // =======================================================
    // Asynchronous interrupt: Pointer to the address of the next instruction to be executed.
    // =======================================================
    else if (External_interrupt_W == 1'b1) begin
        PC_EPC = IFID_PC_add4; 
    end
end
endmodule