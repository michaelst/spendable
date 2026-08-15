defmodule SpendableCredo.Checks.LiveViewCallbackOrder do
  @moduledoc """
  Enforces LiveView callback ordering.

  House convention: callbacks appear in this order in a LiveView module.

      def mount(_params, _session, socket), do: ...
      def handle_params(_params, _uri, socket), do: ...   # optional, before render
      def render(assigns), do: ...
      def handle_event("...", _params, socket), do: ...
      def handle_info(_msg, socket), do: ...
      def handle_async(_name, _result, socket), do: ...

  `handle_params/3` is the only callback that sits before `render/1`. Every
  other sync/async callback comes after `render/1`.

  Multiple clauses of the same callback (e.g., two `mount` heads) are fine -
  they share a priority. The check only fires when a higher-priority callback
  appears in source order before a lower-priority one (e.g. `render/1` before
  `handle_params/3`).
  """

  use Credo.Check,
    base_priority: :high,
    category: :readability,
    explanations: [
      check: """
      LiveView callbacks should appear in this order:

          mount/3 -> handle_params/3 -> render/1 -> handle_event/3 ->
            handle_info/2 / handle_async/3 / terminate/2

      `handle_params/3` is the only callback that sits before `render/1`.
      Mirror this layout across LiveViews so readers can scan a module by
      jumping to predictable sections.
      """
    ]

  @callback_priorities %{
    {:mount, 3} => 1,
    {:handle_params, 3} => 2,
    {:render, 1} => 3,
    {:sync, 2} => 4,
    {:sync, 3} => 5,
    {:handle_event, 3} => 6,
    {:handle_info, 2} => 7,
    {:handle_async, 3} => 8,
    {:terminate, 2} => 9
  }

  @callback_label %{
    {:mount, 3} => "mount/3",
    {:handle_params, 3} => "handle_params/3",
    {:render, 1} => "render/1",
    {:sync, 2} => "sync/2",
    {:sync, 3} => "sync/3",
    {:handle_event, 3} => "handle_event/3",
    {:handle_info, 2} => "handle_info/2",
    {:handle_async, 3} => "handle_async/3",
    {:terminate, 2} => "terminate/2"
  }

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

  defp traverse(
         {:defmodule, _meta, [{:__aliases__, _aliases_meta, _mod_parts}, _body]} = ast,
         ctx
       ) do
    if not live_view_module?(ast) do
      {ast, ctx}
    else
      callbacks = collect_callbacks(ast)
      violations = find_violations(callbacks)

      ctx =
        Enum.reduce(violations, ctx, fn {kind, meta, expected_after}, acc ->
          put_issue(
            acc,
            format_issue(acc,
              message:
                "`#{@callback_label[kind]}` is defined after `#{@callback_label[expected_after]}` " <>
                  "but should come before it. House order is " <>
                  "mount/3 -> handle_params/3 -> render/1 -> handle_event/3 -> " <>
                  "handle_info/2 / handle_async/3 / terminate/2.",
              trigger: @callback_label[kind],
              line_no: meta[:line]
            )
          )
        end)

      {ast, ctx}
    end
  end

  defp traverse(ast, ctx), do: {ast, ctx}

  defp live_view_module?(ast) do
    {_ast, found} =
      Macro.prewalk(ast, false, fn
        {:use, _use_meta, args} = node, acc ->
          {node, acc or Enum.member?(args, :live_view)}

        node, acc ->
          {node, acc}
      end)

    found
  end

  defp collect_callbacks(ast) do
    {_ast, callbacks} =
      Macro.prewalk(ast, [], fn node, acc ->
        case extract_callback(node) do
          {:ok, kind, meta} ->
            {node, [{kind, meta} | acc]}

          :error ->
            {node, acc}
        end
      end)

    callbacks
    |> Enum.reverse()
    |> Enum.sort_by(fn {_kind, meta} -> meta[:line] || 0 end)
  end

  defp extract_callback(
         {:def, _meta, [{:when, _when_meta, [{name, name_meta, args} | _guard]} | _rest]}
       )
       when is_atom(name) and is_list(args) do
    classify(name, length(args), name_meta)
  end

  defp extract_callback({:def, _meta, [{name, name_meta, args} | _rest]})
       when is_atom(name) and is_list(args) do
    classify(name, length(args), name_meta)
  end

  defp extract_callback(_node), do: :error

  defp classify(name, arity, meta) do
    case Map.fetch(@callback_priorities, {name, arity}) do
      {:ok, _priority} -> {:ok, {name, arity}, meta}
      :error -> :error
    end
  end

  defp find_violations(callbacks) do
    {_highest, _highest_kind, violations} =
      Enum.reduce(callbacks, {0, nil, []}, fn {kind, meta}, {highest, highest_kind, violations} ->
        priority = Map.fetch!(@callback_priorities, kind)

        if priority < highest do
          {highest, highest_kind, [{kind, meta, highest_kind} | violations]}
        else
          {priority, kind, violations}
        end
      end)

    Enum.reverse(violations)
  end
end
