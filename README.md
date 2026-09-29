# Vendy Skills

兩份按需載入的工程方法，補充全域工作指引，不再按「規劃、實作、審查、除錯」四種一般意圖重述共同規則。

## 方法

- **`debugging`**：用於原因不明、間歇性、跨層或效能回歸。建立可判定缺陷的訊號，縮小重現，以探針區分原因，並驗證原始情境的修復。
- **`code-review`**：用於具體 diff、branch、PR 或 working-tree changes。確定比較範圍，分別檢查需求符合度與工程正確性，提出具體失敗路徑及依影響排序的 findings。

明顯的局部修正與一般想法評估不需要額外載入這些方法。原本的兩份通用規劃與交付 skill 已撤下；保留的除錯與審查方法已改名並重整。

## 知識邊界

全域指引管理自主權、品質、授權、工作保護與完成原則。Skills 提供任務特有的方法；專案指引與 runtime 提供 domain 事實、命令、CI/CD、ownership 與 release 規則。[PROFILE.md](PROFILE.md) 保留跨任務的精簡個人偏好，不由安裝器載入。

每份 skill 的方法可獨立閱讀，仍依使用者與宿主的指引判定權限；方法本身不授予額外操作權限。

## 方法來源

融合原有的證據與因果判斷，以及 [Matt Pocock skills](https://github.com/mattpocock/skills) 的可重現回饋迴圈、最小重現及需求／工程品質分開檢查。採用方法概念，不沿用固定假說數量、強制階段、自動提交或一律執行完整測試的流程。

## 安裝

```bash
npx skills add vendyluo/vendy-skills
```

依需要選擇 `debugging` 與 `code-review`。更新舊安裝時移除舊的四個入口，避免重複載入。根目錄的 `PROFILE.md` 不會安裝成全域指引。

## Amp 同步

- 全域 prompt 以 `PROFILE.md` 為版本來源，同步到 Amp 帳號的 Global AGENTS.md。不要再透過 `~/.config/amp/AGENTS.md` 載入同一份內容；本機全域檔只放機器特有資訊，沒有就不建立。
- 本機 skills 可透過 symlink 使用此 repo；GitHub push 不會自動更新 Amp server。
- 雲端 skills 需將 `skills/<name>/` 的完整內容同步到個人 User Skills repo 的頂層 `<name>/`，再 commit、push。目的地由 `amp skills repositories` 查詢，不同步至 Workspace Skills。
- 修改或同步完成後，在 Amp 呼叫 `reload_skills`，確認載入無誤。不要直接編輯 Amp 的 server materialized cache。
- UI/design skills 不屬於此 repo 的兩份工程方法；其個人 Amp Skills repo 與本機安裝需另行同步。


## 驗證

需要 Python 3：

```bash
python3 scripts/validate.py
git diff --check
```

Validator 檢查 skill 結構、名稱、描述與引用，並執行 negative fixtures；通過不代表觸發或任務行為已驗證。
