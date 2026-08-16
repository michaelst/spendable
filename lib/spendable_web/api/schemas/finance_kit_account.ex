defmodule SpendableWeb.Api.Schemas.FinanceKitAccount do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "FinanceKitAccount",
    description: """
    One account in the user's Wallet. The kind is mapped onto the vocabulary the rest of the API
    already uses, so an Apple Card reads as a credit card and Apple Cash as a checking account.
    """,
    type: :object,
    properties: %{
      external_id: %Schema{type: :string},
      name: %Schema{type: :string},
      kind: %Schema{type: :string, enum: ["credit_card", "cash", "savings"]},
      balance: %Schema{type: :string, description: "Unsigned. The indicator decides the sign."},
      credit_debit_indicator: %Schema{
        type: :string,
        enum: ["credit", "debit"],
        description: "A card's balance is a debit, because it is owed."
      }
    },
    required: [:external_id, :name, :kind, :balance, :credit_debit_indicator]
  })
end
