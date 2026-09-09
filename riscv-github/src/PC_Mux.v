module PC_Mux(Next_PC, PC_add4, PC_BJ, PC_Exception, PC_Sel, PC_Exception_W);
output   [31 : 0]	Next_PC;

input	   [31 : 0]	PC_add4, PC_BJ, PC_Exception;
input	 	          PC_Sel, PC_Exception_W;

assign    Next_PC = (PC_Exception_W == 1) ?   PC_Exception :
                    (PC_Sel == 1)         ?   PC_BJ        :   PC_add4;

endmodule