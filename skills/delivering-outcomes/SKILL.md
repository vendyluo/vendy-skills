---
name: delivering-outcomes
description: Delivers an explicitly authorized, already-decided implementation or artifact as the smallest complete verified slice. Use when direction and scope are settled and the user asks to implement, change, produce, or finish the outcome.
---

# Delivering Outcomes

Execute an accepted direction without reopening settled design. Produce the smallest complete slice, preserve unrelated work, verify the real outcome, and report exactly what is complete.

## Use This Skill For

- explicitly authorized implementation;
- applying an approved plan or decided repair;
- producing an already-specified artifact;
- completing a bounded repository change;
- finishing directly affected tests and existing documentation.

Do not use it when the outcome or architecture is still undecided, when a reported failure still lacks root cause, or when the request is read-only evaluation. This skill is not a container for specialized UI, writing, or research manuals; use relevant project or specialist guidance for those surfaces.

## Re-establish the Accepted Outcome

Before editing, identify:

- the accepted result and observable completion evidence;
- files, systems, and behavior in scope;
- explicit non-scope and settled decisions;
- applicable project guidance and verification commands;
- authority granted by the current request.

Inspect current repository and runtime state for material drift. Do not reopen settled choices merely because another option seems cleaner. Reconsider them only when new evidence makes the accepted direction unsafe, impossible, contract-breaking, or unable to achieve the outcome.

## Protect Existing Work

Check the worktree before editing. Leave pre-existing changes outside the task untouched, regardless of whether they are indexed or untracked. Never reset, stash, clean, overwrite, relocate, or absorb them. Isolate changes when needed and touch only the task's surface.

Follow scoped project instructions and existing reasonable patterns. Do not add a wrapper, framework, shared layer, dependency, or future flexibility merely to make the implementation look uniform.

## Execute the Smallest Complete Slice

Work from the outcome inward. A complete slice includes what the real behavior requires:

- implementation at the correct source of truth;
- focused tests or deterministic checks;
- generated artifacts when the project tracks them;
- existing documentation directly affected by behavior;
- same-root-cause siblings only when their cause, risk, remedy, contract, and verification match.

Keep unrelated cleanup out. Local refactoring is appropriate only when necessary for the authorized result and does not alter unrelated behavior.

Prefer the least powerful sufficient mechanism. Use direct code or tools when they solve the problem; do not introduce AI, nondeterminism, autonomy, or broader permissions without an accepted reason.

## Respect Authority Boundaries

Implementation authorization covers the complete local slice and its relevant local verification. It does not automatically authorize:

- new shared abstractions or foundational rewrites;
- external contract changes or consumer migration;
- destructive cleanup or irreversible action;
- permanent memory or a new documentation system;
- push, force-push, merge, release, deploy, issue closure, or public reply.

If execution reaches one of these boundaries, stop before the effect. Present the evidence, impact, alternatives, and exact decision required. Do not infer authority from earlier success or from the ability to perform the action.

## Handle Failures Deliberately

Read errors before changing approach. Form a focused explanation and gather new evidence; do not retry an unchanged action merely because it might pass. If the accepted plan no longer works, distinguish implementation defect, environment limitation, stale assumption, and new product or contract decision.

Keep unresolved uncertainty visible. When an external effect may have happened but cannot be safely established, report it as unknown and reconcile or contain it rather than retrying blindly.

## Verify the Outcome

Choose checks that support the requested claim. Run relevant local verification whenever available unless explicitly told to skip it.

Use the real boundary:

- tests for logic and regressions;
- runtime observation for behavior;
- rendered output for UI or documents;
- built and installed artifacts for distribution;
- schemas and consumer checks for contracts;
- current status from the external system for external effects.

Any code change invalidates earlier evidence for the changed surface. Do not weaken tests, suppress failures, hard-code test exceptions, or redefine the outcome to manufacture a pass.

If a prerequisite is unavailable, report local verification as blocked or unavailable. Do not call it a pass. Local success does not imply CI, merge, release, deployment, or production success.

## Report Completion Precisely

Lead with the delivered outcome. Name files or systems changed and the evidence that proves the result. Report only applicable states, separately:

- `implementation complete` or `implementation incomplete`;
- `local tests passed`, `local verification blocked`, or `local verification skipped by instruction`;
- `CI pending`, `CI passed`, `CI failed`, or `CI not applicable`;
- `ready for merge/release` only when all relevant gates are actually satisfied.

Include remaining uncertainty, blocked authority surfaces, and unrelated issues discovered but not changed. Never claim a commit, push, merge, release, deployment, or external reply that did not occur.
