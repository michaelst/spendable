defmodule SpendableCredo.Checks.ActionModuleNaming do
  @moduledoc """
  Ensures action module name, public function, and filename all align.

  Each action module lives in an `Actions` namespace and represents a single
  operation. This check enforces that:

  1. **Public function matches module name** - `Actions.CreateBudget`
     must export `create_budget/N`. Functions with `?` or `!` suffixes
     are accepted (e.g., `can?`, `upsert_order_category!`).

  2. **Filename matches module name** - `Actions.CreateBudget` must
     live in `create_budget.ex`.

  Only modules with `Actions` in their namespace are checked. `.exs` files
  (tests, scripts) are skipped.
  """

  use Credo.Check,
    base_priority: :high,
    category: :warning,
    explanations: [
      check: """
      Action modules should follow the naming convention where the module name,
      exported public function, and filename all align.

          # File: lib/spendable/banks/actions/create_budget.ex
          defmodule Spendable.Budgets.Actions.CreateBudget do
            def create_budget(scope, attrs) do
              ...
            end
          end

      The module name's last segment (CamelCase) should be the camelized version
      of the main public function name (snake_case), and the file should be named
      with the snake_case version. Functions with `?` or `!` suffixes are accepted.
      """
    ]

  alias Credo.Code.Name

  @impl true
  def run(%SourceFile{filename: filename} = source_file, params) do
    if Path.extname(filename) == ".exs" do
      []
    else
      ctx = Context.build(source_file, params, __MODULE__, %{filename: filename})
      result = Credo.Code.prewalk(source_file, &traverse/2, ctx)
      result.issues
    end
  end

  defp traverse({:defmodule, meta, [{:__aliases__, _meta2, mod_parts} | _rest]} = ast, ctx) do
    if actions_module?(mod_parts) do
      mod_name = Name.full(mod_parts)
      last_segment = mod_parts |> List.last() |> to_string()
      expected_fn_name = Macro.underscore(last_segment)
      normalized_mod = normalize(last_segment)

      ctx =
        if has_matching_function?(ast, normalized_mod) do
          ctx
        else
          put_issue(
            ctx,
            format_issue(ctx,
              message:
                "Action module `#{mod_name}` should export a public function `#{expected_fn_name}`.",
              trigger: mod_name,
              line_no: meta[:line]
            )
          )
        end

      file_basename = Path.basename(ctx.filename, ".ex")

      ctx =
        if normalize(file_basename) == normalized_mod do
          ctx
        else
          put_issue(
            ctx,
            format_issue(ctx,
              message:
                "Action module `#{mod_name}` should be in a file named `#{expected_fn_name}.ex`, found `#{Path.basename(ctx.filename)}`.",
              trigger: mod_name,
              line_no: meta[:line]
            )
          )
        end

      {ast, ctx}
    else
      {ast, ctx}
    end
  end

  defp traverse(ast, ctx), do: {ast, ctx}

  defp actions_module?(mod_parts) do
    Enum.any?(mod_parts, fn part -> to_string(part) == "Actions" end)
  end

  defp has_matching_function?(ast, normalized_mod) do
    {_ast, found} =
      Macro.prewalk(ast, false, fn
        {:def, _meta, [{:when, _when_meta, [{name, _name_meta, _args} | _guard]} | _rest]} =
            node,
        acc
        when is_atom(name) ->
          {node, acc or matches_name?(name, normalized_mod)}

        {:def, _meta, [{name, _meta2, _args} | _rest]} = node, acc when is_atom(name) ->
          {node, acc or matches_name?(name, normalized_mod)}

        node, acc ->
          {node, acc}
      end)

    found
  end

  defp matches_name?(name, normalized_mod) do
    name
    |> to_string()
    # we have some ! and ? functions
    |> String.trim_trailing("?")
    |> String.trim_trailing("!")
    |> normalize()
    |> then(fn input -> input == normalized_mod end)
  end

  defp normalize(name) do
    name
    |> String.downcase()
    |> String.replace("_", "")
  end
end
