defmodule SpendableWeb.Api.Schemas.TransactionSource do
  @moduledoc false
  require OpenApiSpex

  alias OpenApiSpex.Schema
  alias Spendable.Banks.Schemas.BankTransaction

  OpenApiSpex.schema(%{
    title: "TransactionSource",
    description: """
    Where a synced transaction came from, flattened for the list row. Null on a transaction the
    user entered themselves. Fetch the logo from `/api/banks/{member_id}/logo`.
    """,
    type: :object,
    properties: %{
      account_id: %Schema{type: :string},
      account_name: %Schema{type: :string},
      account_number: %Schema{type: :string, nullable: true, description: "Masked, last digits only."},
      member_id: %Schema{type: :string},
      member_name: %Schema{type: :string},
      member_has_logo: %Schema{type: :boolean},
      pending: %Schema{type: :boolean}
    },
    required: [:account_id, :account_name, :member_id, :member_name, :member_has_logo, :pending]
  })

  def build(%BankTransaction{bank_account: %{bank_member: member} = account} = bank_transaction) do
    %__MODULE__{
      account_id: account.id,
      account_name: account.name,
      account_number: account.number,
      member_id: member.id,
      member_name: member.name,
      member_has_logo: is_binary(member.logo),
      pending: bank_transaction.pending
    }
  end

  def build(_no_bank_transaction), do: nil
end
