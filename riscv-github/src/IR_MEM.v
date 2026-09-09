module IR_MEM(IR, Clk, Rst, IR_Read, PC);
    output reg [31:0] IR;
    input             Clk;
    input             Rst;
    input             IR_Read;
    input      [31:0] PC;

    parameter Length = 512;
    
    // Declare a memory array with a depth of 512 and a width of 32 bits
    reg [31:0] IRMEM [0:Length-1];

    // Use the initial block to load data from an external file
    // (This is a standard practice supported by simulators like ModelSim or Vivado)
    initial begin
        // "inst.txt" contains the hexadecimal machine code compiled by a RISC-V Assembler
        $readmemh("inst.txt", IRMEM);
    end

    // Instruction memory is usually designed for asynchronous (combinational) read.
    // This allows the IF stage to fetch the instruction immediately within the same clock cycle.
    always @(*) begin
        if (IR_Read == 1'b1) begin
            // Critical modification: Convert byte address to word index (Equivalent to PC / 4)
            // For example: When PC = 0, 4, 8, it precisely reads IRMEM[0], IRMEM[1], IRMEM[2]
            IR = IRMEM[PC[31:2]]; 
        end else begin
            IR = 32'h0000_0000; // Output NOP if IR_Read is disabled
        end
    end
endmodule