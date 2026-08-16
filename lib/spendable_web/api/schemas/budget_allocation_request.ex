defmodule SpendableWeb.Api.Schemas.BudgetAllocationRequest do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "BudgetAllocationRequest",
    description: """
    An allocation to keep, update or add. Distinct from BudgetAllocation because `id` is optional.
    """,
    type: :object,
    properties: %{
      id: %Schema{type: :string, description: "Omit to add a new allocation."},
      amount: %Schema{type: :string},
      budget_id: %Schema{type: :string}
    },
    required: [:amount, :budget_id]
  })
end
