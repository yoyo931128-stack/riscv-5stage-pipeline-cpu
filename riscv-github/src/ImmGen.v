module ImmGen(IFID_IR,ImmSel,Imm_Out);
    input  [31:0] IFID_IR; 
    input  [2:0]  ImmSel;    //Control Unit signal
    output reg [31:0] Imm_Out ;
    
    localparam IMM_I = 3'd0;
    localparam IMM_S = 3'd1;
    localparam IMM_B = 3'd2;
    localparam IMM_J = 3'd3;
    localparam IMM_U = 3'd4;

    always @(*) begin
        case(ImmSel)
            IMM_I: Imm_Out = { {20{IFID_IR[31]}}, IFID_IR[31:20] };
            IMM_S: Imm_Out = { {20{IFID_IR[31]}}, IFID_IR[31:25], IFID_IR[11:7] };
            IMM_B: Imm_Out = { {20{IFID_IR[31]}}, IFID_IR[7], IFID_IR[30:25], IFID_IR[11:8], 1'b0 };
            IMM_J: Imm_Out = { {12{IFID_IR[31]}}, IFID_IR[19:12], IFID_IR[20], IFID_IR[30:21], 1'b0 };
            IMM_U: Imm_Out = { IFID_IR[31:12], 12'b0 };
            default: Imm_Out = 32'b0;
        endcase
    end

endmodule
