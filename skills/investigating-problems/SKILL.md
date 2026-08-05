---
name: investigating-problems
description: Investigates failures, regressions, failing tests, crashes, and broken behavior to establish root cause and a verified repair. Use when something is reported as wrong or previously working behavior no longer holds.
---

# Investigating Problems

Move from an observed failure to a root cause, then make the narrowest repair that fully resolves it when implementation is authorized. A symptom patch is not a diagnosis.

## Use This Skill For

- errors, crashes, and failing tests;
- regressions or behavior that used to work;
- intermittent, timing, lifecycle, state, data, or integration failures;
- broken UI, generated output, commands, or runtime behavior;
- performance complaints that need measurement.

Do not use it for general code review, release assessment, architecture planning, or a new feature with no reported failure.

## Observe Before Explaining

Restate the reported symptom without broadening it. Gather only the context needed to reproduce or directly observe the failure:

- exact input, action sequence, environment, and version;
- expected and actual behavior;
- current source path and runtime boundary;
- error output, logs, state, artifact, screenshot, or measurement;
- known-good state when a regression is claimed.

Run the smallest reproducible check first. If reproduction is unsafe or unavailable, inspect the nearest trustworthy evidence and state the limitation. Do not turn absence of evidence into a confident cause.

List material symptoms before settling on a hypothesis. A cause must explain all observed symptoms, not only the easiest one.

## Trace the Failure

Follow the actual path backward from symptom to the boundary the project controls. Read callers, state transitions, data flow, generated artifacts, and external responses as needed. For layered systems, test the lower layer before blaming the visible one.

Form a specific, disprovable hypothesis:

> The failure occurs because **X** at **location or boundary Y**, supported by **evidence Z**.

Use a discriminating probe that could make the hypothesis false. Instrument ordering, lifecycle, or concurrency when timing matters; inspect rendered output when the defect is visual; measure a baseline when the complaint is performance. Avoid logs or tests that merely confirm the symptom again.

If a probe disproves the current explanation, withdraw it and state what the result changes. A rejected explanation cannot justify another code change. Repeating an unchanged command or restart without a new question is not progress.

## Establish Root Cause

Before changing behavior, be able to state:

- the exact condition that creates the failure;
- why existing guards do not prevent it;
- how it propagates to each observed symptom;
- the narrow check that fails before the repair and passes after it.

If that statement is not yet possible, report an investigation checkpoint: evidence collected, hypotheses ruled out, remaining unknowns, and the next discriminating probe.

## Choose the Repair

Prefer the smallest sufficient and complete change. Small excludes unrelated refactoring and speculative flexibility. Complete covers the real outcome, directly affected contracts and documentation, and sibling sites only when they share the same reproducible root cause, risk shape, remedy, contract behavior, and verification path.

Search for same-shape siblings after confirming the cause. Treat similarity as a lead, not permission to fix unrelated problems. Report different causes or product questions separately.

If the repair requires a new shared abstraction, foundational rewrite, consumer migration, external contract change, irreversible action, or product decision, stop at that boundary and present the evidence and alternatives. Do not disguise it as a bug fix.

## Authorization

Investigation and explanation are read-only by default. Implement only when the request authorizes a fix or modification. Authorized implementation may include focused diagnostic instrumentation and a regression test needed for the repair. Remove temporary instrumentation before completion.

A coherent verified local checkpoint commit is included when the task's hunks can be isolated safely. Push, merge, release, deploy, destructive cleanup, and external replies remain separate authority surfaces unless explicitly included.

## Verify the Claim

Run the narrowest check that exercises the violated behavior, then broader relevant checks when blast radius warrants them. Verification must match the claim:

- compilation does not prove runtime behavior;
- a source diff does not prove generated output;
- a unit test does not prove an installed command path;
- a self-report does not prove an external effect;
- a screenshot does not prove hidden state correctness.

Prefer a durable regression guard that fails on the original behavior. If automation cannot exercise the real boundary credibly, use a repeatable runtime observation or artifact comparison and name the remaining gap instead of manufacturing a hollow test.

## Report

Lead with status and root cause. Include:

- observed failure and reproduction;
- root cause with location or boundary;
- repair made or proposed;
- same-root-cause sibling scope;
- exact verification command and result;
- unresolved uncertainty and completion state.

Distinguish `implementation complete`, `local tests passed`, `local verification blocked`, and any applicable CI state. Never infer one from another.
