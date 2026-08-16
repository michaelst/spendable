defmodule SpendableWeb.Api.Schemas.BankAccountRequest do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "BankAccountRequest",
    description: "The two things a user decides about an account: whether to sync it, and where it belongs.",
    type: :object,
    properties: %{
      sync: %Schema{type: :boolean},
      budget_id: %Schema{
        type: :string,
        nullable: true,
        description: "Null unassigns, putting the balance back into Spendable."
      }
    },
    example: %{"sync" => true, "budget_id" => "bgt_01j0rent"}
  })
end
