# Vendy Skills

Vendy Skills 保存個人偏好與可選的工程檢查表。[PROFILE.md](PROFILE.md) 只保留跨任務的個人偏好，供 Astra 與 Sol 共用；一般工程行為、工具與授權規則交由 Amp 原生指引處理。

它不是 agent framework、自主執行 runtime、Phoenix framework，也不是包辦所有工具的目錄。

## 四個點名使用的檢查表

- **Frame**：`framing-decisions` 把粗略想法、方向、價值判斷與自動化邊界收斂成可決定的方案。
- **Investigate**：`investigating-failures` 從失敗、regression 或 broken behavior 的觀察證據建立 root cause，再決定完整修法。
- **Examine**：`examining-claims` 唯讀評估 diff、PR、計畫、agent output、release readiness 或專案現況。
- **Make**：`delivering-outcomes` 在方向已定且明確授權後，完成最小且完整的實作或成果。

這四個 skills 只在使用者明確點名時載入；一般規劃、除錯、review 或實作不需要它們。保留原文供需要時取用，不把它們當成每項任務的必經流程。

## 知識邊界

這個 repo 只放可移植的工程判斷與 reusable workflow。服務名稱、domain 規則、實際命令、CI/CD、release、ownership 與協作慣例，應留在各專案自己的 `AGENTS.md`、`CLAUDE.md` 或 project skills。當前 repository 與 runtime 的證據永遠優先於通用方法。

## 安裝

```bash
npx skills add vendyluo/vendy-skills
```

安裝時依需求選擇 skills。安裝器只複製選定的 `skills/<name>/`，不會把根目錄的 `PROFILE.md` 安裝成 global instructions。這些是可選的檢查表，不取代 host 的工具或權限契約。

## Amp 同步

- 全域 prompt 以 `PROFILE.md` 為版本來源，同步到 Amp 帳號的 Global AGENTS.md。不要再透過 `~/.config/amp/AGENTS.md` 載入同一份內容；本機全域檔只放機器特有資訊，沒有就不建立。
- 本機 skills 可透過 symlink 使用此 repo；GitHub push 不會自動更新 Amp server。
- 雲端 skills 需將 `skills/<name>/` 的完整內容同步到個人 User Skills repo 的頂層 `<name>/`，再 commit、push。目的地由 `amp skills repositories` 查詢，不同步至 Workspace Skills。
- 修改或同步完成後，在 Amp 呼叫 `reload_skills`，確認載入無誤。不要直接編輯 Amp 的 server materialized cache。
- UI/design skills 不屬於此 repo 的四個工程入口；其個人 Amp Skills repo 與本機安裝需另行同步。

## 驗證

完整驗證需要 Python 3：

```bash
python3 scripts/validate.py
git diff --check
```

`scripts/validate.py` 會檢查所有直接位於 `skills/` 下的 skill，並執行 validator 的 negative fixtures。
