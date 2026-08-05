defmodule StateModel.Verifier do
  @moduledoc false

  @max_states 100_000
  @transition_keys [:name, :trigger, :owner, :when, :set, :preserve]

  def verify(contract, options \\ [])

  def verify(contract, options) when is_map(contract) do
    errors = validation_errors(contract)
    questions = valid_questions(contract)

    cond do
      errors != [] ->
        {:incomplete, %{errors: errors, questions: questions}}

      questions != [] ->
        {:incomplete, %{errors: [], questions: questions}}

      true ->
        explore(contract, Keyword.get(options, :max_states, @max_states))
    end
  end

  def verify(_contract, _options) do
    {:incomplete, %{errors: ["contract must be a map"], questions: []}}
  end

  def format({:pass, report}) do
    lines = [
      "PASS #{report.name}",
      "reachable states: #{report.reachable_states}",
      "exercised transitions: #{report.exercised_transitions}/#{report.total_transitions}"
    ]

    Enum.join(lines ++ Enum.map(report.warnings, &"warning: #{&1}"), "\n")
  end

  def format({:violation, report}) do
    trace =
      case report.trace do
        [] -> ["  (initial state)"]
        entries -> Enum.map(entries, &format_trace_entry/1)
      end

    Enum.join(
      [
        "VIOLATION #{report.name}",
        "rule: #{report.rule}",
        "detail: #{report.detail}",
        "counterexample:"
      ] ++ trace,
      "\n"
    )
  end

  def format({:incomplete, report}) do
    details =
      Enum.map(report.errors, &"error: #{&1}") ++
        Enum.map(report.questions, &"question: #{&1}")

    Enum.join(["MODEL INCOMPLETE"] ++ details, "\n")
  end

  defp explore(contract, max_states) do
    initial = contract.initial

    case reachable_state_violation(contract, initial) do
      nil ->
        queue = :queue.from_list([{initial, []}])
        visit(contract, queue, MapSet.new([initial]), MapSet.new(), max_states)

      violation ->
        violation_result(contract, violation, [])
    end
  end

  defp visit(contract, queue, visited, exercised, max_states) do
    case :queue.out(queue) do
      {:empty, _queue} ->
        pass_result(contract, visited, exercised)

      {{:value, {state, trace}}, rest} ->
        transitions = enabled_transitions(contract, state)

        case advance(
               contract,
               transitions,
               state,
               trace,
               rest,
               visited,
               exercised,
               max_states
             ) do
          {:violation, _report} = violation ->
            violation

          {:incomplete, _report} = incomplete ->
            incomplete

          {:continue, queue, visited, exercised} ->
            visit(contract, queue, visited, exercised, max_states)
        end
    end
  end

  defp advance(contract, transitions, state, trace, queue, visited, exercised, max_states) do
    Enum.reduce_while(
      transitions,
      {:continue, queue, visited, exercised},
      fn transition, {:continue, queue, visited, exercised} ->
        next_state = Map.merge(state, transition.set)
        entry = trace_entry(transition, state, next_state)
        next_trace = trace ++ [entry]
        exercised = MapSet.put(exercised, transition.name)

        violation =
          transition_violation(contract, transition, state, next_state) ||
            reachable_state_violation(contract, next_state)

        cond do
          violation ->
            {:halt, violation_result(contract, violation, next_trace)}

          MapSet.member?(visited, next_state) ->
            {:cont, {:continue, queue, visited, exercised}}

          MapSet.size(visited) >= max_states ->
            {:halt, incomplete_result("exploration exceeded #{max_states} reachable states")}

          true ->
            {:cont,
             {:continue, :queue.in({next_state, next_trace}, queue),
              MapSet.put(visited, next_state), exercised}}
        end
      end
    )
  end

  defp transition_violation(contract, transition, before, next_state) do
    changed_axes =
      transition.set
      |> Map.keys()
      |> Enum.sort()
      |> Enum.filter(&(Map.fetch!(before, &1) != Map.fetch!(next_state, &1)))

    ownership_violation =
      Enum.find_value(changed_axes, fn axis ->
        allowed = Map.fetch!(contract.writers, axis)

        if transition.owner in allowed do
          nil
        else
          %{
            rule: "writer ownership",
            detail:
              "#{inspect(transition.owner)} changed #{inspect(axis)}; allowed writers are #{inspect(allowed)}"
          }
        end
      end)

    ownership_violation || transition_rule_violation(contract, transition, before, next_state)
  end

  defp transition_rule_violation(contract, transition, before, next_state) do
    contract
    |> Map.get(:transition_rules, [])
    |> Enum.filter(&rule_matches?(&1, transition))
    |> Enum.find_value(fn rule ->
      rule.preserve
      |> Enum.sort()
      |> Enum.find_value(fn axis ->
        if Map.fetch!(before, axis) == Map.fetch!(next_state, axis) do
          nil
        else
          %{
            rule: to_string(rule.name),
            detail:
              "#{inspect(transition.name)} changed preserved axis #{inspect(axis)} from " <>
                "#{inspect(Map.fetch!(before, axis))} to #{inspect(Map.fetch!(next_state, axis))}"
          }
        end
      end)
    end)
  end

  defp state_violation(contract, state) do
    Enum.find_value(Map.get(contract, :invariants, []), fn invariant ->
      if evaluate(invariant.check, state) do
        nil
      else
        %{
          rule: to_string(invariant.name),
          detail: "invariant failed in state #{format_state(state)}"
        }
      end
    end)
  end

  defp reachable_state_violation(contract, state) do
    state_violation(contract, state) || deadlock_violation(contract, state)
  end

  defp deadlock_violation(contract, state) do
    if contract.check_deadlocks and enabled_transitions(contract, state) == [] and
         not terminal?(contract, state) do
      %{rule: "no reachable deadlock", detail: "non-terminal state has no transition"}
    end
  end

  defp enabled_transitions(contract, state) do
    Enum.filter(contract.transitions, &matches?(state, &1.when))
  end

  defp pass_result(contract, visited, exercised) do
    all_transition_names = MapSet.new(Enum.map(contract.transitions, & &1.name))
    unexercised = MapSet.difference(all_transition_names, exercised) |> Enum.sort()

    warnings =
      case unexercised do
        [] -> []
        names -> ["unreachable transitions: #{Enum.map_join(names, ", ", &inspect/1)}"]
      end

    {:pass,
     %{
       name: contract_name(contract),
       reachable_states: MapSet.size(visited),
       exercised_transitions: MapSet.size(exercised),
       total_transitions: length(contract.transitions),
       warnings: warnings
     }}
  end

  defp violation_result(contract, violation, trace) do
    {:violation,
     %{
       name: contract_name(contract),
       rule: violation.rule,
       detail: violation.detail,
       trace: trace
     }}
  end

  defp incomplete_result(error) do
    {:incomplete, %{errors: [error], questions: []}}
  end

  defp trace_entry(transition, before, next_state) do
    %{
      transition: transition.name,
      trigger: transition.trigger,
      owner: transition.owner,
      before: before,
      after: next_state
    }
  end

  defp format_trace_entry(entry) do
    "  #{inspect(entry.trigger)} -> #{inspect(entry.transition)} by #{inspect(entry.owner)}\n" <>
      "    #{format_state(entry.before)}\n" <>
      "    => #{format_state(entry.after)}"
  end

  defp format_state(state) do
    contents =
      state
      |> Enum.sort_by(&elem(&1, 0))
      |> Enum.map_join(", ", fn {axis, value} -> "#{axis}: #{inspect(value)}" end)

    "%{#{contents}}"
  end

  defp terminal?(contract, state) do
    Enum.any?(Map.get(contract, :terminal_when, []), &matches?(state, &1))
  end

  defp matches?(state, partial) do
    Enum.all?(partial, fn {axis, value} -> Map.get(state, axis) == value end)
  end

  defp rule_matches?(%{transition: name}, transition), do: transition.name == name
  defp rule_matches?(%{trigger: trigger}, transition), do: transition.trigger == trigger
  defp rule_matches?(_rule, _transition), do: false

  defp evaluate(true, _state), do: true
  defp evaluate(false, _state), do: false
  defp evaluate({:eq, axis, value}, state), do: Map.fetch!(state, axis) == value
  defp evaluate({:neq, axis, value}, state), do: Map.fetch!(state, axis) != value
  defp evaluate({:in, axis, values}, state), do: Map.fetch!(state, axis) in values
  defp evaluate({:not, expression}, state), do: not evaluate(expression, state)
  defp evaluate({:and, expressions}, state), do: Enum.all?(expressions, &evaluate(&1, state))
  defp evaluate({:or, expressions}, state), do: Enum.any?(expressions, &evaluate(&1, state))

  defp evaluate({:implies, premise, consequence}, state) do
    not evaluate(premise, state) or evaluate(consequence, state)
  end

  defp validation_errors(contract) do
    []
    |> require_string(contract, :name)
    |> require_map(contract, :axes)
    |> require_map(contract, :initial)
    |> require_map(contract, :writers)
    |> require_list(contract, :transitions)
    |> require_list(contract, :invariants)
    |> require_list(contract, :transition_rules)
    |> require_list(contract, :terminal_when)
    |> require_list(contract, :questions)
    |> require_boolean(contract, :check_deadlocks)
    |> validate_axes(contract)
    |> validate_initial(contract)
    |> validate_writers(contract)
    |> validate_transitions(contract)
    |> validate_invariants(contract)
    |> validate_transition_rules(contract)
    |> validate_terminal_states(contract)
    |> validate_questions(contract)
    |> Enum.sort()
  end

  defp require_string(errors, contract, field) do
    if is_binary(Map.get(contract, field)),
      do: errors,
      else: ["#{field} must be a string" | errors]
  end

  defp require_map(errors, contract, field) do
    value = Map.get(contract, field)

    if is_map(value) and not is_struct(value),
      do: errors,
      else: ["#{field} must be a plain map" | errors]
  end

  defp require_list(errors, contract, field) do
    if is_list(Map.get(contract, field)), do: errors, else: ["#{field} must be a list" | errors]
  end

  defp require_boolean(errors, contract, field) do
    if is_boolean(Map.get(contract, field)),
      do: errors,
      else: ["#{field} must be a boolean" | errors]
  end

  defp validate_axes(errors, %{axes: axes}) when is_map(axes) do
    axes
    |> Map.to_list()
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.reduce(errors, fn {axis, values}, errors ->
      cond do
        not is_atom(axis) -> ["axis names must be atoms: #{inspect(axis)}" | errors]
        not is_list(values) or values == [] -> ["axis #{inspect(axis)} must have values" | errors]
        Enum.uniq(values) != values -> ["axis #{inspect(axis)} has duplicate values" | errors]
        true -> errors
      end
    end)
  end

  defp validate_axes(errors, _contract), do: errors

  defp validate_initial(errors, %{axes: axes, initial: initial})
       when is_map(axes) and is_map(initial) do
    axis_keys = Map.keys(axes) |> MapSet.new()
    initial_keys = Map.keys(initial) |> MapSet.new()

    errors =
      if axis_keys == initial_keys,
        do: errors,
        else: ["initial must contain exactly every axis" | errors]

    initial
    |> Map.to_list()
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.reduce(errors, fn {axis, value}, errors ->
      if declared_value?(axes, axis, value),
        do: errors,
        else: ["initial value #{inspect(axis)}=#{inspect(value)} is not declared" | errors]
    end)
  end

  defp validate_initial(errors, _contract), do: errors

  defp validate_writers(errors, %{axes: axes, writers: writers})
       when is_map(axes) and is_map(writers) do
    errors =
      if MapSet.new(Map.keys(axes)) == MapSet.new(Map.keys(writers)),
        do: errors,
        else: ["writers must contain exactly every axis" | errors]

    writers
    |> Map.to_list()
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.reduce(errors, fn {axis, owners}, errors ->
      if is_list(owners) and owners != [] and Enum.all?(owners, &is_atom/1),
        do: errors,
        else: ["writers for #{inspect(axis)} must be a non-empty atom list" | errors]
    end)
  end

  defp validate_writers(errors, _contract), do: errors

  defp validate_transitions(errors, %{axes: axes, transitions: transitions})
       when is_map(axes) and is_list(transitions) do
    axis_keys = Map.keys(axes) |> MapSet.new()

    {errors, names} =
      Enum.reduce(transitions, {errors, []}, fn transition, {errors, names} ->
        if is_map(transition) do
          missing = @transition_keys -- Map.keys(transition)

          errors =
            if missing == [],
              do: errors,
              else: ["transition is missing #{inspect(missing)}: #{inspect(transition)}" | errors]

          errors = validate_transition_shape(errors, transition, axes, axis_keys)
          {errors, [Map.get(transition, :name) | names]}
        else
          {["transition must be a map: #{inspect(transition)}" | errors], names}
        end
      end)

    if Enum.uniq(names) == names,
      do: errors,
      else: ["transition names must be unique" | errors]
  end

  defp validate_transitions(errors, _contract), do: errors

  defp validate_transition_shape(errors, transition, axes, axis_keys) do
    name = Map.get(transition, :name, "<unnamed>")
    when_map = Map.get(transition, :when)
    set_map = Map.get(transition, :set)
    preserve = Map.get(transition, :preserve)

    errors =
      if is_atom(Map.get(transition, :name)),
        do: errors,
        else: ["transition name must be an atom: #{inspect(name)}" | errors]

    errors =
      if is_atom(Map.get(transition, :trigger)),
        do: errors,
        else: ["transition #{inspect(name)} trigger must be an atom" | errors]

    errors =
      if is_atom(Map.get(transition, :owner)),
        do: errors,
        else: ["transition #{inspect(name)} owner must be an atom" | errors]

    errors = if is_map(when_map), do: errors, else: ["transition when must be a map" | errors]
    errors = if is_map(set_map), do: errors, else: ["transition set must be a map" | errors]

    errors =
      if is_list(preserve), do: errors, else: ["transition preserve must be a list" | errors]

    if is_map(when_map) and is_map(set_map) and is_list(preserve) do
      classified = MapSet.union(MapSet.new(Map.keys(set_map)), MapSet.new(preserve))
      overlap = MapSet.intersection(MapSet.new(Map.keys(set_map)), MapSet.new(preserve))

      errors =
        if classified == axis_keys and MapSet.size(overlap) == 0,
          do: errors,
          else: [
            "transition #{inspect(name)} must set or preserve every axis exactly once"
            | errors
          ]

      errors =
        if Enum.uniq(preserve) == preserve,
          do: errors,
          else: ["transition #{inspect(name)} preserve contains duplicates" | errors]

      errors
      |> validate_partial_values("#{inspect(name)} guard", when_map, axes)
      |> validate_partial_values("#{inspect(name)} effect", set_map, axes)
    else
      errors
    end
  end

  defp validate_partial_values(errors, name, partial, axes) do
    partial
    |> Map.to_list()
    |> Enum.reduce(errors, fn {axis, value}, errors ->
      cond do
        not Map.has_key?(axes, axis) ->
          ["transition #{inspect(name)} references unknown axis #{inspect(axis)}" | errors]

        not declared_value?(axes, axis, value) ->
          [
            "transition #{inspect(name)} uses undeclared #{inspect(axis)}=#{inspect(value)}"
            | errors
          ]

        true ->
          errors
      end
    end)
  end

  defp validate_invariants(errors, %{axes: axes, invariants: invariants})
       when is_map(axes) and is_list(invariants) do
    Enum.reduce(invariants, errors, fn invariant, errors ->
      cond do
        not is_map(invariant) or not Map.has_key?(invariant, :name) or
            not Map.has_key?(invariant, :check) ->
          ["invariant requires name and check: #{inspect(invariant)}" | errors]

        not (is_binary(invariant.name) or is_atom(invariant.name)) ->
          ["invariant name must be a string or atom: #{inspect(invariant.name)}" | errors]

        true ->
          expression_errors(invariant.check, axes) ++ errors
      end
    end)
  end

  defp validate_invariants(errors, _contract), do: errors

  defp validate_transition_rules(errors, %{
         axes: axes,
         transition_rules: rules,
         transitions: transitions
       })
       when is_map(axes) and is_list(rules) and is_list(transitions) do
    validate_transition_rules(errors, axes, rules, transitions)
  end

  defp validate_transition_rules(errors, _contract), do: errors

  defp validate_transition_rules(errors, axes, rules, transitions) do
    transition_names =
      transitions
      |> Enum.filter(&is_map/1)
      |> Enum.map(&Map.get(&1, :name))
      |> MapSet.new()

    triggers =
      transitions
      |> Enum.filter(&is_map/1)
      |> Enum.map(&Map.get(&1, :trigger))
      |> MapSet.new()

    Enum.reduce(rules, errors, fn rule, errors ->
      selector_count =
        if is_map(rule) do
          Enum.count([:trigger, :transition], &Map.has_key?(rule, &1))
        else
          0
        end

      cond do
        not is_map(rule) ->
          ["transition rule must be a map: #{inspect(rule)}" | errors]

        not Map.has_key?(rule, :name) or
            not (is_binary(rule.name) or is_atom(rule.name)) ->
          ["transition rule requires a name: #{inspect(rule)}" | errors]

        selector_count != 1 ->
          ["transition rule #{inspect(rule.name)} requires exactly one selector" | errors]

        not is_list(Map.get(rule, :preserve)) ->
          ["transition rule #{inspect(rule.name)} preserve must be a list" | errors]

        Enum.uniq(rule.preserve) != rule.preserve ->
          ["transition rule #{inspect(rule.name)} preserve contains duplicates" | errors]

        Enum.any?(rule.preserve, &(not Map.has_key?(axes, &1))) ->
          ["transition rule #{inspect(rule.name)} preserves an unknown axis" | errors]

        Map.has_key?(rule, :transition) and
            not MapSet.member?(transition_names, rule.transition) ->
          ["transition rule #{inspect(rule.name)} references an unknown transition" | errors]

        Map.has_key?(rule, :trigger) and not MapSet.member?(triggers, rule.trigger) ->
          ["transition rule #{inspect(rule.name)} references an unknown trigger" | errors]

        true ->
          errors
      end
    end)
  end

  defp validate_terminal_states(errors, %{axes: axes, terminal_when: terminal_states})
       when is_map(axes) and is_list(terminal_states) do
    Enum.with_index(terminal_states)
    |> Enum.reduce(errors, fn {terminal_state, index}, errors ->
      if is_map(terminal_state) and not is_struct(terminal_state) do
        validate_partial_values(errors, "terminal state #{index}", terminal_state, axes)
      else
        ["terminal state #{index} must be a plain map" | errors]
      end
    end)
  end

  defp validate_terminal_states(errors, _contract), do: errors

  defp validate_questions(errors, %{questions: questions}) when is_list(questions) do
    if Enum.all?(questions, &is_binary/1),
      do: errors,
      else: ["questions must contain only strings" | errors]
  end

  defp validate_questions(errors, _contract), do: errors

  defp valid_questions(%{questions: questions}) when is_list(questions) do
    if Enum.all?(questions, &is_binary/1), do: questions, else: []
  end

  defp valid_questions(_contract), do: []

  defp expression_errors(value, _axes) when is_boolean(value), do: []

  defp expression_errors({operator, axis, value}, axes) when operator in [:eq, :neq] do
    axis_value_errors(axis, value, axes)
  end

  defp expression_errors({:in, axis, values}, axes) when is_list(values) do
    Enum.flat_map(values, &axis_value_errors(axis, &1, axes))
  end

  defp expression_errors({:not, expression}, axes), do: expression_errors(expression, axes)

  defp expression_errors({operator, expressions}, axes)
       when operator in [:and, :or] and is_list(expressions) do
    Enum.flat_map(expressions, &expression_errors(&1, axes))
  end

  defp expression_errors({:implies, premise, consequence}, axes) do
    expression_errors(premise, axes) ++ expression_errors(consequence, axes)
  end

  defp expression_errors(expression, _axes),
    do: ["invalid state expression: #{inspect(expression)}"]

  defp axis_value_errors(axis, value, axes) do
    cond do
      not Map.has_key?(axes, axis) ->
        ["expression references unknown axis #{inspect(axis)}"]

      not declared_value?(axes, axis, value) ->
        ["expression uses undeclared #{inspect(axis)}=#{inspect(value)}"]

      true ->
        []
    end
  end

  defp declared_value?(axes, axis, value) do
    case Map.fetch(axes, axis) do
      {:ok, values} when is_list(values) -> value in values
      _other -> false
    end
  end

  defp contract_name(contract), do: Map.get(contract, :name, "unnamed state contract")
end
