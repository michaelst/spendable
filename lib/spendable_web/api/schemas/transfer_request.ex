defmodule SpendableWeb.Api.Schemas.TransferRequest do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "TransferRequest",
    description: "Exactly two transactions: one leaving an account and one arriving in another.",
    type: :object,
    properties: %{
      transaction_ids: %Schema{
        type: :array,
        items: %Schema{type: :string},
        minItems: 2,
        maxItems: 2
      }
    },
    required: [:transaction_ids],
    example: %{"transaction_ids" => ["txn_01j0out", "txn_01j0in"]}
  })
end
