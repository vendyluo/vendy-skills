# Vendy Skills

兩份按需載入的工程方法，補充全域工作指引，不再按「規劃、實作、審查、除錯」四種一般意圖重述共同規則。

## 方法

- **`debugging`**：用於原因不明、間歇性、跨層或效能回歸。建立可判定缺陷的訊號，縮小重現，以探針區分原因，並驗證原始情境的修復。
- **`code-review`**：用於具體 diff、branch、PR 或 working-tree changes。確定比較範圍，分別檢查需求符合度與工程正確性，提出具體失敗路徑及依影響排序的 findings。

明顯的局部修正與一般想法評估不需要額外載入這些方法。原本的兩份通用規劃與交付 skill 已撤下；保留的除錯與審查方法已改名並重整。

## 知識邊界

全域指引管理自主權、品質、授權、工作保護與完成原則。Skills 提供任務特有的方法；專案指引與 runtime 提供 domain 事實、命令、CI/CD、ownership 與 release 規則。[PROFILE.md](PROFILE.md) 保留 repository 的工程判斷背景，不由安裝器載入。

每份 skill 的方法可獨立閱讀，仍依使用者與宿主的指引判定權限；方法本身不授予額外操作權限。

## 方法來源

融合原有的證據與因果判斷，以及 [Matt Pocock skills](https://github.com/mattpocock/skills) 的可重現回饋迴圈、最小重現及需求／工程品質分開檢查。採用方法概念，不沿用固定假說數量、強制階段、自動提交或一律執行完整測試的流程。

## 安裝

```bash
npx skills add vendyluo/vendy-skills
```

依需要選擇 `debugging` 與 `code-review`。更新舊安裝時移除舊的四個入口，避免重複載入。根目錄的 `PROFILE.md` 不會安裝成全域指引。

## 驗證

需要 Python 3：

```bash
python3 scripts/validate.py
git diff --check
```

Validator 檢查 skill 結構、名稱、描述與引用，並執行 negative fixtures；通過不代表觸發或任務行為已驗證。
