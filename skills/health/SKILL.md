---
name: health
description: "Runs a budget-aware agent-assisted engineering health audit for instruction/config drift, hooks/MCP, verifier surfaces, and AI maintainability. Use when users ask in any language to audit Claude, Codex, Pi, agent instructions, MCP or hooks, verifier coverage, or AI-maintainability drift. Not for debugging application code or reviewing PRs."
---

# Health: Agent-Assisted Engineering Health

Audit the current project's agent setup and AI coding maintainability against this framework:
`agent config → instruction surfaces → tools/runtime → verifiers → maintainability`

Find violations. Identify the misaligned layer. Calibrate to project complexity only.

## Outcome Contract

- Outcome: a budget-aware health report that separates agent configuration risk from AI maintainability risk.
- Done when: each finding names the misaligned layer, the concrete evidence, and a copy-pasteable action or diagnostic command.
- Evidence: collected health script output, tracked project instructions, runtime config summaries, verifier logs, hooks/MCP surfaces, and live probes when needed.
- Output: prioritized findings with status, impact, and next action, or a clear clean bill with residual risk.

Two lanes share one report:

- **Agent config health**: supported runtime instruction drift, permissions, hooks, MCP, skills, and memory supply chain.
- **AI maintainability health**: project context surface, verifier wrapper, generated-artifact checks, hotspot ownership, and stale or misleading durable docs.

**Output language:** Check in order: (1) project agent instructions (`AGENTS.md` before runtime-specific files); (2) global agent instructions; (3) user's recent language; (4) English.

**Budget posture:** Start with the summary audit. Escalate automatically when the user asks for a deep, full, complete, thorough, "深入", "完整", "徹底", or "繼續跑完" audit, when the user explicitly mentions AI coding code rot, Codex/Claude config drift, unclear context, missing verification, verifier output that points at stale paths, or "程式碼變爛", when current project instructions or remembered user preference says to run deep health checks by default, when the project is Complex, or when the summary pass exposes a critical ambiguity that cannot be resolved locally. Otherwise do not read full conversation extracts or launch inspector subagents. Tell the user before escalating because deep health audits can consume significant token quota.

## Durable Context Preflight

See [references/durable-context.md](references/durable-context.md) for when to read durable context, the read-order budget, and the memory-type mapping.

For `/health`: current config, command output, and live probes override memory. Also flag durable memory problems when they affect behavior: oversized injected summaries, stale or contradictory entries, missing project entrypoint references, or private paths copied into public instructions. Keep these as context findings, not code-review findings.

## Step 0: Assess project tier

Pick one. Apply only that tier's requirements.

| Tier | Signal | What's expected |
|---|---|---|
| **Simple** | One owner, one primary runtime, low external impact, direct verification path | Only the instruction and verifier surfaces the project actually needs |
| **Standard** | Collaborators, CI, production users or data, generated artifacts, or multiple agent runtimes | Tracked project instructions plus clear verification and ownership of consequential boundaries |
| **Complex** | Multiple services or teams, external contracts, migrations, irreversible delivery, or high rollback cost | Explicit source-of-truth map, coordinated verifiers, risk boundaries, and stop conditions where autonomous work exists |

File count, personal/company labels, and number of installed skills do not determine the tier by themselves.

## Step 1: Collect data

Run the collection script in summary mode first. Do not interpret yet.
Replace `<skill-base-dir>` with the base directory reported by the runtime when this skill loads.

```bash
HEALTH_SCRIPT="<skill-base-dir>/scripts/collect-data.sh"
bash "$HEALTH_SCRIPT"
```

Sections may show `(unavailable)` when tools are missing:

- `jq` missing → conversation sections unavailable
- `python3` missing → MCP/hooks/allowedTools sections unavailable
- `settings.local.json` absent → hooks/MCP may be unavailable (normal for global-only setups)

Treat `(unavailable)` as insufficient data, not a finding. Do not flag those areas.

The collector includes both runtime-specific and agent-agnostic surfaces:

- `AGENT CONFIG SUMMARY` / `AGENT CONFIG DETAIL` for Codex, Claude, Pi, and project instruction files.
- `AI MAINTAINABILITY SUMMARY` / `AI MAINTAINABILITY DETAIL` for project shape, verification surface, hotspot ownership, wrappers, and doc links.

## Step 1b: MCP Live Check

Test every MCP server: call one harmless tool per server. Record `live=yes/no` with error detail. Respect `enabled: false` (skip without flagging). For API keys, only check if the env var is set (`echo $VAR | head -c 5`), never print full keys.

## Step 1c: Safety and security checks

These run after collection and before the Step 2 analysis. The first two apply to every audit; the third only to projects with long-running or autonomous agents.

### Security Baseline Checks

Run these on every audit, regardless of tier. They are the floor, not the ceiling.

**Deny-list floor.** Apply this only when the runtime actually enforces the rule shape being recommended: agent permission settings, hook settings, MCP settings, allowed/denied tools, or a documented autonomous-agent launcher. In that case, the settings should deny, at minimum: credential and key directories (SSH, cloud providers, GPG, gh CLI), secret files (`.env`, `credentials*`, `secrets*`), and pipe-to-shell installers. Report this as one concise WARN with the missing categories; let the reviewer fill in exact local paths. Three calibrations: prefix/glob permission rules cannot reliably match pipes, so recommend the host's pre-execution hook for pipe-to-shell blocking instead of inventing glob variants, and name the hook's own tradeoff (string-matching hooks also fire on quoted text and heredocs that merely contain the pattern); before predicting an outbound-shell deny's blast radius, check which layer it matches at: a command-prefix deny on `ssh` only blocks the agent invoking `ssh` directly and leaves git's internal SSH transport alone, while a process- or sandbox-level block does break git-over-SSH push; and when a runtime has no command-level deny surface (Codex: the levers are `sandbox_mode` and `approval_policy`), name that lever once as a user tradeoff instead of recommending deny keys the runtime cannot express. If no agent settings surface exists at all, report the deny-list as not applicable rather than a failure.

**Permission-layer vs instruction-layer gating.** An allowlist entry for a git write action (`git push`) next to an instruction-layer rule ("push only when the user says so") is not automatically a contradiction: instructions decide when the action happens, permissions decide whether it re-prompts, and a user who explicitly authorizes pushes every session may keep push in allow deliberately to avoid double confirmation. Calibrate by reversibility and the user's own rules: actions the instructions forbid outright (`git reset --hard`, `git stash`, force-push) belong in deny or ask; routine explicitly-authorized actions stay where the user put them, reported at most as a note. Escalate only when auto mode plus skipped prompts plus broad allow lets a write action run with zero user input in a session, and even then present the friction tradeoff for the user to choose instead of silently moving entries.

**Environment override surface.** Treat the following as attack surface, report when set in tracked files or shipped settings without a justification comment: API base-URL overrides (redirect all traffic to a third party), auto-trust flags for project-local MCP servers, wildcard tool allowlists (`allowedTools: ["*"]`), and permission-skip flags (`--dangerously-skip-permissions` or equivalents). Print file:line and the key name only; never print secrets.

### Memory and Skill Supply Chain

Treat agent memory and third-party skills as supply-chain artifacts. They run with the user's privileges.

**Memory hygiene.** By default audit only whether a memory surface exists, its provenance, and whether risky runs could persist into it. Read or scan permanent memory contents only when the user explicitly puts them in scope (`HEALTH_INCLUDE_MEMORY=1`). When in scope, secrets or credentials are Critical, and entries written by untrusted runs require rotation or removal. For high-risk one-off runs, recommend disabling memory persistence before the run.

**Skill supply chain.** Third-party skills, plugins, and MCP servers run with the user's privileges. For each one not authored in this repo, check: source pinned to a release tag or revision (not `main`, a branch, or a remote git marketplace left tracking its latest head), hook handlers do not write to credential directories, MCP servers have explicit user consent (not auto-trusted by wildcard). Report unpinned sources or unreviewed hook handlers as Structural, not Critical, unless an active exploit signal is present.

### Long-Running Agent Stop Conditions

For projects that use `/loop`, autonomous agents, or another long-running flow, verify that the execution can recognize stagnation, hard blockers, and any cost or side-effect boundary that matters. Do not require a generic stop-condition document for a bounded or human-supervised flow.

Useful signals include:

1. **No meaningful progress across checkpoints.** The same files and errors recur with no new evidence, verification, or usable output. Surface the state instead of retrying the same action.
2. **Repeated identical failure.** The same stack trace, error, or assertion survives supposedly different attempts. Revisit the hypothesis before spending more attempts.
3. **Cost or time boundary.** When the flow can consume material tokens, API spend, compute, or wall time, the launcher or supervising system should expose a suitable limit or checkpoint.
4. **External blocker.** Merge conflicts, missing credentials, unreachable services, or an unresolvable dependency state should pause work rather than loop indefinitely.

Report a Structural gap only when an actual long-running path can retry, spend, or mutate without a credible bound. Put the fix in the smallest existing launcher, workflow, config, or project instruction surface. Recommend a hook only for a deterministic, repeated condition the host can enforce with low false positives; otherwise a runtime checkpoint or explicit supervisor state may be simpler and more honest.

## Step 2: Analyze

Confirm the tier. Then route:

- **Simple:** Analyze locally. No subagents.
- **Standard:** Analyze locally from the summary output. Do not launch subagents by default. If the user asks for a deep/full/thorough audit, or if local analysis cannot classify a security/control issue, escalate to deep mode and explain the likely token cost.
- **Complex, remembered deep preference, explicit deep audit, or explicit AI maintainability audit:** Re-run collection with `bash "$HEALTH_SCRIPT" auto deep`, then launch the relevant subagents in parallel. Redact credentials to `[REDACTED]`. Deep mode reports only memory metadata by default; set `HEALTH_INCLUDE_MEMORY=1` only when the user explicitly put permanent memory contents in scope.
  - **Agent 1** (Context + Security): Read `agents/inspector-context.md`. Feed `CONVERSATION SIGNALS` section.
  - **Agent 2** (Control + Behavior): Read `agents/inspector-control.md`. Feed the tier confirmed from project risk and coordination evidence, not the collector's provisional estimate alone.
  - **Agent 3** (AI Maintainability): Read `agents/inspector-maintainability.md`. Feed only `TIER METRICS`, `AI MAINTAINABILITY SUMMARY` or `AI MAINTAINABILITY DETAIL`, and the script hotspot lists. Launch this agent only for deep health audits, Complex projects, or explicit code-rot/AI-maintainability requests.
- **Fallback:** If a subagent fails, analyze that layer locally and note "(analyzed locally)".

## Step 3: Report

**Health Report: {project} ({tier} tier, {file_count} files)**

**Global findings report once.** Findings in machine-global config (`~/.claude`, `~/.codex`, global rules, skills, memory) are not project findings: label them `global`, report each once with its fix, and recommend one dedicated session for global cleanup instead of re-fixing per project. Before editing any global file, re-read its current state: when health runs across several projects in one day, another session may already have fixed or be mid-fix on the same file, and re-applying a variant of the same rule creates duplicate entries. Never edit the same global file from two concurrent sessions.

### [PASS] Passing checks (table, max 5 rows)

### Finding format

```
- [severity] <symptom> ({file}:{line} if known)
  Why: <one-line reason>
  Action: <exact command or edit to fix>
```

`Action:` must be copy-pasteable. Never write "investigate X" or "consider Y". If the fix is unknown, name the diagnostic command.

A finding refuted in the same breath (a TODO count that turns out to be vendored code or false positives) is not a finding; drop it or fold it into the passing table.

### [!] Critical -- fix now

Active credential exposure, dangerous wildcard execution, proven untrusted code execution, or another directly exploitable security boundary.

Example:

- [!] `settings.local.json` committed to git (exposes MCP tokens)
Why: leaked token enables remote code execution via installed MCP servers
Action: `git rm --cached .claude/settings.local.json && echo '.claude/settings.local.json' >> .gitignore`

### [~] Structural -- fix soon

Instruction/config drift, broken verifier surfaces, materially wasteful MCP or context load, risky but not actively exploited supply-chain configuration, and missing controls whose failure path is concrete.

Agent instructions in the wrong layer, absent enforcement for a demonstrated repeated deterministic failure, descriptions that cause concrete misrouting or material context displacement, and verifier gaps.

**Behavioral wiring changes.** When routing, bootstrap, skill discovery, hook injection, or compaction reinjection behavior changes, static validation, YAML parsing, and registration tests prove only structural integrity. Run a clean session in the affected runtime and observe the intended trigger or reinjection; until then report that behavior as `UNVERIFIED`, exclude it from passing checks, and do not issue a clean bill of health.

**Codex/Claude/Pi instruction drift.** Use `AGENT CONFIG SUMMARY` first. Report a Structural finding when `AGENTS.md` and runtime-specific files contain conflicting substantial guidance without clear delegation, when Codex trust or Pi skill roots are misconfigured, when runtime-specific instructions contradict the shared project source of truth, or when observed collaboration or repeated-agent failures show a missing project instruction surface. Absence alone is informational. Also report when important distributed rules live only in ignored overlays; private overlays can inform an audit but are not durable project truth. Do not print raw config values. Secrets, tokens, keys, and passwords appear only as `[REDACTED]`.

Quick check from the project root, reusing `$HEALTH_SCRIPT` resolved in Step 1:

```bash
bash "$(dirname "$HEALTH_SCRIPT")/check-agent-context.sh" . summary
```

**AI-maintainability gaps.** Use `AI MAINTAINABILITY SUMMARY` in summary mode and `AI MAINTAINABILITY DETAIL` in deep mode. Report `FAIL` when a consequential project has no executable or honest runtime verification path, or when broken references direct agents to dead requirements. Treat a missing project instruction surface as `WARN` only when collaborators, repeated agent mistakes, multiple modules, or risky boundaries make that absence observable; do not require instruction files by repo size alone. Also report `WARN` for unclear project maps, verification or boundary guidance, concentrated TODO/HACK markers, consequential hotspots without stable responsibility or verification, and raw scorecards or dated diagnostic dumps presented as durable truth. Missing `docs/`, specs, handoff files, changelogs, templates, and formal planning artifacts is informational unless an actual coordination or continuity failure makes one necessary.

**Conversation-derived guidance.** When a health audit reads recent agent conversations, do not recommend copying the conversation or a scorecard into docs. Recommend a candidate-matrix pass instead:

| Field | Question |
|---|---|
| Repeated failure | Did this recur across fixes, releases, agents, or user reports? |
| Durable invariant | Can the lesson be stated as a stable rule, not a dated incident summary? |
| Target layer | Should it live in project instructions, a shared skill or rule, or private memory? |
| Verifier | Is there a deterministic command, script, artifact check, or runtime smoke that can enforce it? |
| Redaction risk | Does the lesson require local paths, issue numbers, customer details, machine state, secrets, or unpublished release facts? |

Layering rule: project-specific commands, app names, artifact names, and release rituals stay in the project; reusable workflows belong in shared skills; universal judgment and authorization rules belong in the shared profile or rules; private preferences and one-machine facts stay out of tracked guidance unless the user explicitly chooses a private memory surface. If the lesson cannot pass the redaction-risk field, keep it out of durable shared guidance.

**Concentrated fix chains.** Use recent history to find areas repeatedly fixed within a short window. Repetition is a lead, not proof of a missing abstraction or rule: read the changes and confirm they converge on the same invariant or failure class. When they do, report the invariant and the smallest useful verifier or existing instruction surface that could preserve it. Do not recommend a rewrite or new documentation layer from commit count alone.

**Hotspot boundary gaps.** In deep mode, read `HOTSPOT OWNERSHIP SURFACE`. File size is only a lead. Report a Structural `WARN` when a consequential module has unclear responsibility or invariants, repeatedly attracts fixes, crosses ownership or deployment boundaries, and lacks a reliable verifier. Do not require ownership prose for a large but coherent module merely because it crossed a line-count threshold.

**Missing stable verifier entrypoint.** If the repo exposes multiple verification commands through CI, scripts, or manifests and project guidance does not make the relevant choice clear, report a Structural `WARN`. Recommend documenting or reusing the smallest existing canonical entrypoint. Do not require a Makefile or add a wrapper when current commands are already unambiguous.

Quick check from the project root, reusing `$HEALTH_SCRIPT` resolved in Step 1:

```bash
bash "$(dirname "$HEALTH_SCRIPT")/check-maintainability.sh" . summary
```

For deep audits:

```bash
bash "$(dirname "$HEALTH_SCRIPT")/check-maintainability.sh" . deep
```

Keep actions concrete and non-invasive: repair the broken reference, clarify an existing instruction surface, expose the smallest honest verification path, or document a consequential boundary when collaborators need it. Split code or add a new artifact only when the boundary and value are already proven. Do not propose broad rewrites from script output alone.

**Broken doc references.** Scan `AGENTS.md`, `CLAUDE.md`, `.claude/rules/*.md`, and every `.claude/skills/*/SKILL.md` for references shaped like `@<path>`, `~/.claude/rules/<name>.md`, `~/.claude/skills/<name>/`, `docs/<name>.md`, or `references/<name>.md`. For each match, check that the target exists on disk. Report every "referenced but missing" pointer with the source file and line.

Common offenders:
- A project-level rule references a global rule file that was never created (e.g. `~/.claude/rules/swift.md`).
- A `CLAUDE.md` uses an `@AGENTS.md` placeholder but the actual `AGENTS.md` is missing or empty.
- A skill body references `references/<name>.md` but only `references/<name>-v2.md` exists.
- A rule file references a deleted skill path.

Quick check from the project root, reusing `$HEALTH_SCRIPT` resolved in Step 1:

```bash
bash "$(dirname "$HEALTH_SCRIPT")/check-doc-refs.sh" .
```

The checker resolves `@...` and `docs/...` from the project root, expands `~`, resolves `references/...` from each `.claude/skills/<name>/SKILL.md` directory, checks every reference on a line, skips fenced code examples, and exits non-zero when any target is missing.

Report missing references as Structural findings, not Critical, unless the missing file is named as a hard dependency (e.g. `release.md` for the project's release skill).

**Broken Markdown references.** In deep mode, `check-maintainability.sh` also scans repository Markdown links. Report these as Structural findings when they point to missing local files, especially design, security, release, or handoff docs that agents may follow during future work.

### [-] Incremental -- nice to have

Outdated items, global vs local placement, context hygiene, stale allowedTools entries.

---

If no issues: `All relevant checks passed. Nothing to fix.`

## Non-goals

- Audit-only requests do not authorize fixes. When the current request explicitly asks to fix findings, apply and verify scope-local corrections without asking twice; permanent memory, new architecture, destructive or shared external actions, and changes outside the requested surface keep their separate approval gates.
- Never apply complex-tier checks to simple projects.
- Never act as a heavy lint, typecheck, duplication, or architecture-rewrite substitute; `/health` reports maintainability guardrails and concrete next actions only.

## Gotchas

| What happened | Rule |
|---|---|
| Missed the local override | Always read `settings.local.json` too; it shadows the committed file |
| Subagent timeout reported as MCP failure | MCP failures come from the live probe, not data collection |
| Reported issues in wrong language | Honor CLAUDE.md Communication rule first |
| Flagged intentionally noisy hook as broken | Verify live behavior and documented intent before classifying it. If intent remains ambiguous, report it as unknown; ask only when deciding the desired behavior requires user judgment. |
| Hook seemed not to fire, but it did -- a later UI element rendered above it | Hook firing order is not visual order. Before re-editing the hook config: (a) confirm with `--debug` or by piping output, (b) check whether a diff dialog, permission prompt, or other UI element rendered on top and pushed the hook output offscreen, (c) only then suspect the hook itself. |
| `/health` burned too much quota on first run | Stay in summary mode first. Full conversation extracts and inspector subagents are deep-audit tools, not the default path for Standard projects. |
| Treated missing specs/docs as a failure | Decision artifacts are optional by default. Escalate missing docs/specs only when the tier, active handoff risk, or user request makes them necessary. |
| Treated an ignored AGENTS/CLAUDE file as durable project truth | Report whether the rule is tracked and distributed. Local overlays can inform the audit, but durable fixes belong in public repo docs or shipped skill/rule files. |
| Treated a review scorecard as maintainability documentation | Scorecards are snapshots. Extract the invariant and verification path, then remove or archive the report instead of calling the score itself a durable rule. |
