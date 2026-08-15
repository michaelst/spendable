defmodule SpendableCredo.Checks.LiveViewHandleParams do
  @moduledoc """
  Ensures every LiveView defines `handle_params/3`.

  House rule: `handle_params/3` is always required on a LiveView. Define it as
  a no-op when you don't need to react to URL params:

      def handle_params(_params, _uri, socket) do
        {:noreply, socket}
      end

  The reason it's mandatory: several SpendableWeb on-mount hooks
  (`SpendableWeb.Hooks.DatePicker`, `SpendableWeb.Hooks.Filter`,
  `SpendableWeb.Hooks.RestoreFilters`) call `patch_params/2`, which uses
  `push_patch/2` internally. Phoenix routes every `push_patch` (and any URL
  with a query string at mount time) through `handle_params/3`. Missing the
  callback raises `UndefinedFunctionError`.

  A module is recognised as a LiveView when it contains `use ..., :live_view`.
  Modules under `SpendableWeb.Hooks.*` and `SpendableWeb.Utils.*` are skipped:
  they `use :live_view` only to bring in helpers, and Phoenix never routes
  `handle_params/3` to them.
  """

  use Credo.Check,
    base_priority: :high,
    category: :warning,
    explanations: [
      check: """
      Every LiveView must define `handle_params/3`. Define it as a no-op when
      you don't need to react to URL params:

          def handle_params(_params, _uri, socket) do
            {:noreply, socket}
          end

      Without it, hooks that push patches (DatePicker, Filter, RestoreFilters)
      and URLs with query strings raise `UndefinedFunctionError` at runtime.
      """
    ]

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

  defp traverse({:defmodule, meta, [{:__aliases__, _aliases_meta, mod_parts}, _body]} = ast, ctx) do
    cond do
      not live_view_module?(ast) ->
        {ast, ctx}

      helper_module?(mod_parts) ->
        {ast, ctx}

      has_handle_params_3?(ast) ->
        {ast, ctx}

      true ->
        ctx =
          put_issue(
            ctx,
            format_issue(ctx,
              message:
                "LiveView is missing `handle_params/3`. Add " <>
                  "`def handle_params(_params, _uri, socket), do: {:noreply, socket}` - " <>
                  "hooks like DatePicker, Filter, and RestoreFilters push patches that " <>
                  "round-trip through it, so it is always required.",
              trigger: "handle_params/3",
              line_no: meta[:line]
            )
          )

        {ast, ctx}
    end
  end

  defp traverse(ast, ctx), do: {ast, ctx}

  defp helper_module?(mod_parts) do
    Enum.any?(mod_parts, &(&1 in [:Hooks, :Utils, :Components]))
  end

  defp live_view_module?(ast) do
    {_ast, found} =
      Macro.prewalk(ast, false, fn
        {:use, _meta, args} = node, acc ->
          {node, acc or Enum.member?(args, :live_view)}

        node, acc ->
          {node, acc}
      end)

    found
  end

  defp has_handle_params_3?(ast) do
    {_ast, found} =
      Macro.prewalk(ast, false, fn
        {:def, _meta, [{:handle_params, _name_meta, args} | _rest]} = node, _acc
        when is_list(args) and length(args) == 3 ->
          {node, true}

        {:def, _meta,
         [{:when, _when_meta, [{:handle_params, _name_meta2, args} | _guard]} | _rest2]} = node,
        _acc
        when is_list(args) and length(args) == 3 ->
          {node, true}

        node, acc ->
          {node, acc}
      end)

    found
  end
end
