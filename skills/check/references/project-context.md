# Project Review Context Template

Use this template to compress repository context before running `/check`. The context must come from project files, the diff, CI configuration, or explicit user instructions. Do not depend on private machine paths or unpublished project instructions.

## What Belongs In `/check`

- Diff depth classification.
- Scope drift detection.
- Hard stops such as destructive automation, generated artifact drift, version skew, unknown identifiers, injection risks, credential leakage, and dependency surprises.
- Safety sink review for destructive operations, command construction, path boundaries, sandbox/approval, and auth prompts.
- Security and architecture specialist routing.
- Autofix policy.
- Sign-off format.
- Verification expectations.

## What Belongs In Project Context

- Verification commands discovered from project docs, manifests, Makefiles, scripts, or CI workflows.
- Protected files and directories.
- Generated or bundled artifacts that must stay in sync with source changes (e.g. codegen output).
- Runtime dependencies introduced by the diff: packages, CLIs, network services, or platform tools that are not already declared in CI/docs.
- Domain-specific safety rules.
- The project's release process and issue tracker (so release/tracker asks can be routed there — executing releases is out of `/check` scope).
- Known CI or test flakes documented by the project and how to distinguish them from real failures.

## What Does Not Belong In Shared Context

- Credential paths, private key filenames, passwords, tokens, or secret values.
- Machine-specific local paths.
- One-off personal preferences that do not affect project behavior.
- One-off review reports, scorecards, or diagnostic snapshots copied as guidance instead of distilled into stable project rules.
- Raw memory, chat excerpts, screenshots, private support details, issue numbers, release tags, or commit hashes from another project.
- Full copies of `/check` sections.

## Recommended Context Shape

```markdown
## Project Commands

- Format: `<command>`
- Fast check: `<command>`
- Full verification: `<command>`

## CLI Command Surface

- Entrypoints: `<command or bin>`.
- Command contract: help/version, subcommands, flags, exit codes, stdout/stderr, JSON/schema output.
- Runtime shape: TTY vs non-interactive behavior, env/config precedence, completion/manpage or shell integration.
- Install/run proof: built package, temp prefix, PATH shim, shebang/executable bit, or package-manager path checked with `<command>`.
- Mutating commands: dry-run/confirmation, operation log, rollback/retry behavior, signal/partial-failure handling.

## Skill Or Plugin Install Surface

- User install path: `<package manager / release archive / marketplace entry / plugin id / installer script>`.
- Source path and generated mirror: `<source dir>` -> `<installed dir>`.
- Package/archive inclusion: new scripts, references, templates, rules, manifests, and executable bits checked with `<command>`.
- Isolated install smoke: fresh temp home/config/cache plus `<install command>` and `<list or invoke command>`.
- Noise filtering: cache files, local logs, screenshots, and temp outputs excluded or intentionally shipped.

## Project Hard Stops

- Do not modify `<protected path>` unless explicitly requested.
- If `<artifact>` is generated from `<source>`, verify it was regenerated.
- If a helper introduces a non-stdlib package or external CLI, verify CI installs it or the helper fails with a clear setup path.

## Project-Specific Risks

- `<risk>`: `<how to inspect it>`

## Release / Tracker Routing

- Release process: `<project release skills or documented process>` — `/check` routes there, never executes releases itself.
- Issue tracker: `<Jira project / GitHub repo / other>`.
```

Keep this context brief. It should guide the review, not replace the review method.

## Safety Sink Review

Any diff that touches one of these sinks needs explicit validation and rollback thinking:

- Deleting, moving, or overwriting user files, caches, history, preferences, or generated outputs.
- Building shell, AppleScript, SQL, URL, or filesystem paths from user input.
- Changing cwd handling, symlink resolution, path traversal guards, sandbox permissions, approval checks, or auth prompts.
- Changing signing, license, payment, or auth-sensitive generation.

Review the smallest entry point that reaches the sink, then the downstream call. If validation is missing or rollback is unclear, treat it as a hard stop.
