---
name: code-review
description: Review concrete code changes against requirements and failure paths. Use when reviewing a diff, branch, PR, or working-tree changes; not for general advice, idea evaluation, or non-code artifacts.
---

# Code Review

Review-only requests remain read-only. Return findings that can change a decision about the actual changes.

## Fix the Review Surface

Establish the checkout, base, and change set before drawing conclusions. Resolve named refs and select the comparison that answers the request: merge-base comparisons for branch changes, explicit endpoints for a commit range, and index or working-tree comparisons for uncommitted work. Do not silently omit staged, unstaged, or relevant untracked changes when they are part of the requested surface.

Identify the requirements from the request, originating issue or spec, existing contracts, and affected consumers. Missing specifications limit what can be claimed about intent; do not invent them. Gather applicable repository standards separately from the requirements.

## Examine Both Dimensions

Check requirement fidelity: missing or partial behavior, incorrect implementation, and behavior outside the requested outcome. Separately check engineering correctness and applicable standards: failure paths, state transitions, validation, authorization, transactions, concurrency, cancellation, compatibility, and recovery where the change makes them relevant. These are prompts for investigation, not a mandatory checklist.

A change can meet its requirements yet be unsafe, or follow every convention yet implement the wrong outcome. Keep the basis of each finding explicit so one dimension does not mask the other. Treat design smells as leads to inspect, not defects merely because a named pattern appears.

Trace affected callers and consumers beyond the changed lines. Establish observable consumer changes and coordination needs before calling something a migration. Similar code is not proof of a missed sibling fix; show matching cause and failure behavior.

## Challenge and Report

Seek counterexamples to the author's explanation and to your own suspected findings. Run focused checks when independent verification is requested or a material uncertainty needs reproduction. Existing tests and agent reports do not substitute for evidence about the actual reviewed version.

Each finding needs a precise source location, concrete trigger or violated invariant, meaningful impact, and correction or decision. Eliminate findings disproved by callers, guards, requirements, or runtime evidence. Separate optional design improvements from required fixes; preferences and hypothetical risks without a failure path are not blockers.

Lead with actionable findings ranked by consequence. Then state the comparison scope, meaningful checks, missing evidence, and uncertainty. If no findings survive inspection, say so without implying broader correctness than the review established.
