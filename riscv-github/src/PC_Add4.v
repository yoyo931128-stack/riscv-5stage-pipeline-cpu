module PC_Add4(PC_add4, PC);
output	[31:0]	PC_add4;
input	 [31:0]	PC;

assign  PC_add4 = PC+32'h0000_0004;

endmodule
