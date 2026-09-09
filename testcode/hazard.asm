    addi x1, x0, 1      # x1 = 1
    addi x2, x1, 2      # x2 = x1 + 2 = 3 [Hazard]
    addi x3, x0, 4      # x3 = 4 
    add  x4, x2, x3     # x4 = x2 + x3 = 3 + 4 = 7  [Hazard]
    sw   x4, 0(x0)      # 把 7 寫入記憶體位址 0
    lw   x5, 0(x0)
    add  x6, x5, x5     # x6 = x5 + x5 = 7 + 7 = 14  [Hazard]
end:
    jal  x0, end        # 無窮迴圈，讓波形停住
