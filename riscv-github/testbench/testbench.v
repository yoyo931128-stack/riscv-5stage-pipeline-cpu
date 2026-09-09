`timescale 1ns/10ps
module testbench();

reg     Clk;
reg     Rst;
reg     External_interrupt_W;

wire    [7:0] MEM4;
wire    [7:0] MEM5;
wire    [7:0] MEM6;
wire    [7:0] MEM7;

wire    [31:0] Reg0_Zero;
wire    [31:0] Reg1_Counter;
wire    [31:0] Reg2_Sum;
wire    [31:0] Reg3_BaseAddr;
wire    [31:0] Reg4_LoadData;
wire    [31:0] Reg5_ReturnAddr;
RISCV_Core    M_CPU(Clk, Rst, External_interrupt_W);
assign  MEM4 = M_CPU.M_MEM_Stage.M_Data_MEM.D_MEM[4];
assign  MEM5 = M_CPU.M_MEM_Stage.M_Data_MEM.D_MEM[5];
assign  MEM6 = M_CPU.M_MEM_Stage.M_Data_MEM.D_MEM[6];
assign  MEM7 = M_CPU.M_MEM_Stage.M_Data_MEM.D_MEM[7];
assign  Reg0_Zero       = M_CPU.M_ID_Stage.M_Register_Unit.Register[0];
assign  Reg1_Counter    = M_CPU.M_ID_Stage.M_Register_Unit.Register[1];
assign  Reg2_Sum        = M_CPU.M_ID_Stage.M_Register_Unit.Register[2];
assign  Reg3_BaseAddr   = M_CPU.M_ID_Stage.M_Register_Unit.Register[3];
assign  Reg4_LoadData   = M_CPU.M_ID_Stage.M_Register_Unit.Register[4];
assign  Reg5_ReturnAddr = M_CPU.M_ID_Stage.M_Register_Unit.Register[5];
initial begin
    Clk = 0; 
    External_interrupt_W = 0;
    Rst = 1;
    #250 Rst = 0;                 
    #20000 $stop;
end
initial begin
    $dumpfile("testRISCV.vcd"); 
    $dumpvars(0, testbench);
end
always #100 Clk = ~Clk;

endmodule