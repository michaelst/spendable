defmodule SpendableCredo.Checks.NoAssign2 do
  @moduledoc """
  Disallows `assign/2` in favour of `assign/3`.

  `assign/2` accepts a keyword list or map and silently overwrites every key
  it touches. `assign/3` is explicit about which key is being set, which makes
  diffs and call sites easier to read and reduces the risk of accidentally
  clobbering an unrelated assign.

      # bad
      assign(socket, foo: 1, bar: 2)

      # good
      socket
      |> assign(:foo, 1)
      |> assign(:bar, 2)

  Passing a plain variable as the second argument is allowed, since the
  variable may already be a map/struct produced elsewhere:

      # allowed
      assign(assigns, report)
  """

  use Credo.Check,
    base_priority: :high,
    category: :warning,
    explanations: [
      check: """
      Prefer `assign/3` over `assign/2`. Set one key at a time so each call
      site names what it is updating:

          # bad
          assign(socket, foo: 1, bar: 2)

          # good
          socket
          |> assign(:foo, 1)
          |> assign(:bar, 2)
      """
    ]

  @impl true
  def run(%SourceFile{} = source_file, params) do
    ast = SourceFile.ast(source_file)
    piped = collect_piped_assign_metas(ast)
    ctx = Context.build(source_file, params, __MODULE__, %{})

    result = Credo.Code.prewalk(source_file, &traverse(&1, &2, piped), ctx)
    result.issues
  end

  defp collect_piped_assign_metas(ast) do
    {_ast, set} =
      Macro.prewalk(ast, MapSet.new(), fn
        {:|>, _meta, [_lhs, {:assign, meta, args}]} = node, acc when is_list(args) ->
          {node, MapSet.put(acc, meta_key(meta))}

        {:|>, _meta, [_lhs, {{:., _dot_meta, [_module, :assign]}, meta, args}]} = node, acc
        when is_list(args) ->
          {node, MapSet.put(acc, meta_key(meta))}

        node, acc ->
          {node, acc}
      end)

    set
  end

  # Unqualified call: assign(arg1, arg2)
  defp traverse({:assign, meta, [_socket, second_arg]} = ast, ctx, piped) do
    if MapSet.member?(piped, meta_key(meta)) do
      # Right-hand side of a pipe with two explicit args = effective arity 3, OK.
      {ast, ctx}
    else
      if variable_ref?(second_arg), do: {ast, ctx}, else: {ast, add_issue(ctx, meta)}
    end
  end

  # Piped call with one explicit arg = effective arity 2.
  defp traverse({:assign, meta, [only_arg]} = ast, ctx, piped) do
    if MapSet.member?(piped, meta_key(meta)) do
      if variable_ref?(only_arg), do: {ast, ctx}, else: {ast, add_issue(ctx, meta)}
    else
      {ast, ctx}
    end
  end

  # Qualified call: Mod.assign(arg1, arg2) - e.g. Phoenix.Component.assign/2
  defp traverse(
         {{:., _dot_meta, [_module, :assign]}, meta, [_socket, second_arg]} = ast,
         ctx,
         piped
       ) do
    if MapSet.member?(piped, meta_key(meta)) do
      {ast, ctx}
    else
      if variable_ref?(second_arg), do: {ast, ctx}, else: {ast, add_issue(ctx, meta)}
    end
  end

  defp traverse({{:., _dot_meta, [_module, :assign]}, meta, [only_arg]} = ast, ctx, piped) do
    if MapSet.member?(piped, meta_key(meta)) do
      if variable_ref?(only_arg), do: {ast, ctx}, else: {ast, add_issue(ctx, meta)}
    else
      {ast, ctx}
    end
  end

  defp traverse(ast, ctx, _piped), do: {ast, ctx}

  # A plain variable reference: {name, meta, nil | atom} where context is not a list.
  defp variable_ref?({name, _meta, context}) when is_atom(name) and not is_list(context), do: true
  defp variable_ref?(_term), do: false

  defp meta_key(meta), do: {meta[:line], meta[:column]}

  defp add_issue(ctx, meta) do
    put_issue(
      ctx,
      format_issue(ctx,
        message:
          "Avoid `assign/2`. Use `assign/3` (one key per call) so each assign " <>
            "is explicit about what it updates - e.g. `assign(socket, :foo, 1)`.",
        trigger: "assign/2",
        line_no: meta[:line]
      )
    )
  end
end
