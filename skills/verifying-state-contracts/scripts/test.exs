Code.require_file(Path.join(__DIR__, "verifier.exs"))

ExUnit.start()

defmodule StateContract.VerifierTest do
  use ExUnit.Case, async: true

  @examples Path.expand("../examples", __DIR__)

  test "the fixed Fulu lifecycle contract passes" do
    assert {:pass, report} = verify_example("fulu-fixed.exs")
    assert report.reachable_states > 1
    assert report.exercised_transitions == report.total_transitions
  end

  test "the pre-fix death model returns the shortest preservation counterexample" do
    assert {:violation, report} = verify_example("fulu-buggy.exs")
    assert report.rule == "death preserves control ownership"
    assert List.last(report.trace).transition == :death
    assert length(report.trace) == 2
    assert Enum.at(report.trace, 0).transition == :manual_pause
  end

  test "unresolved human decisions are model incomplete" do
    contract = example("fulu-fixed.exs")
    contract = %{contract | questions: ["Can a refund reopen fulfillment?"]}

    assert {:incomplete, %{errors: [], questions: [_question]}} =
             StateContract.Verifier.verify(contract)
  end

  test "every transition must classify every axis as set or preserved" do
    contract = example("fulu-fixed.exs")
    [first | rest] = contract.transitions
    incomplete = %{first | preserve: List.delete(first.preserve, :authority)}
    contract = %{contract | transitions: [incomplete | rest]}

    assert {:incomplete, %{errors: errors}} = StateContract.Verifier.verify(contract)
    assert Enum.any?(errors, &String.contains?(&1, "set or preserve every axis exactly once"))
  end

  test "a nearer deadlock wins over a later transition violation" do
    contract = %{
      name: "deadlock ordering",
      axes: %{phase: [:start, :a, :b, :bad]},
      initial: %{phase: :start},
      writers: %{phase: [:system]},
      questions: [],
      check_deadlocks: true,
      terminal_when: [],
      invariants: [%{name: "bad is forbidden", check: {:neq, :phase, :bad}}],
      transition_rules: [],
      transitions: [
        transition(:to_a, :start, :a),
        transition(:to_b, :start, :b),
        transition(:break_a, :a, :bad)
      ]
    }

    assert {:violation, report} = StateContract.Verifier.verify(contract)
    assert report.rule == "no reachable deadlock"
    assert Enum.map(report.trace, & &1.transition) == [:to_b]
  end

  test "exploration bound returns model incomplete instead of partial pass" do
    contract = example("fulu-fixed.exs")

    assert {:incomplete, %{errors: [error]}} =
             StateContract.Verifier.verify(contract, max_states: 1)

    assert error == "exploration exceeded 1 reachable states"
  end

  test "malformed transition and rule selectors return model incomplete" do
    contract = example("fulu-fixed.exs")
    [first | rest] = contract.transitions
    unnamed = Map.delete(first, :name)

    contract = %{
      contract
      | transitions: [unnamed | rest],
        transition_rules: [
          %{name: "typo", transition: :deth, preserve: [:control]},
          %{name: "ambiguous", transition: :death, trigger: :death, preserve: [:control]}
        ]
    }

    assert {:incomplete, %{errors: errors}} = StateContract.Verifier.verify(contract)
    assert Enum.any?(errors, &String.contains?(&1, "transition is missing"))
    assert Enum.any?(errors, &String.contains?(&1, "unknown transition"))
    assert Enum.any?(errors, &String.contains?(&1, "exactly one selector"))
  end

  test "guard values are validated independently from effects" do
    contract = example("fulu-fixed.exs")
    [first | rest] = contract.transitions

    invalid = %{
      first
      | when: Map.put(first.when, :operation, :typo),
        set: Map.put(first.set, :operation, :hunting)
    }

    contract = %{contract | transitions: [invalid | rest]}

    assert {:incomplete, %{errors: errors}} = StateContract.Verifier.verify(contract)
    assert Enum.any?(errors, &String.contains?(&1, "uses undeclared :operation=:typo"))
  end

  test "a non-list axis domain returns model incomplete instead of crashing" do
    contract = example("fulu-fixed.exs")
    contract = %{contract | axes: Map.put(contract.axes, :operation, :not_a_list)}

    assert {:incomplete, %{errors: errors}} = StateContract.Verifier.verify(contract)
    assert Enum.any?(errors, &String.contains?(&1, "axis :operation must have values"))
  end

  test "missing rule names and invalid transition names return model incomplete" do
    contract = example("fulu-fixed.exs")
    [first | rest] = contract.transitions
    invalid_name = %{first | name: %{}}
    [rule] = contract.transition_rules

    contract = %{
      contract
      | transitions: [invalid_name | rest],
        transition_rules: [Map.delete(rule, :name)]
    }

    assert {:incomplete, %{errors: errors}} = StateContract.Verifier.verify(contract)
    assert Enum.any?(errors, &String.contains?(&1, "transition rule requires a name"))
    assert Enum.any?(errors, &String.contains?(&1, "transition name must be an atom"))
  end

  test "structs in map fields return model incomplete instead of crashing" do
    contract = example("fulu-fixed.exs")
    contract = %{contract | axes: %URI{}}

    assert {:incomplete, %{errors: errors}} = StateContract.Verifier.verify(contract)
    assert "axes must be a plain map" in errors
  end

  test "formatted counterexamples are deterministic" do
    result = verify_example("fulu-buggy.exs")
    assert StateContract.Verifier.format(result) == StateContract.Verifier.format(result)
    assert StateContract.Verifier.format(result) =~ "%{authority: :valid, control: :manual_pause"
  end

  defp verify_example(name), do: name |> example() |> StateContract.Verifier.verify()

  defp example(name) do
    @examples |> Path.join(name) |> Code.eval_file() |> elem(0)
  end

  defp transition(name, from, to) do
    %{
      name: name,
      trigger: name,
      owner: :system,
      when: %{phase: from},
      set: %{phase: to},
      preserve: []
    }
  end
end
