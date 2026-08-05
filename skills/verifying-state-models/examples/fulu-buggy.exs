model = Code.eval_file(Path.join(__DIR__, "fulu-fixed.exs")) |> elem(0)

buggy_death = %{
  name: :death,
  trigger: :death,
  owner: :combat,
  when: %{life: :alive},
  set: %{life: :dead, control: :active, operation: :recovering},
  preserve: [:authority]
}

%{
  model
  | name: "Fulu pre-fix death clears pause",
    writers: Map.update!(model.writers, :control, &[:combat | &1]),
    transitions:
      Enum.map(model.transitions, fn
        %{name: :death} -> buggy_death
        transition -> transition
      end)
}
