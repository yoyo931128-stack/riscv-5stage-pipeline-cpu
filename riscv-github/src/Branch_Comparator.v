module Branch_Comparator(data1,data2,funct3,branch_take);
    input  [31:0] data1;
    input  [31:0] data2;
    input  [2:0]  funct3;
    output reg    branch_take;

    always @(*) begin
        case(funct3)
            3'b000: branch_take = (data1 == data2);                       // BEQ
            3'b001: branch_take = (data1 != data2);                       // BNE
            3'b100: branch_take = ($signed(data1) < $signed(data2));      // BLT
            3'b101: branch_take = ($signed(data1) >= $signed(data2));     // BGE
            3'b110: branch_take = (data1 < data2);                        // BLTU
            3'b111: branch_take = (data1 >= data2);                       // BGEU
            default: branch_take = 1'b0;
        endcase
    end
endmodule