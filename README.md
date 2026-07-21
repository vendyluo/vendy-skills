# Vendy Skills

一組貼合我工作方式的 agent skills。它們從 [tw93/Waza](https://github.com/tw93/Waza) 衍生，經過重新整理後，只保留能跨專案重用的工程判斷與工作方法。

核心很簡單：先解決真實問題，以證據做判斷，選擇最小足夠且完整的做法，不為抽象、文件或流程本身增加複雜度。完整原則見 [PROFILE.md](PROFILE.md)，英文版見 [PROFILE.en.md](PROFILE.en.md)。

## Skills

- `think`：收斂需求、架構與價值判斷。
- `hunt`：從可重現證據找到 root cause，再完成足夠且完整的修正。
- `check`：review 程式碼、PR、release readiness 與專案品質。
- `design`：產品 UI、元件、排版、motion 與 screenshot-driven polish。
- `read`：讀取 URL 與 PDF，依目的回傳摘要、引用或乾淨內容。
- `learn`：多來源研究、理解與可發布整理。
- `write`：中英文改寫、本地化與去 AI 味。
- `health`：檢查 agent instructions、hooks、MCP、verifier 與 AI maintainability。

## 邊界

這個 repo 回答「我怎麼工作」，不替專案決定 domain、架構、命令、CI/CD、release、issue tracker 或協作慣例。這些事實留在各專案的 `AGENTS.md`、`CLAUDE.md` 或 project skills。

不另外維護「個人版」與「公司版」。判斷風險時看實際 collaborators、production data、external side effects、專案慣例與 rollback cost，而不是 personal/work 標籤。

## 安裝

依需求選擇要安裝的 skill 與 agent，不預設全域安裝：

```bash
npx skills add vendyluo/vendy-skills
```

`npx skills` 只安裝選定的 `skills/<name>/`。根目錄的 profile 與共用規則不會成為 global instructions；每個 skill 自己攜帶執行所需的最小原則。

## 驗證

```bash
python3 scripts/validate.py
```

Validator 會檢查 portable skill frontmatter、相對引用、shell/Python 語法、跨 runtime 路徑、專案限定名稱，並執行 bundled helper 的 focused behavior tests。行為改動仍需依相關 skill 的實際 runtime path 做 targeted verification。

上游 attribution 與授權說明見 [LICENSE](LICENSE) 和 [NOTICE.md](NOTICE.md)。
