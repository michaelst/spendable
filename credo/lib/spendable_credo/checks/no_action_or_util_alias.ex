defmodule SpendableCredo.Checks.NoActionOrUtilAlias do
  @moduledoc """
  Disallows aliasing leaf modules under an `Actions` or `Utils` namespace.

  Actions are operations on a context and should be called through the
  context's public API rather than aliased directly. Utils are dependency-free
  helpers meant to be `import`ed so their function names read as if they were
  defined locally.

      # bad
      alias Spendable.Budgets.Actions.CreateBudget
      alias Spendable.Budgets.Utils.CalculateBalances

      # good
      # call the context instead of the action
      Spendable.Budgets.create_budget(scope, attrs)

      # import the util
      import Spendable.Budgets.Utils.CalculateBalances

  Aliasing the `Actions` or `Utils` namespace itself is allowed, since that
  is the namespace and not a specific action/util:

      # allowed
      alias SpendableWeb.Utils
  """

  use Credo.Check,
    base_priority: :high,
    category: :design,
    explanations: [
      check: """
      Actions should be called through their context module and Utils should
      be imported. Aliasing a leaf module under an `Actions` or `Utils`
      namespace bypasses that intent.

          # bad
          alias Spendable.Budgets.Actions.CreateBudget
          CreateBudget.create_budget(scope, attrs)

          # good
          Spendable.Budgets.create_budget(scope, attrs)

          # bad
          alias Spendable.Budgets.Utils.CalculateBalances
          CalculateBalances.calculate_balances(budgets)

          # good
          import Spendable.Budgets.Utils.CalculateBalances
          calculate_balances(budgets)
      """
    ]

  alias Credo.Code.Name

  @impl true
  def run(%SourceFile{} = source_file, params) do
    ctx = Context.build(source_file, params, __MODULE__, %{})
    result = Credo.Code.prewalk(source_file, &traverse/2, ctx)
    result.issues
  end

  defp traverse({:alias, meta, [{:__aliases__, _alias_meta, module_parts} | _rest]} = ast, ctx)
       when is_list(module_parts) do
    case forbidden_namespace(module_parts) do
      namespace when namespace in [:actions, :utils] ->
        full_name = Name.full(module_parts)
        {ast, put_issue(ctx, format_issue(ctx, message(namespace, full_name, meta)))}

      nil ->
        {ast, ctx}
    end
  end

  defp traverse(ast, ctx), do: {ast, ctx}

  defp forbidden_namespace(module_parts) do
    last_index = length(module_parts) - 1

    module_parts
    |> Enum.with_index()
    |> Enum.find_value(fn {part, index} ->
      cond do
        part == :Actions and index != last_index -> :actions
        part == :Utils and index != last_index -> :utils
        true -> nil
      end
    end)
  end

  defp message(:actions, full_name, meta) do
    [
      message:
        "Do not alias `#{full_name}`. Actions should be called through their " <>
          "context module instead of being aliased directly.",
      trigger: full_name,
      line_no: meta[:line]
    ]
  end

  defp message(:utils, full_name, meta) do
    [
      message:
        "Do not alias `#{full_name}`. Utils should be `import`ed so their " <>
          "functions read as if defined locally.",
      trigger: full_name,
      line_no: meta[:line]
    ]
  end
end
