---
name: framing-decisions
description: Frames rough ideas into evidence-based direction, architecture, value, automation, and authority decisions. Use when an outcome or approach is still undecided and material tradeoffs must be resolved before implementation.
---

# Framing Decisions

Turn an unsettled idea into a decision that another person can understand and act on. Plan only when doing so resolves a choice that would otherwise block or endanger the work. This skill never implements without separate authorization.

## Use This Skill For

- rough product or engineering ideas;
- architecture or technical direction;
- whether work is valuable, feasible, or worth maintaining;
- choosing deterministic, assisted, proposal-only, delegated, or autonomous control;
- defining effect, authority, contract, migration, or recovery boundaries;
- plans whose alternatives are genuinely close or costly to reverse.

Do not use it for a defined bug, routine execution of an accepted decision, or a simple local repository audit. Route failures to investigating work, read-only evaluation to examining work, and authorized execution to delivering outcomes.

## Establish the Decision

Start with the human or business outcome. State what should become better, for whom, and what observable result would count. Separate that outcome from a requested mechanism: software, AI, an abstraction, a workflow, and a document are possible means rather than goals.

Read enough current evidence to understand the real constraints. Prefer code, schemas, specifications, consumers, runtime behavior, project guidance, and existing decisions over memory or generic practice. Ask only for choices that belong to the user or cannot be settled by evidence.

Identify the smallest meaningful boundary at which the decision changes:

- work surface and affected people;
- read-only, reversible, persistent, external, or irreversible effects;
- who may propose, approve, execute, accept, publish, and recover;
- consumer contracts and coordination needs;
- evidence that can establish completion;
- credible failure and recovery behavior.

Keep this reasoning internal unless it changes risk, authority, cost, verification, or the user's choice.

## Compare Real Alternatives

Explore genuinely different approaches before choosing. Always include the direct, least-powerful sufficient mechanism when it is viable. Do not introduce AI, autonomy, shared infrastructure, or a new abstraction without a concrete advantage over deterministic code, direct tools, or a human workflow.

For each serious option, test:

- whether it achieves the outcome;
- which assumptions carry the decision;
- correctness and verification quality;
- operational and maintenance burden;
- reversibility and failure containment;
- contract, migration, privacy, security, and authority impact.

Do not pad the comparison with cosmetic variants. Recommend one direction and say what evidence would overturn it. Once the direction is accepted, stop promoting rejected options unless new evidence makes the choice unsafe or unworkable.

## Automation and Authority

Choose control mode at the effect boundary, not from a product label. A system may mix direct transactions, AI assistance, proposals, bounded delegation, and ongoing autonomy.

Broader capability does not grant broader permission. If the approach can spend money, modify external state, expose data, change production, or continue without a person present, make the real approval and intervention points explicit. Prefer a smaller mechanism when broader autonomy does not improve the outcome enough to justify weaker predictability or control.

Do not invent a control plane, durable manifest, memory system, reviewer fleet, or orchestration layer for routine bounded work. Add structure only when a real invariant or recurring failure requires it.

## Contract and Structural Stops

If the recommendation changes a relied-on API, event, CLI, configuration, schema, package interface, or published format, show who depends on it, how their observable behavior changes, how adoption would be coordinated, which compatible option remains, and who owns the choice. Do not hide coordination inside an implementation plan.

A new shared abstraction, architectural layer, or foundational rewrite needs evidence of current cost, the smallest non-structural alternative, complexity removed, migration impact, and why the change is not aesthetic preference.

High-impact, irreversible, security-sensitive, or consumer-migration decisions stay with the responsible human. Evidence supports that decision; it does not grant authority.

## Deliver the Frame

Lead with the recommendation. Include only what is needed to settle the material choices:

- outcome and success evidence;
- chosen direction and rationale;
- scope and explicit non-scope;
- assumptions and meaningful unknowns;
- effect, authority, contract, and recovery boundaries;
- implementation outline and verification path when planning is justified.

Do not create an ADR, specification system, permanent memory, or other durable artifact unless the project requires it or the user asks. End at the decision boundary. A selected option or approved plan is not itself authorization to modify files or systems.
