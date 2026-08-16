defmodule SpendableWeb.Api.Schemas.FinanceKitCharge do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "FinanceKitCharge",
    description: "One charge exactly as Wallet reported it.",
    type: :object,
    properties: %{
      account_external_id: %Schema{type: :string},
      external_id: %Schema{type: :string},
      amount: %Schema{type: :string, description: "Unsigned. The indicator decides the sign."},
      credit_debit_indicator: %Schema{
        type: :string,
        enum: ["credit", "debit"],
        description: "Which way the money went. Debits are stored negative."
      },
      date: %Schema{type: :string, format: :date},
      name: %Schema{type: :string},
      pending: %Schema{type: :boolean}
    },
    required: [
      :account_external_id,
      :external_id,
      :amount,
      :credit_debit_indicator,
      :date,
      :name,
      :pending
    ]
  })
end
