---
name: investigating-failures
description: Diagnoses a reported failure and verifies an authorized repair. Use when errors, regressions, failing tests, or broken behavior are reported.
---

# Investigating Failures

Establish why the reported behavior fails, then repair it when that is the intended request. An explanation-only request stays read-only; a request to fix already authorizes diagnosis, the local repair, and relevant verification.

## Find a discriminating observation

Separate the observed symptom from the proposed cause. Reproduce the smallest failing case when safe; otherwise use the closest trustworthy evidence and state the limitation. Inspect the owning path, relevant callers, inputs, environment, and known-good behavior as needed.

Form a falsifiable explanation that accounts for the material symptoms. Choose a probe whose result differs between competing explanations. Follow ordering and lifecycle when timing matters, inspect the render for visual defects, and measure performance complaints. Do not repeat unchanged commands or restarts without a reason.

If evidence contradicts the hypothesis, revise it. If the cause remains uncertain, continue with the next useful safe probe; a progress checkpoint is not a reason to stop unless blocked or asked to pause.

## Repair the cause

Before changing behavior, understand the failing condition, how it reaches the symptom, and what observation would distinguish a repair from a symptom patch. Scale the explanation to the defect; an obvious local error does not require a formal investigation report.

Use the smallest complete repair and preserve unrelated behavior and work. Check sibling sites only when the confirmed cause suggests the same defect. Similarity alone does not authorize broader cleanup.

Carry the user's existing fix authorization through the repair and verification. Ask only for uncovered consequential product or contract decisions, consumer migrations, destructive actions, or external effects. Do not stop merely because diagnosis is complete.

## Verify and finish

Prefer a regression check that fails on the original behavior and passes after the repair, with expectations independent of the implementation. Broaden testing according to the affected consumers and required project checks. When automation cannot credibly exercise the boundary, use repeatable runtime evidence and name the gap.

Remove temporary diagnostic artifacts. Stop once the reported failure is resolved and relevant checks are complete, or a concrete blocker needs user action. Do not add unrelated hardening or an automatic commit requirement.

Report the cause, repair or proposed remedy, verification result, and material uncertainty. Keep local success distinct from CI, deployment, and external state. Reconcile unknown external effects before retrying them.
