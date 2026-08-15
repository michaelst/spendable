defmodule SpendableCredo.Checks.NoSigilWordLists do
  @moduledoc """
  Disallows the `~w` / `~W` sigils for defining lists of strings or atoms.

  House style: write the list out explicitly so each item is quoted and the
  list reads as data, not shorthand.

      # bad
      ~w(amex discover visa)
      ~w(pending paid void)a

      # good
      ["amex", "discover", "visa"]
      [:pending, :paid, :void]
  """

  use Credo.Check,
    base_priority: :normal,
    category: :readability,
    explanations: [
      check: """
      Prefer explicit list literals over `~w(...)` / `~W(...)` sigils for
      lists of strings or atoms:

          # bad
          ~w(amex discover visa)
          ~w(pending paid void)a

          # good
          ["amex", "discover", "visa"]
          [:pending, :paid, :void]
      """
    ]

  @impl true
  def run(%SourceFile{} = source_file, params) do
    ctx = Context.build(source_file, params, __MODULE__, %{})
    result = Credo.Code.prewalk(source_file, &traverse/2, ctx)
    result.issues
  end

  defp traverse({:sigil_w, meta, _args} = ast, ctx), do: {ast, add_issue(ctx, meta, "~w")}
  defp traverse({:sigil_W, meta, _args} = ast, ctx), do: {ast, add_issue(ctx, meta, "~W")}
  defp traverse(ast, ctx), do: {ast, ctx}

  defp add_issue(ctx, meta, trigger) do
    put_issue(
      ctx,
      format_issue(ctx,
        message:
          "Avoid `#{trigger}(...)`. Write the list out explicitly - " <>
            "e.g. `[\"amex\", \"discover\", \"visa\"]` or `[:pending, :paid, :void]` - " <>
            "so each item is quoted and the list reads as data.",
        trigger: trigger,
        line_no: meta[:line]
      )
    )
  end
end
