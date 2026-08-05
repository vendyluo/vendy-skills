skill_dir = Path.expand("..", __DIR__)
Code.require_file(Path.join(__DIR__, "verifier.exs"))

case System.argv() do
  [contract_path] ->
    loaded_contract =
      try do
        {contract, _binding} = Code.eval_file(Path.expand(contract_path))
        {:ok, contract}
      rescue
        exception ->
          {:error, Exception.message(exception)}
      end

    result =
      case loaded_contract do
        {:ok, contract} ->
          StateModel.Verifier.verify(contract)

        {:error, message} ->
          {:incomplete, %{errors: ["contract could not be loaded: #{message}"], questions: []}}
      end

    IO.puts(StateModel.Verifier.format(result))

    exit_code =
      case result do
        {:pass, _report} -> 0
        {:violation, _report} -> 1
        {:incomplete, _report} -> 2
      end

    System.halt(exit_code)

  _args ->
    IO.puts(:stderr, "usage: elixir #{Path.relative_to_cwd(__ENV__.file)} <contract.exs>")
    IO.puts(:stderr, "skill root: #{skill_dir}")
    System.halt(2)
end
