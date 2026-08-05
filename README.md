# Vendy Skills

Vendy Skills 是一小組以人類意圖為中心、可跨 runtime 使用的工程方法。[PROFILE.md](PROFILE.md) 是這個 repository 編寫與檢查 skills 的治理來源；每個 skill 則獨立把一種人類意圖轉成有證據、授權邊界與完成條件的工作流程。

它不是 agent framework、自主執行 runtime、Phoenix framework，也不是包辦所有工具的目錄。

## 四種公開意圖

- **Frame**：`framing-work` 把粗略想法、方向、價值判斷與自動化邊界收斂成可決定的方案。
- **Investigate**：`investigating-problems` 從失敗、regression 或 broken behavior 的觀察證據建立 root cause，再決定完整修法。
- **Examine**：`examining-work` 唯讀評估 diff、PR、計畫、agent output、release readiness 或專案現況。
- **Make**：`delivering-outcomes` 在方向已定且明確授權後，完成最小且完整的實作或成果。

這四個入口按人的目的分工，不要求使用者理解內部分類、agent 組織或控制流程。

## 選用 specialist

- `verifying-state-contracts`：把有狀態的設計寫成有限狀態契約，檢查 ownership、durability、event ordering 與 invariant，再以 Elixir verifier 輸出 `PASS`、`VIOLATION` 或 `MODEL INCOMPLETE`。

## 知識邊界

這個 repo 只放可移植的工程判斷與 reusable workflow。服務名稱、domain 規則、實際命令、CI/CD、release、ownership 與協作慣例，應留在各專案自己的 `AGENTS.md`、`CLAUDE.md` 或 project skills。當前 repository 與 runtime 的證據永遠優先於通用方法。

## 安裝

```bash
npx skills add vendyluo/vendy-skills
```

安裝時依需求選擇 skills；不需要把每個方法都載入每項工作。安裝器只複製選定的 `skills/<name>/`，不會把根目錄的 `PROFILE.md` 安裝成 global instructions。因此，每個 `SKILL.md` 都必須自帶完整且與 profile 一致的行為契約。

## 驗證

完整驗證需要 Python 3 與 Elixir 1.19 以上：

```bash
python3 scripts/validate.py
git diff --check
```

`scripts/validate.py` 會檢查所有直接位於 `skills/` 下的 skill、執行 validator 的 negative fixtures，並執行 state contract verifier 的 focused behavior tests。缺少 Elixir 時，完整驗證會回報 unavailable 並以非零狀態結束，不會誤報為通過。若只修改 state verifier，可單獨執行 `elixir skills/verifying-state-contracts/scripts/test.exs`。
