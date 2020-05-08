defmodule Spendable.Web.Utils.LogComplexity do
  use Absinthe.Phase
  require Logger

  def run(input, _options \\ []) do
    {_operation, complexity} =
      input
      |> Absinthe.Blueprint.current_operation()
      |> Absinthe.Blueprint.prewalk(0, &handle_node/2)

    Logger.info("Query complexity: #{inspect(complexity)}")
    {:ok, input}
  end

  def handle_node(%{complexity: complexity} = node, max) when complexity > max, do: {node, complexity}
  def handle_node(node, max), do: {node, max}
end
