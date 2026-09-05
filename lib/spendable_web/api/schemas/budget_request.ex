defmodule SpendableWeb.Api.Schemas.BudgetRequest do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "BudgetRequest",
    description: """
    Amounts are decimal strings. `balance` is what the user wants the budget to hold - the server
    works out the adjustment that gets it there, so never send `adjustment`.

    `funding_amount` is what the budget puts into itself each month; setting it is what makes a
    budget fill on its own instead of being fed by hand. Only an envelope or a goal can hold
    money, so it is ignored on a tracking or income budget.

    `rollover` says whether the balance carries into next month. Send false and each month tops the
    budget back up to its funding amount instead. Only an envelope can decline to roll over.
    """,
    type: :object,
    properties: %{
      name: %Schema{type: :string},
      type: %Schema{type: :string, enum: ["tracking", "envelope", "goal", "income"]},
      budgeted_amount: %Schema{type: :string, nullable: true},
      funding_amount: %Schema{type: :string, nullable: true},
      rollover: %Schema{type: :boolean},
      balance: %Schema{type: :string}
    },
    example: %{
      "name" => "Groceries",
      "type" => "envelope",
      "budgeted_amount" => "400.00",
      "funding_amount" => "400.00"
    }
  })
end
