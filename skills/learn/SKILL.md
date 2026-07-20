---
name: learn
description: "Runs an evidence-first research workflow that turns unfamiliar domains, source bundles, or collected material into a usable mental model or publish-ready output. Use when users ask in any language to research, study, deep-dive, compile sources, synthesize unfamiliar material, or turn a source bundle into a coherent reference. Not for quick lookups or single-file reads."
when_to_use: "學習一下, 深入研究, 研究一下, 整理成文章, 把這批材料整理, 一站式參考, 一篇就夠, 整理成長文, research, deep dive, help me understand, compile sources, unfamiliar domain"
dispatch_intent: "Deep research, unfamiliar domain, compile sources into output"
---

# Learn: From Evidence to Understanding

Support the user's thinking; do not replace it.

## Outcome Contract

- Outcome: unfamiliar material becomes a reliable mental model, reference, article, or notes set the user can use.
- Done when: the important questions are answered to the requested depth, material claims have fitting evidence, contradictions and limits stay visible, and the result is useful for the user's next decision or deliverable.
- Evidence: source URLs or files, fetched content, notes from digestion, outline decisions, and self-review against the requested output.
- Output: research notes, outline, publish-ready draft, or canonical reference, matching the chosen mode.

**Boundary**: single URL that only needs fetching belongs in `/read`. A single URL that needs summary or analysis can use `/read` as the fetch step, but the final answer should satisfy the user's requested summary or analysis. `/learn` is for multi-source research that produces a new structured output.

## Choose the Smallest Useful Mode

| Mode | Use when | Typical output |
|------|----------|----------------|
| **Quick Reference** | The user needs a working model or decision aid, not exhaustive coverage | Concise synthesis with key evidence and unknowns |
| **Deep Research** | The domain is unfamiliar, disputed, broad, or consequential | Source-backed analysis and a reusable mental model |
| **Write to Learn** | The user supplied material and wants understanding through structured writing | Outline, notes, or draft grounded in that material |
| **Canonical Reference** | The user wants a durable, broad reference for a defined audience | Comprehensive article with examples, limits, and further reading |

Infer the mode from the request. Ask only when a different depth or output would materially change the work. A named mode sets depth, not a mandatory amount of ceremony.

## Phase 0: Frame the Question

Before collecting, identify:

- the actual question or decision the research should support;
- the intended audience and output;
- relevant time range, jurisdiction, system version, or project boundary;
- what is already supplied or known;
- what would make the answer materially wrong.

Do not turn every research request into a questionnaire. Use the user's wording and available context first; ask a narrow question only if the missing answer changes scope, evidence, or risk.

## Phase 1: Collect

Collect evidence that can answer or test the framed questions. Prefer source types by what they can establish:

- primary records, official documentation, source code, specifications, datasets, or first-party statements for what a system says or does;
- independent analysis, replication, critique, or reporting for context and contested interpretations;
- current runtime output, artifacts, or direct observation for claims about present behavior;
- high-quality secondary explanations for orientation and synthesis when primary material is incomplete or inaccessible.

Primary does not mean infallible, and secondary does not mean disposable. Evidence quality, independence, recency, incentives, and fit to the claim matter more than labels.

Use `/read` when an installed URL/PDF reading workflow improves extraction or traceability; otherwise use the environment's appropriate fetch tools. Record a source locally only when the requested deliverable or future verification benefits from it. Do not create a research archive merely to prove that research happened.

Search in focused passes. Stop when additional sources no longer change the important claims, reveal meaningful disagreement, or reduce a consequential uncertainty. Source count is a budget signal, not a quality gate.

## Phase 2: Digest

Read enough of each source to understand the relevant claim in context. For material claims, track:

- what the source actually supports;
- whether it is direct evidence, interpretation, or inference;
- its date, scope, assumptions, and likely incentives;
- independent support or disagreement;
- confidence and unresolved questions.

Use a claim/evidence matrix or source register when the volume, stakes, or disagreement makes traceability useful. Do not force one for a small, clear bundle.

### Conversation Or Review Distillation

When the input is a recent conversation, project review, scorecard, or diagnostic report, treat it as raw material:

- Read only conversations, session history, or memory that the user has put in scope and the runtime permits. Do not write conclusions into permanent memory without explicit approval.
- Prefer current artifacts and direct evidence over remembered summaries. Use summaries to navigate, then verify disputed or consequential details against the source when possible.
- When editing durable guidance, distinguish transferable judgment from project facts. Promote a pattern only when the evidence shows it should survive outside the original context.
- Extract repeated workflow failures, invariants, and verifier surfaces.
- Drop dated line numbers, current-score framing, private paths, one-machine setup, and repo-specific commands unless the output is explicitly for that same repo.
- Map each durable lesson to its target layer: project docs, shared rules, skill references, or deterministic scripts.
- Prefer references or existing skill sections for adaptive workflow guidance; use scripts only for deterministic checks that can fail reliably without project-specific context.
- Keep evidence snippets only as notes for yourself; do not paste raw conversation history into the final artifact.

## Phase 3: Synthesize Before Drafting

Build the mental model before polishing prose:

- answer the central question in plain language;
- connect causes, constraints, tradeoffs, and consequences;
- keep factual disagreement and uncertainty visible;
- separate sourced fact, reasoned inference, and recommendation;
- note where a source describes a different version, jurisdiction, audience, or operating context.

If evidence overturns the working thesis, revise the thesis. Do not defend the initial framing because it came from the user, an authority, a framework, or an earlier agent conclusion.

## Phase 4: Structure and Draft

Choose the smallest structure that teaches the topic or supports the decision. For substantial output, map major sections to the evidence they rely on. A section may contain clearly labeled reasoning or recommendations without a citation; factual premises still need support.

Draft directly when the user requested a draft. If a section is difficult because the model is weak or the evidence conflicts, return to collection or synthesis for that section rather than filling the gap with confident prose.

For a canonical reference, aim for broad practical coverage within an explicit boundary, not the impossible promise that readers will never need another source. Include worked examples, common failure modes, limits, and a short further-reading path when they improve usefulness.

## Phase 5: Refine

Refine against the requested outcome:

- Remove redundant and verbose passages without changing meaning or voice
- Repair places where the argument does not flow
- Explain concepts before relying on them
- Remove interesting material that does not help the question
- Preserve uncertainty instead of smoothing it into certainty

Use `/write` when the deliverable needs dedicated prose polishing. Otherwise scan directly for filler, formulaic contrast, dramatic fragmentation, repetition, and unsupported confidence.

## Phase 6: Verify and Deliver

Before claiming completion:

- verify important factual claims against their cited sources;
- check quotations, numbers, dates, versions, and links that the answer depends on;
- distinguish what is known, inferred, disputed, or still unknown;
- confirm the conclusion answers the original question and does not exceed the evidence;
- disclose access gaps, unavailable sources, stale data, or verification that could not be performed.

Lead the delivery with the answer or model the user needs. Add method, source notes, and caveats only where they help review or reuse. Creating or approving publication-ready text does not authorize uploading, posting, or distributing it.

## Hard Rules

- **Evidence outranks the initial thesis.** Revise the answer when better evidence changes it.
- **Contradictions stay visible.** When two sources contradict on a factual claim, note both positions and the evidence each gives; never silently pick one.
- **No manufactured certainty.** Missing access, weak corroboration, or domain limits must be stated, not hidden behind source volume.
- **No ritual source counts.** Gather enough fitting evidence for the claim and risk; do not pad the bibliography to satisfy a number.
- **Stop at publish confirmation.** After the user confirms the article is ready, do not upload, post, distribute, or perform any publish action unless explicitly asked.

## Gotchas

| What happened | Rule |
|---------------|------|
| Collected many explainers but no evidence that can test the central claim | Match source type to claim; add primary records, artifacts, data, or independent verification where they matter. |
| Treated an official statement or convincing explainer as ground truth | Evaluate what it directly supports, its incentives and scope, and whether independent evidence changes the picture. |
| Produced source-by-source summaries instead of a usable model | Organize around the user's questions, not the order in which sources were fetched. |
| Added fixed source, query, or pass counts to make the process look rigorous | Scale effort to uncertainty and consequence; rigor comes from fit, traceability, and verification. |
| AI offered to upload the article to a blog or social platform after the user said it was ready | Stop at confirmation. Publishing is the user's action, not yours. |
| Turned a project review into a shared rule without filtering | Promote only transferable judgment. Leave project-specific commands, paths, domain behavior, and safety constraints in that project. |
