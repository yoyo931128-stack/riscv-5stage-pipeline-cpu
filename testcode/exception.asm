addi  x1, x0, 0          # x1 = 0
addi  x2, x0, 239        # x2 = 239 (0x0000_00EF)
sw    x2, 0(x1)          # 將 0xEF 寫入 [RAM 地址 0]
auipc x3, 1              # x3 = 0x000C + 0x1000 = 0x0000_100C
lbu   x4, 0(x1)          # x4 = 0x0000_00EF (讀取 RAM 地址 0)

# ------- 6 條 Zicsr 全功能測試鏈（刻意操作 mepc 與 mcause，保留 mtvec 預設值為 0x80） -------
csrrw  x10, 0x341, x2    # 【CSRRW】 讀出 mepc 初始值 (0) 到 x10，並把 x2 (0xEF) 寫入 mepc
csrrs  x11, 0x341, x2    # 【CSRRS】 讀出 mepc 舊值 (0xEF) 到 x11，並與 x2 做 OR，mepc 仍為 0xEF
csrrc  x12, 0x341, x4    # 【CSRRC】 讀出 mepc 舊值 (0xEF) 到 x12，並與 x4 (0xEF) 做 Clear，mepc 清零

csrrwi x13, 0x342, 5     # 【CSRRWI】讀出 mcause 舊值 (0) 到 x13，並把立即值 5 直接寫入 mcause
csrrsi x14, 0x342, 10    # 【CSRRSI】讀出 mcause 舊值 (5) 到 x14，並與立即值 10 (0x0A) 做 OR，mcause 變 15
csrrci x15, 0x342, 3     # 【CSRRCI】讀出 mcause 舊值 (15) 到 x15，並與立即值 3 做 Clear，mcause 變 12 (0x0C)
NOP
NOP
NOP
# ------- 觸發特權異常爆炸點 -------
.word 0x0000007F         # 觸發 Illegal Opcode 異常！
                                            # 當期 PC = 0x0000_0038。
                                            # 系統自動鎖存：mepc_out = 0x38, mcause_out = 2。
                                            # 隨後，PC 強行跳躍到 mtvec 指定的入口：32'h0000_0080。

jal   x0, 0              # 常規防禦迴圈（若無引發異常才會卡在這）

# ------- NOP Slide 軌道（從位址 0x3C 一路補零延伸到 0x80） -------
0x3C ~ 0x7C :NOP                    # 19 條硬體 Bubble/NOP 軌道，用來填補空間至 0x80

# ------- 終點站：中斷向量保護安全區 -------
0x84 : 0000006f -> jal   x0, 0              # 【安全降落點】無限自圈迴圈！
                                            # 當異常噴過來後，PC 會在 0x0000_0084和0x0000_0088之間循環。
                                            