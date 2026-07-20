---
name: check
description: "Reviews code diffs, PRs, release readiness, and project audits. Use when users ask in any language for code review, pre-merge checks, release gates, or project audits. Not for debugging root causes, prose review, or executing publish, deploy, merge, or release actions."
when_to_use: "review, 看看程式碼, 檢查一下, 有沒有問題, 是否需要優化, 合併前, 優化程式碼, 看看PR, review my code, check changes, before merge, code review, code-review, audit, project audit, 專案體檢, 程式碼品質評分, scorecard, rate this codebase"
dispatch_intent: "Code review, before merge, generated artifacts, safety sinks, project-wide code-quality audit scorecard"
---

# Check: Review Before You Ship

Read the diff and current project contract, then report only findings that can change the outcome. Review is read-only unless the user explicitly asks to fix findings or implementation is already authorized. Done means the review surface and actual verification state are reported honestly; it does not imply CI, merge, or release gates passed.

## Outcome Contract

- Outcome: a review grounded in the current diff, project context, and live evidence.
- Done when: findings, fixes, or blockers are stated with the commands or artifacts that prove them.
- Evidence: worktree status, diff, project docs, manifests, CI, and current command output.
- Output: concise findings first, then verification summary when applicable.

## Worktree Safety Preflight

Before any review or PR operation, read the current worktree with:

```bash
git status --short --branch -uall
```

Treat modified, staged, and untracked files as user work. You may read them and include them in the review surface, but you must not move, hide, overwrite, clean, or discard them without explicit user approval in the current turn.

Do not run these commands as default review or PR setup: `git switch`, `git checkout`, `git reset --hard`, `git clean`, `git stash -u`, `git stash --include-untracked`, `git stash -a`, `git stash --all`, or `gh pr checkout`. If a branch change or cleanup is genuinely required, stop and ask for that exact operation.

Do not "protect" user work by moving untracked files, generated files, screenshots, or local scratch files into `/tmp` or another holding directory. Moving someone else's WIP out of the checkout is the same class of interference as stashing it. If a clean tree is required for generation, packaging, or verification, use a separate worktree from a known commit and copy only the artifact or patch you own back into the current checkout.

For commit or push follow-through in a dirty or multi-agent checkout, record `git rev-parse HEAD` before staging. Re-read `git status --short --branch -uall` and `git rev-parse HEAD` immediately before commit and again before push. If HEAD moved, unknown commits appeared, or the worktree changed outside your intended files, stop and report the mismatch instead of rebasing, recommitting, or pushing.

For PR inspection, prefer commands that do not switch the current working tree: `gh pr view`, `gh pr diff`, `git fetch origin pull/<n>/head:refs/tmp/pr-<n>`, and `git merge-tree`.

## Mode Picker

Pick the mode that matches the user's intent, then read that section in full. Modes layer on top of the shared review surface (Scope, Hard Stops, Fix Routing, Specialist Review, Verification, Sign-off) further down.

| User intent | Mode |
|---|---|
| Diff or PR ready, "review", "看看程式碼", "合併前" | Default review (start at [Get the Diff](#get-the-diff)) |
| "audit", "專案體檢", "scorecard" | [Project Audit](#project-audit-mode) |
| Prose, content, tone, or localization review | Delegate to `/write` (see [Document Review](#document-review)) |
| Document or print typography, paged layout, or artifact aesthetics | Use a dedicated document-design workflow when one is available; this is not a code review |
| Broken PDF render, page break, or font output | Delegate root-cause work to `/hunt` Rendering Bug Mode |
| Release readiness, publish readiness, deploy gate | Review the project's documented gate, CI, and artifacts; executing release, publish, deploy, merge, closure, or public replies still requires explicit authorization and project-specific tooling |

Before any mode, run [Project Context Extraction](#project-context-extraction) and (if memory is in scope) [Durable Context Preflight](#durable-context-preflight).

## Project Context Extraction

Extract constraints from the current repository rather than assuming. Project instructions and conventions supply local facts and defaults; understand the invariant they protect instead of treating them as authority that can override current evidence or safety boundaries.

Before reviewing, extract project constraints from repository context:

1. Read the diff and identify changed languages, frameworks, manifests, generated outputs, release files, and CI workflows.
2. Inspect tracked project files only as needed: README, AGENTS/CLAUDE instructions when present, package manifests, lockfiles, build configs, test configs, workflow files, and release notes.
3. Compress the findings into review context: verification commands, protected or generated files, generated artifacts, and domain risks.
4. When project context and this skill differ, identify whether the project rule protects a real local invariant. Follow it when it does; surface the conflict when current evidence, safety, or an external contract says otherwise.
5. If project docs or CI name a verification command, prefer that over auto-detection.

For the context shape, see `references/project-context.md`.

Release execution is out of scope here. Release-readiness review uses the project's own documented process, artifacts, CI, and distribution surfaces rather than a global release ritual.

## Durable Context Preflight

See [references/durable-context.md](references/durable-context.md) for when to read durable context, the read-order budget, and the memory-type mapping.

For `/check`: the current diff, CI, and remote state override memory. Durable memory can explain user intent and preferred follow-through, but public project rules still come from README files, manifests, CI workflows, release docs, and explicit instructions in the current thread. Never cite private memory as a public project requirement.

## Get the Diff

Use the review surface the user named. Otherwise review staged and unstaged worktree changes first, even on the base branch; use the branch-to-base diff when the task is clearly a branch or PR review. Ask for a range only when no reviewable diff or target is available.

## Project Audit Mode

Activate when the user asks for a project-wide code-quality scorecard: "audit", "專案體檢", "程式碼品質評分", "scorecard". Distinct from Default Review (PR/diff scoped). Single-pass project-wide quality assessment.

**Flow**

1. Run `python3 <skill-base-dir>/scripts/audit_signals.py --root <project>` from the target repo, with `<skill-base-dir>` replaced by this skill's base directory. The script emits labelled blocks (`=== FILE SIZE HOTSPOTS ===` ... `=== DENYLIST IN BUILD ===`) each ending with `status: PASS|WARN|FAIL|N/A`.
2. Skim the largest source files surfaced by `FILE SIZE HOTSPOTS` (typically 3-5; stop sooner if the architecture is already clear).
3. Read `CLAUDE.md` / `AGENTS.md` / `README.md` to learn the project's own stated conventions before judging it against generic ones.
4. Apply the four-axis rubric below. Score only when the user asked for a scorecard; otherwise report evidence and priorities without manufacturing a number. When scored, each axis is 0-10 and Overall is the arithmetic mean.
5. Surface only concrete findings that pass the Finding Quality Gate. Zero findings is valid. Each finding includes file:line when possible, severity (CRIT/STRUCT/INCR), and one-line fix.
6. Output to **terminal only**. Do not create files in the target repo. If the user follows up with "save it", offer `./docs/<project>-audit.md` then; default is ephemeral.

**Rubric**

| Axis | What it covers |
|---|---|
| Outcome and Contract | Whether the software solves the stated user or business problem and preserves required behavior and external contracts |
| Simplicity and Architecture | Understandable boundaries, coupling, necessary abstractions, duplication cost, and single sources of truth |
| Verification and Delivery | Relevant tests, runtime checks, CI gates when present, generated outputs, packaging, and distribution evidence |
| Runtime, Data, and Safety | Performance evidence, data integrity, security, reversibility, privacy, and third-party blast radius |

**Scoring anchors**

- 9-10: exceptional discipline, polish-only items
- 7-8.5: solid with clear targeted improvements
- 5-7: working but with structural debt
- below 5: significant rework recommended

A WARN that the project has explicitly justified (in its own docs or a comment) is not a finding; cite the justification and skip. Do not mechanically convert WARN to CRIT. A block with `status: N/A` means the surface does not exist (e.g. no packaging script); treat as silence, not as a positive signal.

**Output template (terminal)**

```
Project: <name>
Overall: X.X / 10

Outcome & Contract:         X / 10 -- one-line summary
Simplicity & Architecture: X / 10 -- one-line summary
Verification & Delivery:   X / 10 -- one-line summary
Runtime, Data & Safety:    X / 10 -- one-line summary

Findings
[CRIT] <file:line> -- <issue>
       why: <reason grounded in signal or read>
       fix: <concrete action>
[STRUCT] ...
[INCR] ...

Top 3 highest-leverage moves
1. ...
2. ...
3. ...
```

Stop after the report unless the user asks for follow-up implementation. Audit mode does not modify files in the target repo.

## Scope

Classify depth by behavioral risk, contract surface, reversibility, and evidence needed. Diff size is a supporting signal, not a hard threshold:

| Depth | Criteria | Reviewers |
|-------|----------|-----------|
| **Quick** | Narrow, reversible change with one clear contract and no security, data, migration, or distribution boundary | Base review only |
| **Standard** | Multiple interacting modules or user-visible behavior where a specialist perspective could change the verdict | Base + conditional specialists |
| **Deep** | Security, auth, payments, destructive data mutation, external contract or schema migration, irreversible rollout, or broad distribution impact | Base + all relevant specialists + adversarial pass |

State the depth before proceeding.

Static content diffs can stay quick even when they touch several generated files: version strings, dates, release-copy mirrors, sitemap dates, or one-for-one localization copy changes usually need line-by-line readback plus grep consistency, not a specialist fleet. Escalate only when the diff changes logic, generation rules, public distribution behavior, or user-facing semantics beyond the literal text replacement.

## Did We Build What Was Asked?

Before reading code, check scope drift: do the diff and the stated goal match? Label: **on target** / **drift** / **incomplete**.

Also check surgical traceability: every changed file and every new public surface must trace back to the user's stated goal. If a file, dependency, config knob, abstraction, generated artifact, workflow permission, or release behavior cannot be explained in one sentence from the request, label it drift until proven necessary.

Drift signals (examples, not exhaustive -- any one is enough to label drift):
- A changed file has no connection to the stated goal
- The diff includes unrelated refactoring, formatting, or restructuring that is not needed for the authorized outcome
- A new dependency appears that the goal did not mention
- Code unrelated to the goal was deleted or commented out
- A new abstraction or helper was introduced that is not required by the goal
- A maintainability, review, or cleanup change quietly adds user-visible UI, default config, workflow permissions, or release behavior

## Pattern-Fix Completeness

When the diff fixes one instance of a class-of-bug (a missing validation, a wrong selector, an off-by-one, a missing lock), search the repository for plausible sibling shapes and confirm the same bug was handled completely. Shape similarity is only a lead: require the same reproducible root cause, risk shape, remedy, contract impact, and verification before calling a sibling incomplete. Different product semantics or consumer contracts are separate findings, not authorization to modify them. For a deeper sweep playbook, see hunt's Scope Blast Mode.

## Testability Seam For Recurring Bugs

When a visual, layout, timing, or stateful-UI bug has recurred, require a durable regression guard that exercises the violated invariant. Prefer an existing pure seam or the project's current test boundary; do not extract a helper or abstraction solely to satisfy a unit-test shape. A deterministic runtime or artifact check is valid when no honest automated seam exists. If a new testability abstraction would materially prevent recurrence, propose it separately with the smallest non-refactor alternative rather than making it a hidden condition of the bug fix.

## CLI Command Surface

When a diff touches a CLI entrypoint, installer, completion, config/env handling, package wrapper, or a mutating command such as cleanup, update, uninstall, migration, or cache removal, load `references/release-surfaces.md` (CLI Command Surface) and work its checklist, then fill the CLI Command Surface template from `references/project-context.md` before sign-off. The core stance: verify command contract and installed-runtime behavior, not just library tests, and treat every mutating command as a safety sink.

Terminal output is a rendered surface. After changing CLI-facing text, spacing, or layout, re-run the command and read the real output before claiming done; editing the string is not seeing the screen.

## Skill, Plugin, And Packaged Install Surface

When a diff touches a skill, plugin, marketplace entry, installer, package allowlist, package manifest, generated mirror, or published archive, load `references/release-surfaces.md` (Packaged Install Surface) and verify the installed runtime contract through its five steps: real user install path, rebuilt package contents, isolated install smoke, noise filtering, and explicit gaps when the smoke cannot run. Manifest JSON, source tests, or a successful local import never substitute for installed-runtime proof.

## Hard Stops (resolve before merging)

Examples, not exhaustive -- flag any diff that could cause irreversible harm if merged unreviewed.

- **No unverified claims.** Do not write "I verified X", "I ran Y", "tests pass", or "this fixes Z" without trustworthy evidence for the exact reviewed code state: current command output, CI result, runtime artifact, or equivalent reproducible evidence. Do not rerun ceremonially when that exact evidence already exists, but invalidate it after code changes. If you only reasoned from code, say so.
- **Re-read before citing source-of-truth facts.** Before writing a line number, dirty-file count, branch ahead/behind state, fallback behavior, locale coverage, or release artifact state into a handoff or review report, re-read the source in this turn (`git status`, `git diff`, file `Read`, `rg`, command output). Earlier chat context, prior agent notes, and your own recall are stale by default. Cite the verification path inline (`per current Read of <file>` / `per git status this turn`) so reviewers know which facts are anchored.
- **String-matching on captured output**: when a diff branches on or greps an error message or command output, probe what that string actually holds at runtime before approving. A subprocess spawned with `stdio: 'inherit'` (or any uncaptured pipe) leaves diagnostics on the terminal and `error.message` holding only the command line, so the matcher silently matches the command, not the output. Prefer a structured fact the caller already holds (exit code, build target) over re-parsing a string.
- **Magic-wait coupling**: a fixed `sleep`, `asyncAfter`, `setTimeout`, or "should be enough" timeout standing in for an unobserved async completion, or an animation, poll, or progress step tied to a frame count or fixed duration rather than wall-clock state. It passes on the author's machine and breaks on a slow CPU, a 120Hz display, or a proxied network. Flag it: drive the next step off the real completion signal (callback, navigation-done, frame-changed, state flag), and keep timing machine- and frame-rate-independent.
- **Destructive auto-execution**: any task marked "safe" or "auto-run" that modifies user-visible state (history files, config, preferences, installed software) must require explicit confirmation.
- **Source and distribution out of sync**: generated or bundled outputs implied by the source change must be rebuilt and tracked before calling the implementation complete. Before declaring distribution or release ready, also verify package contents, named release artifacts, upload state, and version consistency across the surfaces the project ships. Review does not authorize uploading them.
- **Verifier failure layer unclear**: if a verifier fails before assertions or due to missing optional dependencies, bootstrap noise, transient build-service crashes, unavailable simulators, or tool setup, classify setup versus product failure. Retry only with new evidence or a narrower environment. Do not call the repo broken until the intended test body or artifact check actually ran. The inverse is the same stop: a verifier that passes without running the real path -- a skipped optional-dependency job that still prints OK, a function that early-returns leaving output empty so a true-on-empty assertion passes, a render reported fixed but never opened -- is a hollow green. A pass counts only when at least one non-skipped, non-empty case exercised the path and the assertions fail on emptiness.
- **Manifest-only install proof**: if a diff changes a skill, plugin, installer, marketplace entry, package wrapper, or installable archive, metadata and source tests are not enough. Build or install through the real user path in an isolated environment, or mark the install/runtime layer unverified.
- **Unresolved identifiers in diff**: every new reference must resolve to an existing definition, generated contract, dependency API, or definition included in the same diff. Search the repository and relevant generated or dependency surface before approving it; absence outside the diff is valid when the diff itself introduces the definition.
- **Dead-code or YAGNI deletion without proof**: any "zero callers" or "unused" claim must be checked across the whole repository, including top-level entrypoints, docs, tests, generated dispatch tables, scripts, CI, package allowlists, package manifests, and dynamic lookup patterns. Treat sub-agent or tool reports as leads, not proof. Before deleting, batch-grep all candidates, classify test-only references separately from production/runtime references, and chase written variables or data tables that may become orphaned together. If a file is only wrongly exposed through a package, archive, or plugin mirror, tighten that distribution surface and its test instead of deleting the dev tool. If the grep scope is partial, do not delete.
- **Injection and validation**: SQL, command, path injection at system entry points. Credentials hardcoded, logged, committed, or copied into public docs.
- **Dependency changes**: unexpected additions or version bumps in package.json, Cargo.toml, go.mod, requirements.txt. Flag any new dependency not obviously required by the diff. The inverse is a finding too: a declared dependency or linked SDK with zero imports across the repo gets reported, not silently removed; it may be staged for upcoming work, while some unused SDKs still affect privacy or distribution. Removal needs implementation authorization, a repository-wide reference check, and relevant verification.
- **Safety sinks**: destructive file operations, shell or AppleScript construction, cwd/path/symlink traversal, approval or sandbox boundary changes, signing/appcast flows, and auth prompts need explicit review of validation, rollback, and user-confirmation behavior.
- **Unapproved external contract change**: changes to cross-service APIs, events, webhooks, public package or SDK interfaces, CLI commands, flags, exit codes or output, config or environment contracts, published schemas or formats, or behavior consumers rely on require consumer analysis. Surface old and new behavior, migration or rollout, a non-contract-changing alternative, and the decision owner; do not disguise the change as local cleanup.
- **Audit before restore**: when the diff re-adds a symbol, string, asset, or config field that recent history removed, grep the rest of the diff and the main branch to confirm anything still uses it. A rule file that names the symbol is not proof of life. If only a parity test references it, the rule is stale and the restore is wrong; reject the restore and flag the stale rule. Specifically suspicious: re-adding an enum case, xcstrings entry, dictionary key, or asset file that the prior commit deleted intentionally.
- **Intentional-divergence normalized**: a surface that deliberately breaks a house pattern -- omits a shared step, takes a conditional path the siblings avoid, leaves an asymmetry -- to dodge a known defect, then a later cleanup pass "tidies" it back into uniformity and reintroduces the bug. Before unifying an outlier to match its siblings, read the comment or commit that created it and confirm the defect it prevents survives your change.
- **Broad matchers in destructive sinks**: any diff that adds recursion, mass-delete, traversal, ID-prefix wildcards, or fallback regex branches feeding a destructive sink gets a line-by-line review of matcher breadth in every branch, protected-path coverage for the new entry point, and any bypassed user-confirmation step. Author or tool provenance is not evidence of correctness.
- **Migration code for features that did not ship before**: when the project has a prior release or production baseline, reject migration scaffolding, version-gated defaults, or "carry old key forward" logic if the underlying preference, schema, or feature never reached that baseline. Verify against the project's actual last-shipped state rather than assuming a tag convention. Migration code for a never-consumed state is dead-on-arrival complexity.

## Finding Quality Gate

Before writing any finding into the report, run this gate:

**Pre-report self-check (four questions, every finding must pass):**
1. Can I cite the exact source location, runtime artifact, or command output?
2. Can I describe the specific input or state that triggers the bad outcome?
3. Have I read the upstream callers / downstream consumers, not just the function in isolation?
4. Is the severity defensible from concrete user, contract, data, security, or delivery impact?

If any answer is "no", drop the finding or downgrade it to advisory. Vague findings train the reader to ignore real ones.

**A clean review is a valid review.** Do not manufacture findings to justify the invocation. Zero findings with a stated review surface is a complete output. Padding the report with low-confidence noise is a worse outcome than reporting nothing.

**HIGH and CRITICAL require three pieces of evidence:**
1. The exact source location or runtime artifact where the bug lives.
2. The specific trigger: what input, state, or sequence produces the bad outcome.
3. Why existing guards (validation, type system, upstream catch, framework default) do not already prevent it.

Cannot supply all three? Downgrade to MEDIUM, or drop. "This *might* break under some condition" is not a HIGH.

## Knowledge Sync

After reviewing the diff, check whether behavior directly affected existing project docs or introduced a durable invariant worth documenting:

- Existing README, API guide, Swagger/OpenAPI source, generated docs, or release instructions directly affected by behavior must stay synchronized when implementation is authorized.
- A new safety, UI, deploy, or cross-file invariant belongs in the project's existing instruction surface only when that surface exists and the invariant is clear.
- Do not create a new documentation system, ADR, OpenSpec, or permanent memory from a review alone. Recommend the target and obtain authorization.
- One-off review reports or diagnostic snapshots are evidence, not evergreen guidance. Extract only stable invariants, and only into the correct project or shared layer.

### Snapshot Report Routing

Treat review reports, scorecards, and diagnostic snapshots as evidence, not as source-of-truth docs. Before approving one:

1. Re-read the current diff or repo surface named by the report. If the claim is stale, exclude the report from the commit or rewrite it into a stable rule.
2. Keep project-specific commands, paths, protected areas, release rituals, and safety constraints in that project's own context (CLAUDE.md, project skills). Do not promote them into the shared skills repo (vendyluo/skills).
3. Promote only transferable review behavior into the shared skills repo: e.g. "check untracked files before readiness", "inspect generated package contents", or "turn one-off reports into invariants."

In read-only review, report any required sync or durable-doc candidate without editing. When the user requested review-and-fix or implementation is already authorized, update directly affected existing docs; get separate approval before creating a new documentation or memory surface.

## Specialist Review (Standard and Deep only)

Load `references/persona-catalog.md` to determine which specialists activate. Launch all activated specialists in parallel via the environment's agent or sub-agent facility when available, passing the full diff. If no parallel reviewer facility exists, run the specialist passes sequentially in the same session.

Merge findings: when two specialists flag the same code location, keep the higher severity and note cross-reviewer agreement. Findings on different code locations are never duplicates even if they share a theme.

Treat each specialist finding as a claim to verify, not a fact to act on. Before routing a finding to Fix Routing or sign-off, re-read the cited code this turn and confirm it is real and live: not already handled elsewhere, not consistent-by-design, not a latent-only risk labeled as a live bug. Parallel reviewers over-report from name-based inference and partial context; drop or downgrade what dissolves on direct read, and cite the verification path.

## Fix Routing

Apply no fix during a review-only request. When the user explicitly requests review-and-fix or implementation is already authorized, route findings as follows:

| Class | Definition | Action |
|-------|------------|--------|
| `scope_local` | Unambiguous and within the authorized outcome: typo, missing import, directly affected existing docs | Apply and verify |
| `behavioral` | Changes behavior but stays inside the authorized contract | Apply only when that behavior is part of the implementation authorization; otherwise ask once |
| `structural` | New abstraction or foundational rewrite | Present current cost, smallest non-rewrite fix, migration, and complexity removed; obtain separate approval |
| `contract` | External contract, consumer migration, or coordinated rollout | Stop and present the contract impact and alternatives; obtain explicit approval |
| `advisory` | Informational only | Note in sign-off |

## Adversarial Pass (Deep only)

"If I were trying to break this system through this specific diff, what would I exploit?" Four angles (see `references/persona-catalog.md`): assumption violation, composition failures, cascade construction, abuse cases. Suppress findings below 0.60 confidence.

## Platform Operations

Use the platform tool that matches the project. For GitHub projects, prefer `gh` or the available GitHub integration and confirm CI passes before merging. For non-GitHub projects, derive the CLI/API from public project docs or the user's explicit platform context; do not force GitHub commands onto other hosts.

Poll CI as structured state, not streamed text: `gh run view <id> --json status,conclusion` (or the host's equivalent). Piping `gh run watch`, test output, or build output through `tail`/`head` swallows the real exit code and can report a failed or still-running run as green.

## Verification

Run the project's documented relevant verification command. If none is documented and this skill's `scripts/run-tests.sh` is available, use it as discovery fallback from the target project root. Record the command and result.

If verification fails, classify product failure versus setup failure and do not claim a pass. If no relevant command exists, report `verification: unavailable -- no project command or honest runtime check found`; that is a gap, not a pass. If the user explicitly instructed the current task to skip local checks, report `local verification skipped by instruction` and keep CI or runtime state separate.

For bug fixes, require the narrowest durable guard that would fail on the unfixed behavior. Prefer the project's existing test boundary. Do not demand a new abstraction or hollow unit test when a deterministic runtime or artifact check is the honest verifier; surface any missing automation separately.

In a dirty or multi-agent checkout, first decide whether unrelated WIP can materially supply symbols, alter generated state, or change the verifier. If yes, verify the owned patch in an isolated worktree or equivalent clean environment. If not, the targeted local result is still valid; do not create isolation ceremony without a plausible contamination path.

## Gotchas

| What happened | Rule |
|---------------|------|
| Posted a public reply to the wrong issue or PR thread | Re-read the target with `gh issue view N` or `gh pr view N` and confirm title, author, and current state before acting |
| PR comment sounded like a report | 1-2 sentences, natural, like a colleague. Not structured, not AI-sounding. |
| PR comment used bullet points | Write as short paragraphs, one thought per paragraph; thank the contributor first |
| New file name duplicated a locale, platform, or suffix convention | Check the target directory's existing naming convention before creating or renaming files |
| Deployed without provider runtime or env checks | Follow the project's public deployment docs and compare provider config with local required env and runtime settings |
| Push failed from auth mismatch | Check `git remote -v`, current branch, and auth identity before the first push in a new project |

## Document Review

Route prose, content, tone, and localization review to `/write` Document Review Mode. Document or print typography, paged layout, and artifact aesthetics belong to a dedicated document-design workflow when one is available. Broken rendering, page breaks, or font output belong to `/hunt` Rendering Bug Mode. `/check` handles code diffs and release artifacts only.

## Sign-off

Open the final message with one plain status line: the review verdict, implementation state if applicable, local verification state, and CI/release state only when known. A verdict buried under a table reads as unfinished. Include only the detail lines that help the user act next.

```
status:           [review complete, no blockers / changes required / blocked on <what>]
implementation:   [not requested / fixed locally / committed as <hash>] when applicable
files changed:    N (+X -Y)
scope:            on target / drift: [what]
review depth:     quick / standard / deep
hard stops:       N found, N fixed, N deferred
sibling sweep:    N same-shape sites checked, N fixed / none found / not applicable
specialists:      [security, architecture] or none
new tests:        N
doc debt:         none / AGENTS.md needs X / rules need Y
local verification: [command] -> pass / fail / skipped by instruction / unavailable
CI/release gate:  passed / pending / not checked / not applicable
```
