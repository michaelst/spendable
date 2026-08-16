defmodule SpendableWeb.Api.Schemas.BankMember do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias SpendableWeb.Api.Schemas.BankAccount

  OpenApiSpex.schema(%{
    title: "BankMember",
    description: "A connection to an institution, and the accounts inside it.",
    type: :object,
    properties: %{
      id: %Schema{type: :string},
      name: %Schema{type: :string},
      provider: %Schema{type: :string, description: "Who supplies the connection."},
      status: %Schema{
        type: :string,
        nullable: true,
        description: ~s(Anything other than "CONNECTED" means the user has to reconnect.)
      },
      has_logo: %Schema{
        type: :boolean,
        description: "Fetch it from `/api/banks/{id}/logo` when true."
      },
      bank_accounts: %Schema{type: :array, items: BankAccount}
    },
    required: [:id, :name, :provider, :has_logo, :bank_accounts]
  })

  def build(%Spendable.Banks.Schemas.BankMember{} = member) do
    %__MODULE__{
      id: member.id,
      name: member.name,
      provider: member.provider,
      status: member.status,
      has_logo: is_binary(member.logo),
      bank_accounts: Enum.map(member.bank_accounts, &BankAccount.build/1)
    }
  end
end
