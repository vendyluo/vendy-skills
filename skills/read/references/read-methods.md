# Read Methods Reference

Resolve the built-in helper script directory once. This works from a single-skill install, a packaged dispatcher, or the source repository:

```bash
READ_SCRIPT_DIR=""
for candidate in \
  "${CLAUDE_SKILL_DIR:+$CLAUDE_SKILL_DIR/scripts}" \
  "${CLAUDE_SKILL_DIR:+$CLAUDE_SKILL_DIR/skills/read/scripts}" \
  "./skills/read/scripts"; do
  if [ -n "$candidate" ] && [ -f "$candidate/fetch.sh" ]; then
    READ_SCRIPT_DIR="$candidate"
    break
  fi
done
if [ -z "$READ_SCRIPT_DIR" ]; then
  echo "read helper scripts not found; set CLAUDE_SKILL_DIR or run from the repository root" >&2
  exit 1
fi
```

## Standard Fetch

Use the built-in fetch wrapper first. It requests the origin directly and only uses third-party extraction proxies when `--use-proxy` is explicitly authorized:

```bash
"$READ_SCRIPT_DIR/fetch.sh" "{url}"
# After explicit proxy approval for a public, non-sensitive URL:
"$READ_SCRIPT_DIR/fetch.sh" --use-proxy "{url}"
```

Success means non-empty, readable content rather than a login, captcha, or error page. Read the structured stderr result to see which tier succeeded or why extraction failed.

### Optional local tools

```bash
agent-fetch "{url}" --json
# or
defuddle parse "{url}" -m
```

Use these only when already available or when installing them is authorized. `agent-fetch --json` returns JSON, so extract the Markdown-bearing field before returning or saving the result. `defuddle parse -m` outputs Markdown directly. Raw JSON is not a valid final output for `/read`.

## GitHub URLs

GitHub file URLs (`github.com/user/repo/blob/...`) render heavy HTML. The proxy cascade often returns partial or nav-heavy content. Prefer:

```bash
# Raw file content (fastest)
curl -sL "https://raw.githubusercontent.com/{user}/{repo}/{branch}/{path}"

# Via gh CLI (works with private repos)
gh api repos/{user}/{repo}/contents/{path} --jq '.content' | base64 -d
```

Use the proxy cascade only as a fallback for GitHub pages that are not raw file views (e.g., issue threads, README renders).

## PDF to Markdown

### Remote PDF URL

Download and extract locally first:

```bash
tmp_pdf="$(mktemp -t read-pdf.XXXXXX).pdf"
curl -sL "{pdf_url}" -o "$tmp_pdf"
pdftotext -layout "$tmp_pdf" -
rm -f "$tmp_pdf"
```

If local extraction fails and the URL is public and non-sensitive, use r.jina.ai only after explicit proxy approval:

```bash
curl -sL "https://r.jina.ai/{pdf_url}"
```

### Local PDF file

```bash
# Best quality (requires: pip install marker-pdf)
marker_single /path/to/file.pdf --output_dir "${READ_OUTPUT_DIR:-/tmp/read-output}"

# Fast, text-heavy PDFs (requires: brew install poppler)
pdftotext -layout /path/to/file.pdf - | sed 's/\f/\n---\n/g'

# No-dependency fallback
python3 -c "
import pypdf, sys
r = pypdf.PdfReader(sys.argv[1])
print('\n\n'.join(p.extract_text() for p in r.pages))
" /path/to/file.pdf
```

Use `marker` when layout matters (papers, tables). Use `pdftotext` for speed.

## Feishu / Lark Document

Requires `requests` and Feishu app credentials:

```bash
# Install requests in an appropriate environment first if the user authorizes it.
export FEISHU_APP_ID=your_app_id
export FEISHU_APP_SECRET=your_app_secret
python3 "$READ_SCRIPT_DIR/fetch_feishu.py" "{url}"
```

Supports: docx and wiki pages. Legacy `/docs/` pages are not supported by this script; convert them to docx first, or use a public-page fallback if the document is accessible without the API. App needs `docx:document:readonly` and `wiki:wiki:readonly` permissions.
Output: YAML frontmatter (title, document_id, url) + Markdown body.

Do not tell every user to install `lark-cli` up front. Use it as the user-login fallback when the API helper fails because app credentials are missing, or when the user explicitly prefers OAuth login over `FEISHU_APP_ID` / `FEISHU_APP_SECRET`:

```bash
# Install @larksuite/cli first only when a global dependency change is authorized.
lark-cli auth login            # one-time login
lark-cli docs +fetch --doc "{url}" --format json
```

`lark-cli docs +fetch` returns structured document JSON, not final Markdown. Extract and convert the useful content before answering; do not return raw JSON.

## WeChat Public Account

Try the standard local fetch first. If the static response lacks article content, use the built-in Playwright script when its dependencies already exist or installing them is authorized:

```bash
pip install playwright beautifulsoup4 lxml && playwright install chromium
python3 "$READ_SCRIPT_DIR/fetch_weixin.py" "{url}"
```

For a public, non-sensitive article, the proxy cascade is another fallback after explicit proxy approval.
