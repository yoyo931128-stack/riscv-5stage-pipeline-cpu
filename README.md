# riscv-5stage-pipeline-cpu
中央處理元件 課程期末專題｜指導教授：張孟洲｜2026.06

以本系林慶樺學長之 MIPS R2000 五級管線設計為藍本，全面改寫為 RISC-V RV32I
架構，補齊原設計缺漏的分支資料前推機制，並加入 Zicsr 擴充與 M-mode 例外處理。

## 修改與新增設計對照表

| 項目 | 學長 MIPS 原始設計 | 本專案 RISC-V 實作 |
|---|---|---|
| 指令集 | MIPS R2000 | RV32I（39 條）+ Zicsr（6 條） |
| 解碼路徑 | rd/rt 欄位浮動，需 RegDst MUX | 欄位位置對齊，可拔除 MUX |
| 分支判斷 | EX Stage，penalty 2 cycle | ID Stage，penalty 1 cycle |
| Branch Forwarding | 無 | EX/MEM、MEM/WB → ID Stage |
| 例外處理 | Latch 簡化保存 | mtvec / mepc / mcause + Zicsr |

## 檔案結構

- `src/` — Verilog 模組原始碼
- `tb/` — testbench
- `test/` — 四支測試程式（.asm 原始碼與對應機器碼 txt）
- `data.txt` — 暫存器初值設定
- `doc/` — 完整專題報告 PDF

## 使用方式

1. 將欲測試的機器碼 txt 檔複製到 Verilog 原始碼所在目錄
2. 將該檔案更名為 `inst`
3. Compile 後即可用 ModelSim 模擬

`data.txt` 為暫存器初值設定，無必要請勿更動。

## 測試程式

| 檔案 | 測試重點 |
|---|---|
| `hazard.asm` | 管線 Data Hazard 偵測與前傳機制 |
| `branch.asm` | 分支指令與動態跳轉的控制邏輯 |
| `exception.asm` | Zicsr 擴充指令集與 Exception 處理 |
| `CMDtest.asm` | 全面驗證 RV32I 指令集 |

模擬結果以 ModelSim 波形與 Venus 模擬器交叉比對驗證。

## 已知限制

- CSR Hazard 目前以手動插入 NOP 迴避，正規做法應由硬體 Stall
- `mret` 指令尚未實作，中斷處理程式僅記錄現場而未實際處理
- 僅做功能層級行為模擬，未進行邏輯合成與時序分析
