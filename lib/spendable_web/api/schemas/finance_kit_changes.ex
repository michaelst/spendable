defmodule SpendableWeb.Api.Schemas.FinanceKitChanges do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias SpendableWeb.Api.Schemas.FinanceKitAccount
  alias SpendableWeb.Api.Schemas.FinanceKitCharge

  OpenApiSpex.schema(%{
    title: "FinanceKitChanges",
    description: """
    One batch of what the device read out of Wallet. Send `history_token_before` as the token the
    last batch returned, or null on a full backfill; a mismatch is refused rather than applied.
    """,
    type: :object,
    properties: %{
      history_token_before: %Schema{type: :string, nullable: true},
      history_token_after: %Schema{type: :string},
      accounts: %Schema{type: :array, items: FinanceKitAccount},
      inserted: %Schema{type: :array, items: FinanceKitCharge},
      updated: %Schema{
        type: :array,
        items: FinanceKitCharge,
        description: "A charge keeps its id when it settles, so these are applied in place."
      },
      deleted: %Schema{
        type: :array,
        items: %Schema{type: :string},
        description: "External ids of charges that were reversed or declined."
      }
    },
    required: [:history_token_after, :accounts]
  })
end
