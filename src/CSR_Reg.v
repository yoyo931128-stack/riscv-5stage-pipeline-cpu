module CSR_Reg(Clk,Rst,Exception_W,Trap_Cause,Trap_PC,CSR_Write_Enable,CSR_Address,CSR_Write_Data,CSR_Op,mtvec_out,mepc_out,mcause_out);
    input         Clk;
    input         Rst;
    input         Exception_W;      // PC_Exception_W
    input  [3:0]  Trap_Cause;        // cause
    input  [31:0] Trap_PC;           // PC_EPC
    input         CSR_Write_Enable;
    input  [11:0] CSR_Address;
    input  [31:0] CSR_Write_Data;
    input  [1:0]  CSR_Op; //01: Write, 10: Set, 11: Clear
    output reg [31:0] mtvec_out;     // Output to PC_Mux as Next_PC
    output reg [31:0] mepc_out;     // Provided for use by the mret command
    output reg [31:0] mcause_out;
    parameter MTVEC_ADDR  = 12'h305;
    parameter MEPC_ADDR   = 12'h341;
    parameter MCAUSE_ADDR = 12'h342;

    always @(posedge Clk or posedge Rst) begin
        if (Rst == 1'b1) begin
            // initial mtvec?avoid 0x0000_0000
            mtvec_out  <= 32'h0000_0080; 
            mepc_out   <= 32'h0000_0000;
            mcause_out <= 32'h0000_0000;
        end 
        else begin
            // when Exception save state
            if (Exception_W == 1'b1) begin
                mepc_out   <= Trap_PC;
                mcause_out <= {28'b0, Trap_Cause}; 
            end
            // Software actively writes (extension functions) using CSR commands.
            else if (CSR_Write_Enable == 1'b1) begin
                case (CSR_Address)
                    MTVEC_ADDR:  mtvec_out  <= (CSR_Op == 2'b10) ? (mtvec_out | CSR_Write_Data) :
                                               (CSR_Op == 2'b11) ? (mtvec_out & ~CSR_Write_Data) : CSR_Write_Data;
                                               
                    MEPC_ADDR:   mepc_out   <= (CSR_Op == 2'b10) ? (mepc_out | CSR_Write_Data) :
                                               (CSR_Op == 2'b11) ? (mepc_out & ~CSR_Write_Data) : CSR_Write_Data;
                                               
                    MCAUSE_ADDR: mcause_out <= (CSR_Op == 2'b10) ? (mcause_out | CSR_Write_Data) :
                                               (CSR_Op == 2'b11) ? (mcause_out & ~CSR_Write_Data) : CSR_Write_Data;
                endcase
            end
        end
    end

endmodule