defmodule SpendableCredo.Checks.PipeIntoNoreplyOk do
  @moduledoc """
  Disallows piping inside a `{:noreply, _}`, `{:ok, _}`, `{:cont, _}`, or
  `{:halt, _}` tuple. When you need to chain operations, pipe into the
  `noreply/1`, `ok/1`, `cont/1`, or `halt/1` helper instead.

      # allowed
      {:noreply, socket}

      # bad
      {:noreply, socket |> assign(:foo, 1)}

      # good
      socket |> assign(:foo, 1) |> noreply()

  The helpers are defined in `SpendableWeb.Helpers`.
  """

  use Credo.Check,
    base_priority: :high,
    category: :readability,
    explanations: [
      check: """
      Don't pipe inside a `{:noreply, _}` / `{:ok, _}` / `{:cont, _}` /
      `{:halt, _}` tuple. Pipe into the matching helper instead:

          # bad
          {:noreply, socket |> assign(:foo, 1)}

          # good
          socket |> assign(:foo, 1) |> noreply()

      A bare `{:noreply, socket}` is fine.
      """
    ]

  @tuple_tags [:noreply, :ok, :cont, :halt]

  @impl true
  def run(%SourceFile{} = source_file, params) do
    ctx = Context.build(source_file, params, __MODULE__, %{})
    result = Credo.Code.prewalk(source_file, &traverse/2, ctx)
    result.issues
  end

  defp traverse({tag, value} = ast, ctx) when tag in @tuple_tags do
    if pipe?(value) do
      {ast, add_issue(ctx, pipe_meta(value), tag)}
    else
      {ast, ctx}
    end
  end

  defp traverse(ast, ctx), do: {ast, ctx}

  defp pipe?({:|>, _meta, _args}), do: true
  defp pipe?(_other), do: false

  defp pipe_meta({:|>, meta, _args}), do: meta

  defp add_issue(ctx, meta, tag) do
    put_issue(
      ctx,
      format_issue(ctx,
        message:
          "Don't pipe inside `{:#{tag}, ...}`. Pipe into `#{tag}/1` instead, " <>
            "e.g. `socket |> ... |> #{tag}()`.",
        trigger: "{:#{tag}, ... |> ...}",
        line_no: meta[:line]
      )
    )
  end
end
