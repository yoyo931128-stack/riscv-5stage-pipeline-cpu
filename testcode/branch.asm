addi x1, x0, 5 # x1 = 5
addi x2, x0, 5 # x2 = 5
addi x3, x0, 10 # x3 = 10
# 測試 1: Branch Forwarding (EX/MEM 級前推，完全不需 Stall)
add x4, x1, x0 # x4 = 5 + 0 = 5
addi x0, x0, 0 
bne x4, x3, target1
# 應觸發 Branch_Forwarding
addi x5, x0, 1 # 錯誤路徑(硬體出錯才會執行)
addi x5, x0, 2 # 錯誤路徑
target1:
# 測試 2: Branch Hazard (ID/EX 級衝突，硬體必須強迫 Stall 1 週期)
addi x6, x0, 5 # x6 = 5
add x7, x6, x6 # x7 = 10
beq x7, x3, target2 
# 應觸發 BranchHazard 產生 1 週期暫停 (PC_Write_B=1, IFID_RegWrite_B=1)
# 比較 10 == 10 條件成立，跳躍到 target2
addi x5, x0, 4 # 錯誤路徑
addi x5, x0, 5 # 錯誤路徑
target2:
# 測試 3: JALR 指令跳轉與暫存器基底驗證
# 當前 x3 = 10。我們希望 JALR 精確跳躍到下方的 target3 (PC = 0x40)。
# 計算公式：JALR_Target = (x3 + 立即值 54) = 10 + 54 = 64 = 0x40 
jalr x5, 54(x3) # 執行 JALR，同時將返回位址 PC+4 (0x38) 寫入 x5 暫存器 
addi x5, x0, 7 # 錯誤路徑
addi x5, x0, 8 # 錯誤路徑
target3:
# [PC = 0x40] 
end:
jal x0, end