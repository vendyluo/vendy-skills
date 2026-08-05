---
name: verifying-state-models
description: Reviews stateful designs for mixed dimensions, ownership, durability, event-ordering, and missing invariants, then runs a deterministic finite-state verifier. Use when designing or reviewing backend workflows, frontend async flows, lifecycle systems, or AI-generated state transitions.
compatibility: Requires Elixir 1.19 or newer to run the bundled prototype verifier.
---

# Verifying State Models

Turn prose or code-level state handling into an explicit state contract, challenge the model, then use the bundled deterministic verifier. Never treat an LLM judgment as verification.

## Workflow

1. Identify independent axes before listing transitions. Separate at least lifecycle, operation, authority, connectivity, control permission, persistence, and UI observation when they are distinct in the domain.
2. For every transition, name its trigger and owner, define its guard and effects, and classify every other axis as preserved. An omitted axis is an unanswered design question, not an implicit success.
3. Ask who may create and lift locks, pauses, terminal states, and authority loss. Distinguish durable intent from transient runtime state.
4. Record unresolved product decisions in `questions`. Do not choose answers silently. The verifier returns `MODEL INCOMPLETE` while any question remains.
5. Write the contract using [the prototype format](reference/contract-format.md).
6. Resolve this skill's installed directory, then run:

   ```sh
   elixir <skill-directory>/scripts/verify.exs <contract.exs>
   ```

7. Interpret results strictly:
   - `PASS`: exhaustive exploration of all reachable states completed within the bound and satisfies the written rules; it does not prove the business rules are correct.
   - `VIOLATION`: inspect the shortest counterexample trace and repair the model or implementation.
   - `MODEL INCOMPLETE`: resolve the listed structural errors or human decisions before claiming verification.
8. Convert a confirmed counterexample into a regression scenario at the system's real authority boundary.

## Mandatory Model Critique

Before running the tool, ask:

- Do enum values describe different dimensions, such as `loading`, `offline`, and `modal_open`?
- Does more than one subsystem write the same axis? If so, what is the priority rule?
- Which transitions can lift a state they did not create?
- Which fields must remain unchanged across each transition?
- Are restart, reconnect, retry, cancellation, and late delivery modeled?
- Do two events produce different outcomes when their order is reversed? Is that ordering contractual?
- Can a projection claim progress while an authority or lifecycle barrier suppresses real work?
- Are durable and transient reasons explicitly distinguished?

The deterministic tool cannot discover missing business truth. Surface uncertainty as `questions` rather than inventing an invariant.

## Prototype Boundaries

- Trusted local `.exs` contracts only; loading a contract evaluates Elixir code.
- Equality guards and finite enumerated axes only.
- `PASS` requires exhaustive exploration within the state bound; exceeding it is `MODEL INCOMPLETE`. A concrete violation found before the bound remains valid.
- Safety and optional model-level deadlock checks only. No liveness, fairness, eventuality, starvation, or livelock proof.
- Transitions are atomic. Races and event ordering are explored only when the contract models each interleaving explicitly.
- Ownership applies to actual value changes, not no-op write attempts. Unreachable transitions are warnings and their runtime rules are not exercised.
- No production-code parsing, runtime execution, code generation, or automatic repair.
- No claim that `PASS` proves the implementation matches the model.

Use [the Fulu fixed model](examples/fulu-fixed.exs) as the first passing example and [the pre-fix model](examples/fulu-buggy.exs) as a known counterexample.
