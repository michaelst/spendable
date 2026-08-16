defmodule SpendableWeb.Api.Schemas.FinanceKitConnection do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias SpendableWeb.Api.Schemas.BankAccount

  OpenApiSpex.schema(%{
    title: "FinanceKitConnection",
    description: "The connection everything read out of Wallet belongs to.",
    type: :object,
    properties: %{
      id: %Schema{type: :string},
      name: %Schema{type: :string},
      history_token: %Schema{
        type: :string,
        nullable: true,
        description: "Where the last read left off. Null means nothing has been read yet."
      },
      bank_accounts: %Schema{type: :array, items: BankAccount}
    },
    required: [:id, :name, :bank_accounts]
  })

  def build(%Spendable.Banks.Schemas.BankMember{} = member) do
    %__MODULE__{
      id: member.id,
      name: member.name,
      history_token: member.history_token,
      bank_accounts: Enum.map(member.bank_accounts, &BankAccount.build/1)
    }
  end
end
