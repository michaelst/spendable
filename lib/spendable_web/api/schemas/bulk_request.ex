defmodule SpendableWeb.Api.Schemas.BulkRequest do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "BulkRequest",
    description: """
    Applies the same change to several transactions. `budget_id` spends each transaction's whole
    amount from that budget, replacing whatever it was allocated to before.
    """,
    type: :object,
    properties: %{
      transaction_ids: %Schema{type: :array, items: %Schema{type: :string}, minItems: 1},
      reviewed: %Schema{type: :boolean},
      excluded: %Schema{type: :boolean},
      budget_id: %Schema{type: :string}
    },
    required: [:transaction_ids],
    example: %{"transaction_ids" => ["txn_01j0one", "txn_01j0two"], "reviewed" => true}
  })
end
