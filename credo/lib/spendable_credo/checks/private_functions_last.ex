defmodule SpendableCredo.Checks.PrivateFunctionsLast do
  @moduledoc """
  Public functions must be defined before private functions in a module.

  Once a `defp` appears, every following definition should be private too.
  Keeping the public API at the top lets a reader scan what a module exposes
  without wading through helpers first.

      # bad
      def a, do: helper()
      defp helper, do: :ok
      def b, do: :ok

      # good
      def a, do: helper()
      def b, do: :ok
      defp helper, do: :ok
  """

  use Credo.Check,
    base_priority: :high,
    category: :readability,
    explanations: [
      check: """
      Keep all public functions (`def`) above private functions (`defp`) in a
      module. Move any public function defined after a private one up above the
      private block.
      """
    ]

  @impl true
  def run(%SourceFile{} = source_file, params) do
    ctx = Context.build(source_file, params, __MODULE__, %{})
    result = Credo.Code.prewalk(source_file, &traverse/2, ctx)
    result.issues
  end

  defp traverse({:defmodule, _meta, [_alias, [do: body]]} = ast, ctx) do
    {ast, check_body(body, ctx)}
  end

  defp traverse(ast, ctx), do: {ast, ctx}

  defp check_body({:__block__, _meta, statements}, ctx), do: check_statements(statements, ctx)
  defp check_body(_single_statement, ctx), do: ctx

  defp check_statements(statements, ctx) do
    {_seen_private?, ctx} =
      Enum.reduce(statements, {false, ctx}, fn statement, {seen_private?, ctx} ->
        case definition(statement) do
          {:private, _line} -> {true, ctx}
          {:public, line} when seen_private? -> {seen_private?, add_issue(ctx, line)}
          _other -> {seen_private?, ctx}
        end
      end)

    ctx
  end

  defp definition({:def, meta, _args}), do: {:public, meta[:line]}
  defp definition({:defp, meta, _args}), do: {:private, meta[:line]}
  defp definition(_other), do: :other

  defp add_issue(ctx, line_no) do
    put_issue(
      ctx,
      format_issue(ctx,
        message:
          "Public functions must come before private functions. " <>
            "Move this `def` above the private functions in the module.",
        trigger: "def",
        line_no: line_no
      )
    )
  end
end
