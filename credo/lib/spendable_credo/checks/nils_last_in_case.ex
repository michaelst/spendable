defmodule SpendableCredo.Checks.NilsLastInCase do
  @moduledoc """
  Enforces that `nil` patterns appear last in `case` statements.

  When matching multiple patterns in a `case`, placing `nil` first makes the
  code harder to read because the "happy path" is pushed down. Putting `nil`
  last keeps the primary logic at the top and the fallback at the bottom.

      # bad
      case value do
        nil -> :nothing
        %{name: name} -> {:ok, name}
      end

      # good
      case value do
        %{name: name} -> {:ok, name}
        nil -> :nothing
      end
  """

  use Credo.Check,
    base_priority: :normal,
    category: :readability,
    explanations: [
      check: """
      Place `nil` patterns last in `case` statements. This keeps the primary
      logic at the top and the nil/fallback handling at the bottom:

          # bad
          case value do
            nil -> :error
            result -> {:ok, result}
          end

          # good
          case value do
            result -> {:ok, result}
            nil -> :error
          end
      """
    ]

  @impl true
  def run(%SourceFile{} = source_file, params) do
    ctx = Context.build(source_file, params, __MODULE__, %{})
    result = Credo.Code.prewalk(source_file, &traverse/2, ctx)
    result.issues
  end

  defp traverse({:case, _meta, [_expr, [do: clauses]]} = ast, ctx) when is_list(clauses) do
    case nil_clause_position(clauses) do
      {:not_last, line} -> {ast, add_issue(ctx, line)}
      _other -> {ast, ctx}
    end
  end

  defp traverse(ast, ctx), do: {ast, ctx}

  defp nil_clause_position(clauses) do
    last_index = length(clauses) - 1

    clauses
    |> Enum.with_index()
    |> Enum.find_value(:none, &check_clause(&1, last_index))
  end

  defp check_clause({{:->, meta, [[pattern], _body]}, index}, last_index) do
    cond do
      not nil_pattern?(pattern) -> false
      index == last_index -> {:last, meta[:line]}
      true -> {:not_last, meta[:line]}
    end
  end

  defp nil_pattern?(nil), do: true
  defp nil_pattern?({:when, _meta, [nil, _guard]}), do: true
  defp nil_pattern?(_pattern), do: false

  defp add_issue(ctx, line_no) do
    put_issue(
      ctx,
      format_issue(ctx,
        message:
          "Place `nil` patterns last in `case` statements. " <>
            "This keeps the primary logic at the top and nil handling at the bottom.",
        trigger: "nil",
        line_no: line_no
      )
    )
  end
end
