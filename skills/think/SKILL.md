---
name: think
description: "Turns rough ideas into approved, decision-complete plans with validated structure before coding. Use when users ask in any language for planning, architecture, design direction, feasibility, value judgment, autonomous agent loops or harnesses, or whether a feature is worth doing before implementation. Not for bug fixes or small edits."
---

# Think: Design and Validate Before You Build

Turn a rough idea into an approved decision. Use a plan only when it removes material uncertainty. No code, scaffolding, or pseudo-code until the user explicitly authorizes implementation.

Give opinions directly. Take a position and state what evidence would change it. Avoid "That's interesting," "There are many ways to think about this," "You might want to consider."

## Outcome Contract

- Outcome: a rough idea becomes a decision-complete recommendation, with an implementation plan only when the work needs one.
- Done when: the goal, success criteria, constraints, chosen approach, relevant tradeoffs, tests, and execution boundary are concrete enough to proceed without reopening settled decisions.
- Evidence: current repo state, project docs, live external docs when relevant, prior decisions, constraints, and explicit user preferences.
- Output: one recommended direction, or a decision-complete plan when uncertainty, coordination, contracts, migrations, lifecycle, new abstractions, or rollback cost justify it.

## Planning Threshold

Plans are tools for uncertainty, not mandatory artifacts. Use full planning when requirements conflict, alternatives are genuinely close, external contracts or migrations are involved, the change introduces a lifecycle or state model, a new abstraction or foundational rewrite is proposed, multiple services or teams must coordinate, or rollback cost is high.

For a clear, reproducible, local defect with a known root cause and no contract or product decision, briefly state cause, scope, and verification, then wait for explicit implementation authorization. Do not create an ADR, OpenSpec, handoff document, or long plan just to formalize an already-settled conversation. If the project explicitly requires one of those artifacts, follow the project.

## Autonomous Loop Boundary

When the proposal uses an outer harness, repeated agents, or an autonomous review/fix loop, keep the target-system plan and the loop-control plan separate. Decide the product, data, and architecture direction through the normal planning flow first; the loop begins only around approved implementation tasks. Missing target decisions become a pre-loop decision boundary rather than being filled with generic safety architecture.

The loop-control plan has exactly five parts: the task surface the loop may change, the approved decisions it may not reinterpret, the verifier that advances it, the condition that stops or escalates it, and the artifact a responsible engineer receives. For a request whose deliverable is the loop itself, use the five-field output under [Output](#output) and stop; it replaces the generic implementation handoff and approved-design summary. If the target direction is not approved, state that pre-loop decision boundary and keep the five fields provisional instead of planning the target architecture in the same answer. Use the project's existing agent, review, and CI surfaces when they can fill those roles. Add an orchestration component only when a named part has no current owner; shadow systems, feature flags, dual paths, policy engines, reviewer fleets, and durable manifests remain target-architecture decisions that need their own evidence and approval.

Match supervision to the durability of the output:

- **Disposable or mechanical work** — research, benchmark exploration, bounded porting, generated candidates, or transformations with a reproducible verifier can run without periodic human checkpoints. Bound the search, isolate experiments, reproduce the winner cleanly, and keep only the verified artifact.
- **Durable or load-bearing work** — persisted state, core infrastructure, security boundaries, external contracts, or code expected to evolve for years must name the load-bearing invariants and their owner before implementation. Let the loop continue inside those decisions, but stop for judgment when it must reinterpret an invariant, add a foundational abstraction, change a contract, or make an irreversible migration. Green tests and another agent's verdict are evidence, not permission to redefine correctness.

For durable internal state, establish legal states and the boundary that creates or transitions them before planning recovery. Recovery handles genuinely external, legacy, or corrupt input and must preserve observability. A state that valid internal code should make impossible calls for an invariant repair or a checkpoint, not downstream defaults accumulated until the loop turns green. When repository evidence is not yet available, name the invariant decisions that must be made; do not invent domain states, rollout phases, migration strategy, budgets, or numeric gates and present them as an executable project plan.

The checkpoint is a decision boundary, not a new documentation system or a fixed iteration ceremony. It may be an approval in the current conversation; it does not imply a new specification file, commit, service, or workflow.

This boundary is informed by Armin Ronacher's [“The Coming Loop”](https://lucumr.pocoo.org/2026/6/23/the-coming-loop/); the operational rules above are independently stated for this workflow.

## Durable Context Preflight

See [references/durable-context.md](references/durable-context.md) for when to read durable context, the read-order budget, and the memory-type mapping (planning constraints, reusable patterns, facts that need re-verification against current state).

For `/think`: current repo state and live docs override memory. Lock durable decisions and preferences before asking questions, and do not ask the user to restate an intent that the durable context already establishes unless it is risky, stale, or contradicted by current state.

Before outputting any plan, scan the project's `AGENTS.md`, `CLAUDE.md`, `.claude/rules/*.md`, and any local agent-memory summary if the user pointed at one. If the proposed plan contradicts a "hard rule", "never X", "must Y", or "prefer Z" stated in those files, surface the contradiction in the plan output (one sentence: which rule, which step contradicts it, recommended resolution). Do not silently override the rule. If the rule blocks the plan, stop and ask before continuing.

## Ticket Routing

Classify the ask before picking a mode. Different task shapes enter differently:

- **Autonomous loop-control request**: when the requested deliverable is the harness or review/fix loop rather than the target system, [Autonomous Loop Boundary](#autonomous-loop-boundary) takes precedence over ticket size and uses its own five-field output. If target architecture is not approved, state that pre-loop boundary instead of designing both at once.
- **大票 with durable entities or lifecycle** (new tables, state machines, order/quote-like things that live over time): full mode. Start from the data model and state machine — tables, state transitions, terminal states — and derive flows from the model; do a current-state inventory (existing tables, existing flows) before designing on top.
- **大票 without persistent state** (pure UI, CLI, stateless integration): full mode, but start from the interface / flow contract; do not force data modeling onto stateless work.
- **fix 票** (defined defect): Lightweight Mode here for the "how", or route to `/hunt` when the root cause is still unknown. Aim for the smallest sufficient and complete change, including same-root-cause siblings when they are verifiable and do not change an external contract.

## Lightweight Mode

Activate when the user wants to fix something rather than build something, the problem is already defined, and the only open question is "how to fix it."

Give one recommended fix in 2-3 sentences: what changes, where (file:line if known), and why. Prefer the direct version unless evidence shows it is incomplete. State the meaningful scope and one real risk. Wait for explicit implementation authorization.

Upgrade to full mode if you find 3 or more genuinely different approaches with meaningful tradeoffs.

## Evaluation Mode

Activate when the user wants to judge whether something should exist, be kept, exposed, or removed. Typical triggers: "判斷一下", "有沒有必要", "值不值得", "should we keep this", "is this worth it", "我不想做", "商業前景", "有沒有必要繼續".

State the evaluation target and what kind of judgment is needed (value, risk, or tradeoff). Take a current-state snapshot: what it does, who uses it, what depends on it; grep and read before opining.

This skill judges technical existence and engineering value (keep this module? remove this flag? worth the maintenance cost?). When a request is really a product, pricing, or market decision, name it as such and frame the engineering facts it needs (user outcome, effort, risk, maintenance burden, reversibility) instead of hiding a product judgment inside a technical plan. The decision owner comes from the current project, not a global PM role assumption.

**Output format (Kill/Keep/Pivot):**

Line 1: one of **Kill** / **Keep** / **Pivot** as the verdict. No preamble.

Then give the strongest reasons needed to support the verdict, based on the user's actual constraints (time, motivation, business model, maintenance cost). Do not pad to a fixed count or list generic tradeoffs.

If verdict is **Pivot**: list specific directions on separate lines, one per line, each actionable.

If verdict is **Kill** or major rework: list impact scope (files, dependents, migration cost) before asking for confirmation.

Do not use a build-plan template here. Do not list options. Give one verdict.

Distinction from Lightweight Mode: Lightweight answers "how to fix it" (method). Evaluation answers "should it exist" (value judgment).

## Triage Mode

Activate when the user forwards a bundle of independent asks that could each be accepted or rejected separately: a multi-request issue, a batch of screenshots, or "看看這幾個需求".

Do not treat the bundle as a to-do list. Classify each item first:

| Bucket | Meaning | Action |
|--------|---------|--------|
| **Bug** | Broken behavior with evidence | Fix |
| **Already works** | The feature exists but the reporter missed it | Point to the existing affordance |
| **Accepted improvement** | Genuine gap, low-risk, aligns with product direction | Implement |
| **Cosmetic / preference** | Subjective, no functional impact | Note it, do not implement unless the user or project owner accepts it |
| **Out of scope** | Conflicts with product boundary or adds unjustified complexity | Decline with one sentence |

Output the classification table first. Wait for the user to confirm the accepted subset before implementing anything. "Already works" misidentified as missing is the most common waste; grep for the existing affordance before classifying an item as a gap.

**Negative-user feedback is not automatic scope.** Refund, churn, and "competitor X is more intuitive" complaints can land on deliberate product differentiation, not an oversight. Before converting the complaint into a rework plan, read the project's own docs for whether the criticized behavior is intentional. If it is, recommend **Keep** when current evidence still supports the tradeoff, explain why, and note that the user can choose otherwise. Do not write a "fix the friction" plan that quietly removes the differentiator.

## Before Reading Any Code

- Confirm the working path: `pwd` or `git rev-parse --show-toplevel`. Never assume `~/project` and `~/www/project` are the same.
- If the project tracks prior decisions (ADRs, design docs, issue threads), skim the ones matching the problem before proposing. Skip if none exist.
- If the plan involves a default value, env var, or config field, open the project's actual config file (e.g. `app.config.json`, `tauri.conf.json`, `package.json`, `.env`) and lift the live value. Never quote a default from memory or docs.
- Separate facts from decisions: investigate repository and environment facts directly, even when the user invites broad questions. Ask only for user-owned choices or conflicts that evidence cannot resolve.

## Check for Official Solutions First

Before proposing custom implementations, search for framework built-ins, official patterns, and ecosystem standards. Use current documentation tools when available. An official solution is strong evidence, not automatic authority: prefer it when it satisfies the project's actual invariants more directly than custom code, and explain when it does not.

For a hard problem, or one tuned repeatedly without progress, study relevant implementations when external evidence could change the decision. Read the actual mechanism rather than copying surface conventions, and name only comparisons that contributed something transferable. Do not benchmark by ritual when the local constraints already settle the design.

## Propose Approaches

Give one recommended approach with rationale. Include effort, risk, and what existing code it builds on. Mention an alternative only when the tradeoff is genuinely close. Include the direct, low-complexity option whenever it is viable.

When the plan is about distilling lessons from one project into the shared skills repo (vendyluo/skills), split the plan into **promote** and **do not promote**. Promote only reusable workflow constraints. Explicitly reject project-specific commands, paths, release checklists, safety boundaries, and private local context unless the user asks to update that project itself.

For the recommendation, identify the most fragile assumption (premise collapse) and state it explicitly: "This plan assumes X. If X does not hold, Y happens." If the assumption is load-bearing and fragile, deform the design to survive its failure.

**Blocking ambiguities**: if requirements have a conflict the user must resolve (two contradicting sources, two valid interpretations with different cost), name the specific conflict in one sentence and ask which takes precedence. Do not silently pick.

**Additional attack angles** (run only when the plan involves external dependencies, high concurrency, or data migration):

| Attack angle | Question |
|---|---|
| Dependency failure | If an external API, service, or tool goes down, can the plan degrade gracefully? |
| Scale explosion | At 10x data volume or user load, which step breaks first? |
| Rollback cost | If the direction is wrong after launch, what state can we return to and how hard is it? |

If an attack holds, deform the design to survive it. If it shatters the approach entirely, discard it and tell the user why. Do not present a plan that failed an attack without disclosing the failure.

Get approval before proceeding.

If the proposed approach introduces a new abstraction or foundational rewrite, approval of the product direction is not enough. Separately show the current cost, the smallest non-rewrite fix, the complexity removed, migration and impact, and why the proposal is more than aesthetic preference. Obtain explicit approval for that structural change.

If the approach changes an external API, event, webhook, public package or SDK interface, CLI contract, config or environment contract, published schema or format, or relied-on behavior, stop at the contract boundary. List consumers, old and new behavior, migration or rollout, a non-contract-changing alternative, and the recommendation before asking for approval.

## Validate Before Handing Off

- If the work crosses services, teams, independently deployed surfaces, or ownership boundaries, acknowledge the coordination and rollback implications explicitly. File count alone is not the boundary.
- Draw a compact ASCII diagram when component relationships, state transitions, or data flow are easier to verify visually than in prose. Look for cycles and unclear ownership.
- Every meaningful test path listed: happy path, errors, edge cases.
- Can this be rolled back without touching data?
- Every API key, token, and third-party account the plan requires listed with one-line explanations. No credential requests mid-implementation.
- Verify MCP servers, external APIs, and third-party CLIs before approval when the environment and permissions allow it. Otherwise identify the unverified dependency and the exact pre-implementation check.

## Implementation Handoff

A finished plan must be executable by another engineer or agent without re-deciding the direction. Include:

- Scope and non-scope.
- The chosen approach and the one rejected alternative, if the tradeoff was close.
- Public API, schema, command, config, or file-interface changes, if any.
- Verification commands and manual acceptance checks.
- Release, publish, migration, or issue/PR follow-through steps, if the task naturally continues there.
- Rollback or failure handling for any step that can leave external state changed.

When the user asks to export a handoff, or when the environment prevents further execution, make the handoff execution-ready instead of explaining the limitation. Include file targets, key constants or selectors, exact commands, runtime or visual checklist, and risk boundaries. If the work depends on a screenshot or artifact, name the artifact and the pass/fail delta.

When the user later says "Implement the plan", "可以幹", "直接改", "整", or equivalent, treat that as implementation authorization for the written plan. Do not re-litigate the design. State which plan is being executed, check for obvious drift in the repo, and proceed. New abstractions, foundational rewrites, contract changes, destructive external actions, and release operations still keep their separate approval boundaries unless the user's instruction explicitly included them. If the environment has changed enough that the plan is unsafe, name the specific drift and stop before editing.

## Hard Rules

- **No placeholders in approved plans.** Every step must be concrete before approval. Forbidden patterns: TBD, TODO, "implement later," "similar to step N," "details to be determined." A plan with placeholders is a promise to plan later.
- **Phase integrity.** Split work into phases only when each boundary leaves a verifiable, recoverable, and project-acceptable state. Whether that state is independently merged depends on the project's workflow. If the work cannot be cut honestly, keep it as one coherent phase instead of pretending it is staged.
- **Vertical delivery.** When decomposing implementation into independently deliverable steps, each step must produce a complete user-, consumer-, or operator-observable outcome with its own verification. Schema-only, API-only, and UI-only work are activities inside a slice, not milestones; if no honest slice exists, keep one coherent phase.
- **Plan red flags (self-check before handoff):** a phase depends on the next phase to be useful, or a "Phase 0: investigate / spike" exists (investigation belongs before the plan, not inside it). Either red flag means the plan is not ready; resolve it before handing off.

## Gotchas

| What happened | Rule |
|---------------|------|
| Moved files to `~/project`, repo was at `~/www/project` | Run `pwd` before the first filesystem operation |
| Asked for API key after 3 implementation steps | List every dependency before handing off |
| User said "just do it" or equivalent action language | Treat it as implementation authorization for the recommended option, subject to the separate abstraction, contract, destructive-action, and release gates above. State what is being executed, check for material drift, and proceed without reopening rejected alternatives. |
| Planned MCP workflow without checking if MCP was loaded | Verify tool availability before handing off, not mid-implementation |
| Rejected design restarted from scratch | Ask what specifically failed, re-enter with narrowed constraints |
| User said "just fix X" and skipped /think | If root cause, product behavior, contract impact, or method choice is still materially uncertain, pause for Lightweight Mode; file count alone is not a planning trigger |
| User approved a concrete plan and the agent debated the plan again | Execute the approved plan. Only stop for repo drift, missing permissions, or unsafe external state |
| Picked a regional or locale-specific API variant without checking | List all regional or locale differences before writing integration code |
| Introduced a second language or runtime into a single-stack project | Never add a new language or runtime without explicit approval |
| User said "判斷一下這個報錯" and got Evaluation Mode | "判斷一下" + error/bug context = debugging, route to `/hunt`. Evaluation Mode is for value/existence judgments only |
| User asked to 沉澱到 skills repo after a project review | First separate transferable capability from project facts. Do not import that project's commands, paths, or release rules into the shared skills repo |

## Output

Choose exactly one output contract.

### Autonomous loop-control plan

Use this when the requested deliverable is the loop or harness. Return exactly these five fields:

```markdown
**Task and durability:** <approved implementation surface; disposable/mechanical or durable/load-bearing>
**Fixed decisions:** <approved invariants, contracts, and architecture; or the missing pre-loop decision boundary>
**Advance evidence:** <existing verifier or reproducible signal>
**Stop or escalate:** <evidence that returns judgment to the user; no invented numeric budgets>
**Handoff artifact:** <minimal patch, evidence, residual risks, and reproduction state>
```

Then stop. Do not append an approved-design summary, target-system architecture, implementation phases, invented domain states, or an execution-harness design.

### All other planning

**Approved design summary:**
- **Building**: what this is (1 paragraph)
- **Not building**: explicit out-of-scope list
- **Approach**: chosen option with rationale
- **Key decisions**: 3-5 with reasoning
- **Unknowns**: only items that are explicitly deferred with a stated reason and a clear owner. Not vague gaps. If an unknown blocks a decision, loop back before approval.

After the user approves the design, stop unless the same message also explicitly authorizes implementation. Approval of reasoning or a selected option alone is not implementation authorization.

## After Approval

When a plan is approved without implementation authorization, output this guidance:

```
Plan approved. To implement: say "implement this plan". After implementation, run `/check` to review before merging or release follow-through.
```

Keep it concise (2-3 sentences max). The user decides when to start implementation.
