defmodule SpendableWeb.Api.Schemas.SplitLine do
  @moduledoc false
  require OpenApiSpex

  import SpendableWeb.Utils.Money

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "SplitLine",
    description: "One budget's share of a split.",
    type: :object,
    properties: %{
      id: %Schema{type: :string},
      amount: %Schema{type: :string},
      budget_id: %Schema{type: :string}
    },
    required: [:id, :amount, :budget_id]
  })

  def build(%Spendable.Budgets.Schemas.SplitLine{} = line) do
    %__MODULE__{id: line.id, amount: amount(line.amount), budget_id: line.budget_id}
  end
end
