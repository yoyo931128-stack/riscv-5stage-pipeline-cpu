module Data_MEM(RamData, Clk, Rst, D_MEMWrite, D_MEMRead, D_MEMSize, D_MEMUnsigned, DMEM_Address, DMEM_WriteData);
output reg [31:0] RamData; 
input          Rst;
input          Clk;
input          D_MEMWrite;
input          D_MEMRead;
input   [1 :0] D_MEMSize;     //00(Byte), 01(Halfword), 10(Word)
input          D_MEMUnsigned; // 1(Unsigned Zero-extend), 0(Signed Sign-extend)
input   [6 :0] DMEM_Address;  // Byte Address
input   [31:0] DMEM_WriteData;

parameter      Length = 127;

// Declare memory array (128 bytes)
reg     [7:0]  D_MEM [0:Length];

initial begin
    $readmemh("data.txt", D_MEM);
end

wire [7:0] b0 = D_MEM[DMEM_Address];
wire [7:0] b1 = D_MEM[DMEM_Address+1];
wire [7:0] b2 = D_MEM[DMEM_Address+2];
wire [7:0] b3 = D_MEM[DMEM_Address+3];

wire [15:0] hw = {b1, b0};             // Little-Endian Halfword
wire [31:0] wd = {b3, b2, b1, b0};     // Little-Endian Word

//=======================================================
// synchronous Read (Combinational Logic)
//  LB, LH, LW, LBU, LHU
//=======================================================
always @(negedge Clk or posedge Rst) begin
    if (Rst == 1'b1) begin
        RamData <= 32'h0000_0000;
    end
    else if (D_MEMRead == 1'b1) begin
        case (D_MEMSize)
            2'b00: begin // Load Byte
                if (D_MEMUnsigned) RamData <= {24'b0, b0};
                else               RamData <= {{24{b0[7]}}, b0};
            end
            2'b01: begin // Load Halfword
                if (D_MEMUnsigned) RamData <= {16'b0, hw};
                else               RamData <= {{16{hw[15]}}, hw};
            end
            2'b10: begin // Load Word (LW)
                RamData <= wd; 
            end
            default: RamData <= 32'h0000_0000;
        endcase
    end else begin
        RamData <= 32'h0000_0000;
    end
end

//=======================================================
// Synchronous Write
// SB, SH, SW
//=======================================================
always @(negedge Clk) begin 
    if (D_MEMWrite == 1'b1) begin
        case (D_MEMSize)
            2'b00: begin // Store Byte (SB)
                D_MEM[DMEM_Address]   <= DMEM_WriteData[7:0];
            end
            2'b01: begin // Store Halfword (SH)
                D_MEM[DMEM_Address]   <= DMEM_WriteData[7:0];
                D_MEM[DMEM_Address+1] <= DMEM_WriteData[15:8];
            end
            2'b10: begin // Store Word (SW)
                D_MEM[DMEM_Address]   <= DMEM_WriteData[7:0];
                D_MEM[DMEM_Address+1] <= DMEM_WriteData[15:8];
                D_MEM[DMEM_Address+2] <= DMEM_WriteData[23:16];
                D_MEM[DMEM_Address+3] <= DMEM_WriteData[31:24];
            end
        endcase
    end
end

endmodule