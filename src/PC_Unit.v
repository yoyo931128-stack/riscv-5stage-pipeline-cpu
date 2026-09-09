module PC_Unit(PC, Clk, Rst, PC_Write, Next_PC);
output	reg [31:0]	PC;
input   		    Clk;
input   		    Rst;
input   		    PC_Write;
input	 [31:0]	Next_PC;

always@(posedge Clk or posedge Rst)begin
        if(Rst==1'b1)begin
                PC<=32'h0000_0000;
                end
        else if(PC_Write==1'b1)begin
                PC<=Next_PC;
                end
        else begin
                PC<=PC;
                end
        end
endmodule

