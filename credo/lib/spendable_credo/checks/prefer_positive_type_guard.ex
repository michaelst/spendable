defmodule SpendableCredo.Checks.PreferPositiveTypeGuard do
  @moduledoc """
  Prefer a positive type guard over `not is_nil/1`.

  `not is_nil(x)` only rules out a single value and lets everything else
  through. A positive guard pins the type you actually expect, which surfaces
  bugs earlier and documents intent at the call site.

      # bad
      if not is_nil(estimated_delivery_date) do

      # good
      if is_struct(estimated_delivery_date, Date) do

  Ecto queries are the exception: `not is_nil(field)` is the idiomatic way to
  express `IS NOT NULL`, so occurrences inside `from`, `where`, `having`,
  `dynamic`, etc. are ignored.
  """

  use Credo.Check,
    base_priority: :high,
    category: :warning,
    explanations: [
      check: """
      Prefer a positive type guard (`is_struct/2`, `is_binary/1`, `is_integer/1`,
      ...) over `not is_nil/1`. A positive guard pins the type you expect instead
      of merely ruling out `nil`:

          # bad
          not is_nil(value)

          # good
          is_struct(value, DateTime)

      Ecto query expressions (`where`, `having`, `dynamic`, `from ...`) are
      exempt, since `not is_nil(field)` is the idiomatic `IS NOT NULL`.
      """
    ]

  @ecto_query_funs [
    :where,
    :or_where,
    :having,
    :or_having,
    :on,
    :dynamic,
    :select,
    :select_merge,
    :join,
    :from
  ]

  @impl true
  def run(%SourceFile{} = source_file, params) do
    ast = SourceFile.ast(source_file)
    excluded = collect_ecto_is_nil_metas(ast)
    ctx = Context.build(source_file, params, __MODULE__, %{})

    result = Credo.Code.prewalk(source_file, &traverse(&1, &2, excluded), ctx)
    result.issues
  end

  defp collect_ecto_is_nil_metas(ast) do
    ecto_available? = ecto_query_available?(ast)

    {_ast, set} =
      Macro.prewalk(ast, MapSet.new(), fn
        # Qualified call: Ecto.Query.where(...), Ecto.Query.from(...), etc. Always Ecto.
        {{:., _dot_meta, [{:__aliases__, _aliases_meta, [:Ecto, :Query]}, fun]}, _meta, args} =
            node,
        acc
        when fun in @ecto_query_funs and is_list(args) ->
          {node, collect_is_nil_metas(args, acc)}

        # Unqualified call: where(...), from(...), etc. Only treat as Ecto when the
        # file actually has the query macros in scope, so a local function that
        # happens to share a name (e.g. SpendableWeb.Utils.Join.join/3) is not exempted.
        {fun, _meta, args} = node, acc when fun in @ecto_query_funs and is_list(args) ->
          if ecto_available?, do: {node, collect_is_nil_metas(args, acc)}, else: {node, acc}

        node, acc ->
          {node, acc}
      end)

    set
  end

  # `use` of these modules brings `Ecto.Query` into scope (each imports it).
  @ecto_query_scope_uses [[:Spendable, :Schema], [:Spendable, :DataCase]]

  # Detects whether `Ecto.Query`'s macros are in scope - either imported directly
  # or pulled in via a `use` that imports it (e.g. `use Spendable.Schema`).
  defp ecto_query_available?(ast) do
    {_ast, available?} =
      Macro.prewalk(ast, false, fn
        {:import, _meta, [{:__aliases__, _aliases_meta, [:Ecto, :Query]} | _rest]} = node, _acc ->
          {node, true}

        {:use, _meta, [{:__aliases__, _aliases_meta, parts} | _rest]} = node, _acc
        when parts in @ecto_query_scope_uses ->
          {node, true}

        node, acc ->
          {node, acc}
      end)

    available?
  end

  defp collect_is_nil_metas(ast, acc) do
    {_ast, set} =
      Macro.prewalk(ast, acc, fn
        {:is_nil, meta, [_arg]} = node, inner -> {node, MapSet.put(inner, meta_key(meta))}
        node, inner -> {node, inner}
      end)

    set
  end

  defp traverse({:not, _meta, [{:is_nil, inner_meta, [_arg]}]} = ast, ctx, excluded) do
    if MapSet.member?(excluded, meta_key(inner_meta)) do
      {ast, ctx}
    else
      {ast, add_issue(ctx, inner_meta)}
    end
  end

  defp traverse(ast, ctx, _excluded), do: {ast, ctx}

  defp meta_key(meta), do: {meta[:line], meta[:column]}

  defp add_issue(ctx, meta) do
    put_issue(
      ctx,
      format_issue(ctx,
        message:
          "Prefer a positive type guard over `not is_nil/1` - e.g. " <>
            "`is_struct(x, DateTime)` or `is_binary(x)`. A positive guard pins " <>
            "the type you expect instead of merely ruling out nil.",
        trigger: "not is_nil",
        line_no: meta[:line]
      )
    )
  end
end
