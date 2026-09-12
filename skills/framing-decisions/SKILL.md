---
name: framing-decisions
description: Compares approaches for an unresolved consequential choice. Use when a product or architecture decision must be settled before implementation.
---

# Framing Decisions

Resolve the choice that blocks the outcome. Routine reversible implementation details do not need a separate decision workflow.

## Ground the choice

Identify the human outcome, the material constraint, and what evidence would distinguish viable approaches. Read the relevant source, consumers, specifications, or runtime evidence; do not require a full repository survey.

Separate the requested outcome from a proposed mechanism. Include a direct, least-powerful sufficient approach when viable. Compare only genuinely different options on the tradeoffs that matter: user value, correctness, maintenance, reversibility, and effects on data, security, or consumers.

Recommend one approach and state material assumptions or evidence that would reverse it. Keep routine reasoning internal; explain consequential tradeoffs to the user.

## Respect the decision boundary

For a relied-on contract change, identify affected consumers, observable differences, coordination needs, and a compatible alternative. A new shared layer or foundational rewrite needs a concrete benefit beyond consistency or aesthetics.

Authority follows the user's request, not this skill's phase. If the user asked only for discussion or a plan, deliver that without editing. If the user already authorized implementation, resolve ordinary reversible choices and continue; do not ask again merely because planning is complete.

Ask before proceeding with a consequential product choice, consumer migration, or external effect not covered by that authorization. Evidence and technical capability do not grant permission. State the exact remaining decision rather than requesting blanket approval.

## Finish the decision

Provide the recommendation, rationale, relevant alternatives, and necessary verification or rollout constraints. Do not create an ADR, durable plan, or orchestration system unless requested or required by the project.

Once the choice is settled, stop comparing alternatives unless new evidence invalidates it. Continue authorized delivery, or end with the requested decision artifact when the task is discussion-only.
