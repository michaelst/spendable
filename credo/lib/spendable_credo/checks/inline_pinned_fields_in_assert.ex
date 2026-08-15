defmodule SpendableCredo.Checks.InlinePinnedFieldsInAssert do
  @moduledoc """
  Flags `assert var.field == expected` lines that should be folded into a
  preceding `assert <pattern with var> = call()` using a pinned pattern.

      # bad
      assert {:ok, bank_account} = Banks.get_bank_account(scope, id: id)
      assert bank_account.budget.id == budget.id
      assert bank_account.bank_member.id == bank_member.id

      # good
      %{id: budget_id} = budget
      %{id: bank_member_id} = bank_member

      assert {:ok, %{budget: %{id: ^budget_id}, bank_member: %{id: ^bank_member_id}}} =
               Banks.get_bank_account(scope, id: id)

  Triggered when a variable bound by an `assert <pattern> = <call>` is later
  used in another `assert` in the same block via dot access (e.g.
  `bank_account.budget.id`) or compared directly via `==`/`===` (e.g.
  `assert id == budget.id`). The fix is to fold the expected field into the
  original pattern using `^pin` for comparison values and explicit map/struct
  shape for the path.
  """

  use Credo.Check,
    base_priority: :high,
    category: :warning,
    explanations: [
      check: """
      Bind expected values to local vars and assert struct shape in a single
      `assert ... = ...` with `^` pins, instead of binding the result to a
      var and reading fields off it in follow-up assertions.

          # bad
          assert {:ok, budget} = call()
          assert budget.id == expected_id
          assert budget.name == "Groceries"

          # good
          assert {:ok, %{id: ^expected_id, name: "Groceries"}} = call()
      """
    ]

  @impl true
  def run(%SourceFile{filename: filename} = source_file, params) do
    if test_file?(filename) do
      ctx = Context.build(source_file, params, __MODULE__, %{})
      result = Credo.Code.prewalk(source_file, &traverse/2, ctx)
      result.issues
    else
      []
    end
  end

  defp test_file?(filename), do: String.ends_with?(filename, "_test.exs")

  defp traverse({:__block__, _meta, stmts} = ast, ctx) when is_list(stmts) do
    {_bound, ctx} = Enum.reduce(stmts, {MapSet.new(), ctx}, &process_statement/2)
    {ast, ctx}
  end

  defp traverse(ast, ctx), do: {ast, ctx}

  defp process_statement(
         {:assert, _meta, [{:=, _eq_meta, [pattern, _rhs]} | _rest]},
         {bound, ctx}
       ) do
    {MapSet.union(bound, collect_bare_vars(pattern)), ctx}
  end

  defp process_statement({:assert, meta, [expr | _rest]}, {bound, ctx}) do
    case bound_var_in_dot_chain(expr, bound) do
      {:ok, var} ->
        {bound, add_issue(ctx, meta[:line], var)}

      :none ->
        case bound_var_in_equality(expr, bound) do
          {:ok, var} -> {bound, add_bare_equality_issue(ctx, meta[:line], var)}
          :none -> {bound, ctx}
        end
    end
  end

  defp process_statement(_other, acc), do: acc

  defp collect_bare_vars(pattern) do
    {_walked, {bare, pinned}} =
      Macro.prewalk(pattern, {[], []}, fn
        {:^, _caret_meta, [{var, _var_meta, nil}]} = node, {bare, pinned} when is_atom(var) ->
          {node, {bare, [var | pinned]}}

        {var, _var_meta, nil} = node, {bare, pinned} when is_atom(var) ->
          if pinnable?(var) do
            {node, {[var | bare], pinned}}
          else
            {node, {bare, pinned}}
          end

        node, acc ->
          {node, acc}
      end)

    pinned_set = MapSet.new(pinned)

    bare
    |> Enum.reject(&MapSet.member?(pinned_set, &1))
    |> MapSet.new()
  end

  defp pinnable?(name) do
    name
    |> Atom.to_string()
    |> String.starts_with?("_")
    |> Kernel.not()
  end

  defp bound_var_in_equality({op, _meta, [lhs, rhs]}, bound) when op in [:==, :===] do
    case {bare_bound_var(lhs, bound), bare_bound_var(rhs, bound)} do
      {nil, nil} -> :none
      {nil, var} -> {:ok, var}
      {var, _other} -> {:ok, var}
    end
  end

  defp bound_var_in_equality(_other, _bound), do: :none

  defp bare_bound_var({var, _meta, nil}, bound) when is_atom(var) do
    if MapSet.member?(bound, var), do: var, else: nil
  end

  defp bare_bound_var(_other, _bound), do: nil

  defp bound_var_in_dot_chain(expr, bound) do
    {_walked, found} =
      Macro.prewalk(expr, :none, fn
        node, :none ->
          check_dot_node(node, bound)

        node, found ->
          {node, found}
      end)

    found
  end

  defp check_dot_node({{:., _dot_meta, [_inner, field]}, _call_meta, []} = node, bound)
       when is_atom(field) do
    case dot_root(node) do
      {:ok, var} ->
        if MapSet.member?(bound, var), do: {node, {:ok, var}}, else: {node, :none}

      :none ->
        {node, :none}
    end
  end

  defp check_dot_node(node, _bound), do: {node, :none}

  defp dot_root({{:., _dot_meta, [inner, field]}, _call_meta, []}) when is_atom(field),
    do: dot_root(inner)

  defp dot_root({var, _var_meta, nil}) when is_atom(var), do: {:ok, var}
  defp dot_root(_other), do: :none

  defp add_issue(ctx, line, var) do
    put_issue(
      ctx,
      format_issue(ctx,
        message:
          "Fold `assert #{var}.field == expected` into the previous `assert ... #{var} ... = ...` " <>
            "pattern with `^expected` pins. Asserting struct shape in one pattern keeps the spec " <>
            "for the response in one place.",
        trigger: "assert #{var}.",
        line_no: line
      )
    )
  end

  defp add_bare_equality_issue(ctx, line, var) do
    put_issue(
      ctx,
      format_issue(ctx,
        message:
          "Fold `assert #{var} == expected` into the previous `assert ... #{var} ... = ...` " <>
            "pattern by binding the expected value to a local and replacing `#{var}` with " <>
            "`^expected`. Asserting struct shape in one pattern keeps the spec in one place.",
        trigger: "assert #{var} ==",
        line_no: line
      )
    )
  end
end
