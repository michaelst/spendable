defmodule SpendableWeb.Api.Schemas.TransactionRequest do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias SpendableWeb.Api.Schemas.BudgetAllocationRequest

  OpenApiSpex.schema(%{
    title: "TransactionRequest",
    description: """
    Send the whole set of allocations you want. One with an `id` is kept and updated, one without
    is added, one left out is deleted. Whatever is left of the amount goes to Spendable, so the
    allocations in the response are the ones that count.

    That also means a validation error's pointer indexes the list the server settled on, not the
    one that was sent - match the offending line by its `budget_id`, not by position.
    """,
    type: :object,
    properties: %{
      name: %Schema{type: :string},
      amount: %Schema{type: :string, description: "Negative for money going out."},
      date: %Schema{type: :string, format: :date},
      note: %Schema{type: :string, nullable: true},
      reviewed: %Schema{type: :boolean},
      excluded: %Schema{type: :boolean},
      budget_allocations: %Schema{type: :array, items: BudgetAllocationRequest}
    },
    example: %{
      "name" => "Market",
      "amount" => "-30.00",
      "date" => "2026-08-15",
      "budget_allocations" => [%{"amount" => "-30.00", "budget_id" => "bgt_01j0groceries"}]
    }
  })
end
