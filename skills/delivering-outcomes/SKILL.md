---
name: delivering-outcomes
description: Provides an optional delivery checklist. Use when the user explicitly requests the delivering-outcomes skill, not for routine implementation.
---

# Delivering Outcomes

Deliver the smallest complete, verified result within the user's authorized scope. Do not reopen settled choices unless current evidence makes them unsafe or unworkable.

## Completion contract

Infer the intended result and completion evidence from the request and relevant project guidance. For a simple change, keep this reasoning internal; do not require a plan, checklist, or approval ceremony.

Implementation includes directly affected tests, tracked generated artifacts, and existing documentation when needed. Preserve unrelated work and observable contracts. Fix sibling sites only when they share the confirmed cause, remedy, risk, and verification path.

## Carry the work through

Inspect the owning code and relevant consumers, then change the source of truth using existing patterns. Avoid speculative abstractions or unrelated cleanup.

Continue through implementation, relevant local checks, and repairs caused by the change. A first pass, an internal phase transition, or a selected implementation detail is not a reason to hand the task back. Carry existing authorization forward; ask only when a remaining decision or effect is outside it. Complete independent authorized work before reporting a blocker.

Respect Amp's approval and tool boundaries. Do not infer permission to push, merge, publish, deploy, delete non-disposable data, or reply externally from implementation success. When an external effect has an unknown outcome, reconcile state before retrying.

## Evidence and stopping

Use the smallest check that can expose a plausible defect at the affected boundary; broaden coverage with blast radius. Follow required project checks. Inspect rendered output for visual changes and exercise interactions for behavioral changes when available.

Reuse evidence that still covers the exact current state. Rerun checks invalidated by edits; do not repeat valid checks without a new reason. Never weaken acceptance criteria or tests to obtain a pass.

Stop when the requested result and applicable checks are complete, or when a concrete blocker requires user action. Do not add a review round, framework, or adjacent feature merely because the work is finished.

Report the outcome, meaningful verification, and remaining limitations. Distinguish local results from CI or release status only when relevant; do not force a fixed status template onto every task.
