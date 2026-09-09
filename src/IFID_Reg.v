module IFID_Reg(IFID_PC_add4, IFID_IR, Clk, Rst, IFID_RegWrite, IFID_Flush, PC_add4, IR);
output  reg [31 : 0]    IFID_PC_add4;
output  reg [31 : 0]    IFID_IR;
input                   Clk;
input                   Rst;
input                   IFID_RegWrite;
input                   IFID_Flush;
input    [31 : 0]       PC_add4;
input    [31 : 0]       IR;

always@(posedge Clk or posedge Rst)begin
        if(Rst==1'b1)begin
                IFID_PC_add4 <= 32'h0000_0000;
                IFID_IR      <= 32'h0000_0000;
        end
        else begin
                if(IFID_Flush==1'b1)begin
                        IFID_PC_add4 <= 32'h0000_0000;
                        IFID_IR      <= 32'h0000_0000;
                end
                else if(IFID_RegWrite==1'b1)begin 
                        IFID_PC_add4 <= IFID_PC_add4;
                        IFID_IR      <= IFID_IR;
                end
                else begin 
                        IFID_PC_add4 <= PC_add4;
                        IFID_IR      <= IR;
                end
        end
end
endmodule