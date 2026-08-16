defmodule SpendableWeb.Api.Schemas.BankAccount do
  @moduledoc false
  require OpenApiSpex

  import SpendableWeb.Utils.Money

  alias OpenApiSpex.Schema

  OpenApiSpex.schema(%{
    title: "BankAccount",
    description: "An account inside a connection. Amounts are decimal strings.",
    type: :object,
    properties: %{
      id: %Schema{type: :string},
      name: %Schema{type: :string},
      number: %Schema{type: :string, nullable: true, description: "Masked, last digits only."},
      type: %Schema{type: :string},
      sub_type: %Schema{type: :string},
      balance: %Schema{type: :string, description: "Negative on a credit card, as a ledger reads."},
      sync: %Schema{type: :boolean, description: "Whether activity is pulled and counted."},
      budget_id: %Schema{
        type: :string,
        nullable: true,
        description: "When set, this account's balance is that budget's balance."
      }
    },
    required: [:id, :name, :type, :sub_type, :balance, :sync]
  })

  def build(%Spendable.Banks.Schemas.BankAccount{} = account) do
    %__MODULE__{
      id: account.id,
      name: account.name,
      number: account.number,
      type: account.type,
      sub_type: account.sub_type,
      balance: amount(account.balance),
      sync: account.sync,
      budget_id: account.budget_id
    }
  end
end
