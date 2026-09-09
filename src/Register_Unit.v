module Register_Unit(ReadData1, ReadData2, Clk, Rst, RegWrite, Rs, Rt, WriteReg, WriteData);
    output [31:0] ReadData1;
    output [31:0] ReadData2;
    input         Clk;
    input         Rst;
    input         RegWrite;
    input  [4:0]  Rs;
    input  [4:0]  Rt;
    input  [4:0]  WriteReg;
    input  [31:0] WriteData;

    // Declare the 32 registers, each 32 bits wide
    reg [31:0] Register [0:31];
    integer i;

    //=======================================================
    // Asynchronous Read (Combinational Logic)
    // Ensures data is available immediately in the ID stage.
    // Register x0 (address 0) is hardwired to 0.
    //=======================================================
    assign ReadData1 = (Rs == 5'd0) ? 32'h0000_0000 : Register[Rs];
    assign ReadData2 = (Rt == 5'd0) ? 32'h0000_0000 : Register[Rt];

    //=======================================================
    // Synchronous Write
    // Writing on the negative edge helps resolve Read-After-Write (RAW) 
    // hazards within the same clock cycle in a standard 5-stage pipeline.
    //=======================================================
    always @(negedge Clk or posedge Rst) begin
        if (Rst == 1'b1) begin
            // Clear all registers to 0 on reset
            for (i = 0; i < 32; i = i + 1) begin
                Register[i] <= 32'h0000_0000;
            end
        end else begin
            // Only write if RegWrite is enabled AND the destination is NOT x0
            if (RegWrite == 1'b1 && WriteReg != 5'd0)begin
            Register[WriteReg] <= WriteData;
        end
        end
    end
endmodule