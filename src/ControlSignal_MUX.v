module ControlSignal_MUX(ControlSignal, HAZARD_Control, WB, M, EX);
input         HAZARD_Control;
input   [2:0] WB; // [2]: RegWrite, [1:0]: WBSrc
input   [6:0] M;  // [6]: Branch, [5]: MemRead, [4]: MemWrite, [3]: Unsigned, [2:1]: Size, [0]: Reserved
input   [7:0] EX; // [7]: ALUSrcB, [6]: ALUSrcA, [3:0]: ALU_Action
output [17:0] ControlSignal; 

assign  ControlSignal = (HAZARD_Control == 1'b1) ? 18'b0 : {WB, M, EX};
endmodule