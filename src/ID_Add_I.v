module ID_Add_I(PC_Branch,IFID_PC_add4,Immediate_E);
output	  [31:0]	PC_Branch;
input	   [31:0]	IFID_PC_add4;
input	   [31:0]	Immediate_E;

assign PC_Branch = (IFID_PC_add4 - 32'h4) + Immediate_E;

endmodule