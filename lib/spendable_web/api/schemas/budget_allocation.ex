defmodule SpendableWeb.Api.Schemas.BudgetAllocation do
  @moduledoc false
  require OpenApiSpex

  import SpendableWeb.Utils.Money

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "BudgetAllocation",
    description: "One budget's share of a transaction.",
    type: :object,
    properties: %{
      id: %Schema{type: :string},
      amount: %Schema{type: :string},
      budget_id: %Schema{type: :string}
    },
    required: [:id, :amount, :budget_id]
  })

  def build(%Spendable.Budgets.Schemas.BudgetAllocation{} = allocation) do
    %__MODULE__{
      id: allocation.id,
      amount: amount(allocation.amount),
      budget_id: allocation.budget_id
    }
  end
end
