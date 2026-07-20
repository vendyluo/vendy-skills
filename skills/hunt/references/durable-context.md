# Durable Context Preflight

Shared preamble for every skill that reads optional memory or prior-decision context. Each `SKILL.md` links to this file and then adds skill-specific guidance.

## When to read durable context

Run the durable context steps only when one of these holds:

- The user mentions memory, preview, previous decisions, or a prior conclusion.
- The user provides a memory path.
- The current project exposes an obvious local memory summary (for example, a `MEMORY.md` or a documented memory directory).

Do not hard-code machine-specific memory roots. Do not read raw transcripts by default; use them only when the user explicitly puts session history in scope and a summary cannot establish a material detail.

## Read order and budget

Read durable context in this order: user-provided path, current project scope, then global preferences. List titles first and begin with the smallest relevant set of summaries. Expand only when the user requested deeper history or the initial evidence cannot establish the needed pattern. Treat cross-project entries as transferable patterns only.

## Memory distillation redaction gate

When turning prior chats, durable memory, or cross-project notes into reusable shared guidance, promote only transferable judgment or workflow rules. Strip raw transcript text, screenshots, local paths, project-specific commands, issue or PR numbers, release tags, commit hashes, private product boundaries, paid or license details, support routing, user names, and one-machine state.

If an example is necessary, use neutral placeholders such as `ExampleCLI`, `ExampleApp`, `<issue>`, `<release>`, or `<command>`. Do not copy a private answer, maintainer reply, screenshot observation, or project-specific incident as a durable rule.

## Memory type mapping

- `decision`, `preference`, and `principle` are constraints for the current task (planning, design, review, debugging, voice, audit expectations, etc., depending on skill).
- `pattern` and `learning` are reusable checks or hypotheses.
- `fact` must be verified against current state before it affects the output.

Current code, diff, screenshots, logs, tests, docs, CI, remote state, and live probes always override memory. If they conflict with a remembered claim, name the conflict and follow current state.

An in-session current-state summary is allowed. Creating or updating permanent memory requires explicit user approval.

Each skill adds its own paragraph below this reference for skill-specific overrides and constraints.
