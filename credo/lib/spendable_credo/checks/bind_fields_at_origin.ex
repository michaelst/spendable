defmodule SpendableCredo.Checks.BindFieldsAtOrigin do
  @moduledoc """
  Flags standalone field extractions from a bare variable in tests — either
  `%{...} = var` destructures or `var_id = var.id` dot-access bindings.

  Pulling a field out of an already-bound variable on a separate line, just
  to use it as a later `^pin`, means the field should have been bound where
  `var` was originally created.

      # bad (destructure form)
      {:ok, rule} = Banks.create_bank_rule(scope, attrs)
      ...
      %{id: rule_id} = rule
      assert {:ok, %BankRule{id: ^rule_id}} = Banks.delete_bank_rule(scope, rule)

      # bad (dot-extract form)
      {:ok, rule} = Banks.create_bank_rule(scope, attrs)
      ...
      rule_id = rule.id
      assert {:ok, %BankRule{id: ^rule_id}} = Banks.delete_bank_rule(scope, rule)

      # good - bind the field at the original site
      assert {:ok, %BankRule{id: rule_id} = rule} = Banks.create_bank_rule(scope, attrs)
      ...
      assert {:ok, %BankRule{id: ^rule_id}} = Banks.delete_bank_rule(scope, rule)

  Only triggers when the right-hand side is a bare variable reference (or a
  dot chain rooted in one). A destructure of a function-call result (e.g.
  `%{a: a} = call()`) is left alone since there is no "original site" to
  fold into.
  """

  use Credo.Check,
    base_priority: :high,
    category: :readability,
    explanations: [
      check: """
      Don't destructure an existing variable in tests just to pin a field
      later. Bind the field at the original `=` (the `assert ... = call()`
      or pattern match that produced the variable) using `^pin` in the
      later assertion:

          # bad
          {:ok, rule} = create_rule(...)
          %{id: rule_id} = rule
          assert {:ok, %BankRule{id: ^rule_id}} = delete(rule)

          # good
          assert {:ok, %BankRule{id: rule_id} = rule} = create_rule(...)
          assert {:ok, %BankRule{id: ^rule_id}} = delete(rule)
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
    {ast, Enum.reduce(stmts, ctx, &check_statement/2)}
  end

  defp traverse(ast, ctx), do: {ast, ctx}

  defp check_statement({:=, meta, [lhs, rhs]}, ctx) do
    cond do
      map_or_struct_pattern?(lhs) and variable_ref?(rhs) ->
        add_destructure_issue(ctx, meta[:line], var_name(rhs))

      variable_ref?(lhs) ->
        case dot_chain_root(rhs) do
          {:ok, root_var} ->
            add_dot_extract_issue(ctx, meta[:line], var_name(lhs), root_var)

          :none ->
            ctx
        end

      true ->
        ctx
    end
  end

  defp check_statement(_other, ctx), do: ctx

  defp map_or_struct_pattern?({:%{}, _meta, _fields}), do: true
  defp map_or_struct_pattern?({:%, _meta, [_struct, {:%{}, _inner_meta, _fields}]}), do: true
  defp map_or_struct_pattern?(_other), do: false

  defp variable_ref?({name, _meta, context}) when is_atom(name) and not is_list(context) do
    name |> Atom.to_string() |> String.starts_with?("_") |> Kernel.not()
  end

  defp variable_ref?(_other), do: false

  defp var_name({name, _meta, _ctx}), do: name

  defp dot_chain_root({{:., _dot_meta, [inner, field]}, _call_meta, []}) when is_atom(field) do
    walk_dot_chain(inner)
  end

  defp dot_chain_root(_other), do: :none

  defp walk_dot_chain({{:., _dot_meta, [inner, field]}, _call_meta, []}) when is_atom(field) do
    walk_dot_chain(inner)
  end

  defp walk_dot_chain({name, _meta, context} = node)
       when is_atom(name) and not is_list(context) do
    if variable_ref?(node), do: {:ok, name}, else: :none
  end

  defp walk_dot_chain(_other), do: :none

  defp add_destructure_issue(ctx, line_no, var) do
    put_issue(
      ctx,
      format_issue(ctx,
        message:
          "Don't destructure `#{var}` just to pin a field. Bind the field where " <>
            "`#{var}` was originally created (e.g. `assert {:ok, %Schema{id: id} = #{var}} = call(...)`) " <>
            "and `^pin` it in the later assertion.",
        trigger: "%{...} = #{var}",
        line_no: line_no
      )
    )
  end

  defp add_dot_extract_issue(ctx, line_no, local, root_var) do
    put_issue(
      ctx,
      format_issue(ctx,
        message:
          "Don't extract `#{root_var}.field` into `#{local}` on a separate line. Bind the field " <>
            "where `#{root_var}` was originally created (e.g. `assert {:ok, %Schema{id: #{local}} = #{root_var}} = call(...)`) " <>
            "and `^pin` it in the later assertion.",
        trigger: "#{local} = #{root_var}.",
        line_no: line_no
      )
    )
  end
end
