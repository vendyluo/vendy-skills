# Prototype State Model Format

The prototype loads a trusted Elixir file whose final expression is one map.

## Top-level fields

| Field | Meaning |
|---|---|
| `name` | Human-readable string model name. |
| `axes` | Map of axis names to finite, non-empty value lists. |
| `initial` | One complete initial state containing every axis. |
| `writers` | Map of each axis to the owners allowed to change it. |
| `transitions` | Candidate implementation or design transitions. |
| `invariants` | Predicates that must hold in every reachable state. |
| `transition_rules` | Rules about a transition itself, such as axes it must preserve. |
| `terminal_when` | List of partial states that are allowed to have no outgoing transition. |
| `check_deadlocks` | Boolean. When true, a non-terminal reachable deadlock is a violation. |
| `questions` | Explicit list of unresolved human-decision strings. Any entry makes the result `MODEL INCOMPLETE`. |

All top-level fields are required. Axis names, transition names, triggers, and owners are atoms. Invariant and transition-rule names are strings or atoms.

## Transition fields

Every transition contains:

| Field | Meaning |
|---|---|
| `name` | Unique transition name. |
| `trigger` | Event, command, timer, or recovery trigger. |
| `owner` | Authority that performs the transition. |
| `when` | Partial state matched by equality. An empty map means any state. |
| `set` | Axis values written by the transition. |
| `preserve` | Every axis not in `set`. `set` and `preserve` must partition all axes. |

Explicitly classifying all axes is intentional: it prevents an AI or reviewer from silently treating a forgotten field as preserved.

## State expressions

Invariants use these finite expression forms:

- `true` / `false`
- `{:eq, axis, value}`
- `{:neq, axis, value}`
- `{:in, axis, [values]}`
- `{:not, expression}`
- `{:and, [expressions]}`
- `{:or, [expressions]}`
- `{:implies, premise, consequence}`

An invariant is a map with `name` and `check`.

## Transition rules

A transition rule contains:

- `name`
- exactly one of `trigger` or `transition`, referencing at least one declared transition
- `preserve`, listing axes whose before/after values must be equal

The verifier checks transition ownership and transition rules only when that transition is reachable. This produces a shortest executable counterexample rather than only a structural warning. Equal-length traces are resolved by transition declaration order; axis-level ties use sorted axis names.

## Results and exit status

| Result | Exit | Meaning |
|---|---:|---|
| `PASS` | 0 | Exhaustive exploration of all reachable states completed within the bound and satisfies the written finite contract. |
| `VIOLATION` | 1 | A shortest counterexample was found. |
| `MODEL INCOMPLETE` | 2 | The schema is invalid, exploration exceeded its bound, or human questions remain. |

`PASS` is scoped to the model. It does not prove that the model captures the correct product semantics or that production code implements it.

## Verification Semantics and Limits

- A concrete `VIOLATION` does not require complete exploration; the state bound prevents a partial `PASS`, not a valid counterexample.
- Writer ownership applies only when an axis value actually changes. It does not prove authorization for no-op writes or database access.
- A deadlock means no transition's `when` clause matches. The verifier cannot know whether an external event will arrive, and a matching self-loop prevents deadlock classification.
- `terminal_when` only exempts deadlock checking. It does not make a state absorbing if transitions still match.
- The prototype proves safety properties and optional model-level deadlock freedom, not liveness, fairness, eventual recovery, starvation, or livelock freedom.
- Transitions are atomic. Concurrency and event ordering are covered only when each relevant interleaving is represented explicitly.
- Unreachable transitions produce warnings; their writer and transition rules are not exercised.
- The deterministic verifier cannot discover an omitted product question. The skill critique is responsible for surfacing it in `questions`.
