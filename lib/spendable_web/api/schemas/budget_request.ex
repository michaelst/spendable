defmodule SpendableWeb.Api.Schemas.BudgetRequest do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "BudgetRequest",
    description: """
    Amounts are decimal strings. `balance` is what the user wants the budget to hold - the server
    works out the adjustment that gets it there, so never send `adjustment`.
    """,
    type: :object,
    properties: %{
      name: %Schema{type: :string},
      type: %Schema{type: :string, enum: ["tracking", "envelope", "goal"]},
      budgeted_amount: %Schema{type: :string, nullable: true},
      balance: %Schema{type: :string}
    },
    example: %{"name" => "Groceries", "type" => "envelope", "budgeted_amount" => "400.00"}
  })
end
