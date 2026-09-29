---
name: debugging
description: Diagnose difficult failures with reproducible signals and discriminating probes. Use when a bug has unclear causes, is intermittent or cross-layer, or involves a measured performance regression; skip obvious local fixes.
---

# Debugging

Diagnosis-only requests remain read-only. Use the methods needed to establish cause, rather than imposing fixed phases on every defect.

## Build a Useful Signal

Capture the reported symptom, expected behavior, input or action sequence, environment, and version. Build a repeatable check that detects this specific failure, not merely a crash or unrelated setup error. Depending on the boundary, use a failing test, request or CLI replay, browser interaction, artifact comparison, or small harness.

Run the check before treating it as evidence. Prefer a fast, deterministic signal; for intermittent defects, measure reproduction frequency under controlled conditions rather than calling one successful run a fix. For performance, compare equivalent workloads against a known-good baseline.

If reproduction is unavailable, distinguish direct evidence from inferred causes and identify the access or artifact needed to discriminate them. Continue useful source tracing; absence of a runnable loop does not justify either certainty or an automatic halt.

## Narrow and Discriminate

Reduce inputs, steps, and dependencies while preserving the same failure. Recheck reductions so the harness does not drift into a different bug. Trace the symptom through callers, state transitions, generated output, and external responses to the boundary the project controls.

Consider plausible competing causes when the evidence is ambiguous. For each candidate, state a prediction and choose a probe that can disprove it or distinguish it from alternatives. Inspect ordering and lifecycle for timing failures; use profiles, timings, or query plans for performance. Change one causal variable at a time where practical.

Prefer targeted inspection or tagged temporary instrumentation at discriminating boundaries over logging everything. Keep secrets out of captures. Withdraw disproved explanations. A supported cause must explain the triggering condition and material symptoms, not just correlate with them.

## Confirm the Repair

Repair at the existing source of truth when authorized. Similar sibling sites are leads; include them only when cause, risk, remedy, contract behavior, and verification match within scope.

When practical, turn the minimal reproduction into a regression check that fails on the original defect and passes after repair. Exercise the real caller or lifecycle pattern; a shallow test that misses the triggering chain cannot establish the repair. Use repeatable runtime evidence when no credible automated seam exists.

Recheck the original scenario as well as the minimized one. Remove temporary instrumentation and report the cause, location, discriminating evidence, repair status, and remaining uncertainty.
