Work from the pasted data only.

Input bundle: settings.local.json, GITIGNORE, CLAUDE.md (global), CLAUDE.md (local), hooks, MCP FILESYSTEM, MCP ACCESS DENIALS, allowedTools count, skill descriptions, CONVERSATION EXTRACT

Tier: [SIMPLE / STANDARD / COMPLEX]. Use the matching tier only.

## Part A: Control + Verification Layer

Hooks checks:
- SIMPLE: Hooks are optional. Only flag broken ones, for example wrong file types.
- STANDARD+: Hooks remain optional. Recommend one only when a repeated, deterministic, low-false-positive failure is better enforced mechanically than by instructions or normal verification.
- COMPLEX: Coverage follows consequential write paths and proven failure history, not every frequently edited file type.
- ALL tiers: If hooks exist, verify schema:
  - Each entry needs `matcher` and a `hooks` array
  - Each hook needs `type: "command"` and `command`
  - File path may be available via `$CLAUDE_TOOL_INPUT_FILE_PATH`
  - Missing `matcher` fires on all tool calls
- ALL tiers: Flag full test suites on every edit, prefer fast checks for immediate feedback.
- ALL tiers: Flag commands without output truncation, unbounded output floods context.
- ALL tiers: Flag commands without explicit failure surfacing.

allowedTools hygiene, ALL tiers:
- Flag genuinely dangerous operations only: sudo *, force-delete root paths, *>* and git push --force origin main
- Do NOT flag: path-hardcoded commands, debug/test commands, brew/launchctl/maintenance commands -- these are normal personal workflow entries

Credential exposure, ALL tiers:
- Project-scoped secrets are [!] only if committed, shared, or stored in non-gitignored project files
- Treat `ignored only by non-project rule (...)` in the GITIGNORE section as insufficient; recommend a repo-local ignore rule.
- Do NOT flag user-scoped files like `~/.mcp.json` just because credentials are intentionally stored there

MCP configuration, STANDARD+:
- Check enabledMcpjsonServers count, >6 may impact performance
- Check filesystem MCP has allowedDirectories configured
- If `~/.claude/projects/.../tool-results/*` denials show breakage, output a `python3` one-liner that appends the narrowest missing path

Model name validation, ALL tiers:
- Check settings.local.json for `model` fields. Valid model IDs follow the pattern `claude-*` (e.g., `claude-opus-4-6`, `claude-sonnet-4-6`, `claude-haiku-4-5-20251001`). Any non-`claude-*` model ID (e.g., a provider-specific alias or outdated name) is [!] -- a wrong model name silently wastes the entire session with no output.
- If a model name looks like a third-party alias or contains unusual characters, flag it for manual verification.

Prompt cache hygiene, ALL tiers:
- Check CLAUDE.md or hooks for dynamic timestamps/dates in system context, they break prompt cache
- Check if hooks or skills non-deterministically reorder tool definitions
- Flag mid-session model switches like Opus→Haiku→Opus, they rebuild cache and can cost more
- If model switching is detected, recommend subagents instead

Three-layer defense consistency, STANDARD+:
- For safety-critical rules, inspect intent, method, and deterministic control layers only when each adds distinct value.
- Do not require every rule to be duplicated across instructions, a skill, and a hook. A clear instruction is enough for judgment; a hook is justified only when the condition is mechanically detectable with acceptable false positives.
- Flag missing layers when an observed violation proves the current layer is insufficient, especially for file protection, destructive actions, verification claims, and deploy gates.

Verification checks:
- SIMPLE: No formal verification section required. Only flag if Claude declared done without running any check.
- STANDARD+: Relevant verification must be discoverable in existing project instructions, scripts, manifests, or CI; a dedicated section is optional.
- COMPLEX: Consequential task types should map to an honest verification path. Do not invent wrappers or tests where a current runtime or artifact check is the real boundary.

Subagent hygiene, STANDARD+:
- Flag Agent tool calls in hooks that lack explicit tool restrictions or isolation mode.
- Flag subagent prompts in hooks with no output format constraint -- free-form output pollutes parent context.

## Part B: Behavior Pattern Audit

Data source: the smallest authorized conversation sample that can establish or refute the pattern. Start recent and expand only when the user requested deeper history or the initial sample leaves the pattern uncertain. Only flag clear evidence. Tag each finding [HIGH CONFIDENCE] or [LOW CONFIDENCE].

This section owns repeated corrections, missing patterns, and observable rule violations. Do not duplicate Agent 1's rule-design or context-budget recommendations here.

1. Rules violated: quote the NEVER/ALWAYS rule and observed violation. No inference.
2. Repeated corrections: same issue corrected in at least 2 conversations.
3. Missing local patterns: project-specific behaviors reinforced in conversation but missing from local CLAUDE.md.
4. Missing shared patterns: cross-project behaviors not captured by the shared profile, rule, or relevant skill. Recommend a durable update only with repeated evidence and user approval.
5. Skill frequency, STANDARD+: only report directly observed usage. When the available sample cannot support a frequency claim, mark [INSUFFICIENT DATA]. Low frequency alone is not a reason to retire a useful specialist skill.
6. Anti-patterns: only flag what is directly observable:
   - Claude declaring done without running verification
   - User repeatedly re-explaining stable project facts across sessions: the existing project instruction surface may be missing goal-relevant context; do not assume HANDOFF.md or permanent memory is the answer
   - A session mixes changed goals or independently deliverable outcomes; thread length alone and runtime-specific `/compact` or `/clear` usage are not failures

Return bullet points under two sections:
[CONTROL LAYER: hooks issues | allowedTools to remove | cache hygiene | three-layer gaps | verification gaps | subagents issues]
[BEHAVIOR: rules violated | repeated corrections | project guidance candidates | shared guidance candidates | skill frequency | anti-patterns (tag each with confidence level)]
