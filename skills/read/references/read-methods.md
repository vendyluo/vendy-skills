# Read Methods Reference

Replace `<skill-base-dir>` with the base directory reported by the runtime when this skill loads, then resolve the bundled helper scripts once:

```bash
READ_SCRIPT_DIR="<skill-base-dir>/scripts"
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

# Optional Python fallback (requires: pip install pypdf)
python3 -c "
import pypdf, sys
r = pypdf.PdfReader(sys.argv[1])
print('\n\n'.join(p.extract_text() for p in r.pages))
" /path/to/file.pdf
```

Use `marker` when layout matters (papers, tables). Use `pdftotext` for speed.
